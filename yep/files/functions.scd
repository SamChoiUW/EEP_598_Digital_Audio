/*
Project Title: myLastName_Assignment_1a
Date: Wed Apr 29 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
functions here

Problem 1a: Single Sinusoid Additive Synthesis — String Ensemble Model

Functions defined
─────────────────
~myBufferFuncs
  (none required — no wavetable buffers needed for single-sinusoid AS)

~myWTScoringFuncs
  (none — not wavetable-based)

~myWPScoringFuncs
  (none — not wave-packet-based)

~myScoreFuncs
  \sharcLookup         helper: fetch & normalise SHARC cello_vibrato spectrum
  \partialSustain      helper: compute frequency-dependent sustain per partial
  \basisIndex          helper: map ~myData[\basisFunc] symbol → integer index
  \scoreNote           core:   add all partials for one scale note to a CtkScore
  \scoreScale          top:    iterate over scale, call \scoreNote for each degree
  \postNotes           inherited helper (score inspection)
  \scoreWriteOpenSFPlayer  inherited helper (write + open SFPlayer)
*/


// -------------------------
// instantiate dictionaries

~myBufferFuncs    = Dictionary.new;
~myWTScoringFuncs = Dictionary.new;
~myWPScoringFuncs = Dictionary.new;
~myScoreFuncs     = Dictionary.new;


// -------------------------
// add associations


// ────────────────────────────────────────────────────────────────────────────
// ~myScoreFuncs[\sharcLookup]
//
// Fetch the SHARC spectrum for a given MIDI note from cello_vibrato.
// Returns a Dictionary: (amps: Array, numPartials: Integer, midiKey: Integer)
//
// Nearest available SHARC key is used when exact MIDI note is absent.
// Amplitudes are normalised so the maximum == 1.0.
// ────────────────────────────────────────────────────────────────────────────
~myScoreFuncs[\sharcLookup] = { |midiNote, maxPartials = 24|
    var lib     = SHARC.library[~myData[\sharcInstrument]];
    var keys    = lib.keys.asArray.sort;
    var nearest = keys.minItem { |k| (k - midiNote).abs };
    var spect   = lib[nearest];
    var amps    = spect.ampArray;
    var norm    = amps.maxItem.max(1e-9);

    // normalise and trim
    amps = (amps / norm).keep(maxPartials);

    // filter: only retain partials with amplitude above a noise floor
    var threshold = -60.dbamp;   // −60 dB floor
    amps = amps.collect { |a| (a > threshold).if(a, 0.0) };

    // count meaningful partials
    var nPartials = amps.count { |a| a > 0 }.max(1);

    Dictionary.newFrom([
        \amps,       amps,
        \numPartials, nPartials,
        \midiKey,    nearest
    ])
};


// ────────────────────────────────────────────────────────────────────────────
// ~myScoreFuncs[\partialSustain]
//
// Compute frequency-dependent sustain for partial k (1-indexed).
//
// Formula (from D&J fig 5.13 style decay):
//   τ_k = baseSustain * (1 − decayExp * (k−1) / (numPartials−1))
//
// k = 1 (fundamental) → full baseSustain
// k = numPartials     → baseSustain * (1 − decayExp)
//
// Guard: if numPartials == 1, return baseSustain unchanged.
// ────────────────────────────────────────────────────────────────────────────
~myScoreFuncs[\partialSustain] = { |k, numPartials, baseSustain, decayExp|
    var minSustain = 0.05;  // floor to avoid zero-length envelope
    (numPartials <= 1).if({
        baseSustain
    }, {
        var tau = baseSustain * (1.0 - (decayExp * (k - 1) / (numPartials - 1)));
        tau.max(minSustain)
    })
};


// ────────────────────────────────────────────────────────────────────────────
// ~myScoreFuncs[\basisIndex]
//
// Map a basis-function symbol to its integer index for the SynthDef selector.
//   \pure            → 0
//   \detuneStereoBeat → 1
//   \ringNoiseMono   → 2
//   \fmNoiseStereo   → 3
// ────────────────────────────────────────────────────────────────────────────
~myScoreFuncs[\basisIndex] = { |sym|
    var map = Dictionary.newFrom([
        \pure,             0,
        \detuneStereoBeat, 1,
        \ringNoiseMono,    2,
        \fmNoiseStereo,    3
    ]);
    map[sym] ?? { 1 }   // default: detuneStereoBeat
};


// ────────────────────────────────────────────────────────────────────────────
// ~myScoreFuncs[\scoreNote]
//
// Add all partial CtkNotes for a single scale degree to ctkScore.
//
// Arguments
//   ctkScore    : CtkScore to write into
//   midiNote    : MIDI note number for this scale degree
//   startTime   : note onset time in the score (s)
//   data        : ~myData Dictionary (all synthesis parameters)
//   protoNotes  : ~myProtoNotes Dictionary
//
// One CtkNote per non-zero partial.
// Each partial gets:
//   • its own frequency-dependent sustain
//   • a slight random pan position (±ensemblePan / 2) for width
//   • the chosen basisIndex
// ────────────────────────────────────────────────────────────────────────────
~myScoreFuncs[\scoreNote] = { |ctkScore, midiNote, startTime, data, protoNotes|
    var maxPartials  = data[\maxPartials];
    var spect        = ~myScoreFuncs[\sharcLookup].(midiNote, maxPartials);
    var amps         = spect[\amps];
    var numPartials  = spect[\numPartials];
    var fundamental  = midiNote.midicps;

    var baseSustain  = data[\noteDur];
    var decayExp     = data[\partialDecayExp];
    var basisIdx     = ~myScoreFuncs[\basisIndex].(data[\basisFunc]);
    var ensemblePan  = data[\ensemblePan];

    "  note % (MIDI %, %.2f Hz): % partials, SHARC key %".format(
        data[\scaleNames][data[\scaleMidi].indexOf(midiNote)],
        midiNote, fundamental, numPartials, spect[\midiKey]
    ).postln;

    // iterate over partials
    amps.doWithIndex { |partAmp, i|
        var k = i + 1;   // 1-indexed partial number

        (partAmp > 0).if {
            // frequency-dependent sustain for this partial
            var tau     = ~myScoreFuncs[\partialSustain].(
                k, numPartials, baseSustain, decayExp
            );
            // total CtkNote duration = attack + sustain + release
            var noteDur = data[\attack] + tau + data[\release];

            // slight random pan for ensemble spatial spread
            var panPos  = (i / numPartials.max(1) - 0.5) * ensemblePan;

            // noise-frequency for ring/FM basis (scale with partial frequency)
            var partFreq    = fundamental * k;
            var basisNoise  = partFreq / 20.0;   // ~1/20 octave, per additiveBasisFuncs

            ctkScore.add(
                protoNotes[\addStringSingle].note(
                    startTime: startTime,
                    duration:  noteDur
                )
                .partialNum_(k)
                .fundamental_(fundamental)
                .partialAmp_(partAmp)
                .peakAmp_(data[\peakAmp])

                // amplitude envelope
                .attack_(data[\attack])
                .decay_(data[\decay])
                .sustainLvl_(data[\sustainLvl])
                .sustain_(tau)
                .release_(data[\release])

                // portamento
                .portamento_(data[\portamento])

                // random pitch deviation
                .randDevHz_(data[\randDevHz])
                .randDevRate_(data[\randDevRate])

                // vibrato
                .vibratoRate_(data[\vibratoRate])
                .vibratoDepth_(data[\vibratoDepth])
                .vibratoOnset_(data[\vibratoOnset])

                // tremolo
                .tremoloDepth_(data[\tremoloDepth])
                .tremoloRate_(data[\tremoloRate])

                // ensemble / basis
                .ensembleBeats_(data[\ensembleBeats])
                .basisNoiseFreq_(basisNoise)
                .basisDetuneHz_(data[\randDevHz] * k.sqrt)
                .basisIndex_(basisIdx)

                // pan
                .pan_(panPos)
            )
        }
    };

    // return score
    ctkScore
};


// ────────────────────────────────────────────────────────────────────────────
// ~myScoreFuncs[\scoreScale]
//
// Build the complete ascending C major scale score.
//
// Arguments
//   data       : ~myData Dictionary
//   protoNotes : ~myProtoNotes Dictionary
//
// Returns a CtkScore containing all partial CtkNotes for all 8 scale degrees.
// ────────────────────────────────────────────────────────────────────────────
~myScoreFuncs[\scoreScale] = { |data, protoNotes|
    var ctkScore  = CtkScore.new;
    var startTime = data[\startTime];
    var ioI       = data[\noteIOI];
    var midiNotes = data[\scaleMidi];

    "\n=== Scoring C major scale, cello_vibrato SHARC, basis: % ===\n".format(
        data[\basisFunc]
    ).postln;

    midiNotes.doWithIndex { |midi, i|
        "Degree %/%:".format(i + 1, midiNotes.size).postln;
        ~myScoreFuncs[\scoreNote].(
            ctkScore, midi,
            startTime + (i * ioI),
            data, protoNotes
        )
    };

    "\n=== Score built: % CtkNotes total ===\n".format(
        ctkScore.notes.size
    ).postln;

    ctkScore
};


// ────────────────────────────────────────────────────────────────────────────
// Retained helpers from project template
// ────────────────────────────────────────────────────────────────────────────

// helper score inspection function
~myScoreFuncs[\postNotes] = { |ctkScore, sort = true|
    var ctkScoreKey = currentEnvironment.findKeyForValue(ctkScore);
    var notes       = ctkScore.notes(sort);
    var scoreSize   = notes.size;
    var firstNote, score;

    (scoreSize > 0).if({
        firstNote = ctkScore.notes(true).first;
        score     = Score.new(ctkScore.score);

        "CtkScore ~% is filled with % CtkNote(s):\n".format(ctkScoreKey, scoreSize).postln;
        notes.do({ |ctkNote, i|
            "----------------".postln;
            "note instance: %".format(i).postln;
            "\tsynthDef: \t%".format(ctkNote.synthdefname).postln;
            "\tstarttime: \t%".format(ctkNote.starttime).postln;
            "\tduration: \t%".format(ctkNote.duration).postln;
            "synthDef args:".postln;
            ctkNote.args.associationsDo({ |assoc|
                "\t%".format(assoc).postln
            });
            "".postln;
        });
        "--------------------------------------".postln;
        "First note starttime & final score end time:\n".postln;
        "\tstarttime: \t%".format(firstNote.starttime).postln;
        "\tendtime:   \t%".format(score.endTime).postln;
        "".postln
    }, {
        "CtkScore ~% is filled with NO CtkNotes.".format(ctkScoreKey).postln
    });

    ctkScore
};

// helper score write + open SFPlayer
~myScoreFuncs[\scoreWriteOpenSFPlayer] = { |score, outputFilePath|
    var scoreKey = currentEnvironment.findKeyForValue(score);
    { |exitCode, pid|
        (exitCode == 0).if({
            "\n~% rendered to: %\n".format(
                scoreKey,
                outputFilePath.fileName
            ).postln
        }, {
            Error.new(
                "\n~% could not be rendered!\nError: %".format(scoreKey, exitCode)
            ).throw
        });
        { SFPlayer(outputFilePath.fullPath).gui }.defer
    }
};

"functions.scd loaded — ~myScoreFuncs keys: %".format(~myScoreFuncs.keys).postln;
