/*
Project Title: myLastName_Assignment_1a
Date: Wed Apr 29 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
_scratchPad_: interactive exploration and RT testing.

Evaluate sections in order.  Boot the RT server before playing sounds.
*/

/*
For examples see:
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/////////////// explore interaction with sclang & interpreter ///////////////

// ─────────────────────────────────────────────────────────────────────────────
// A. Load project files
// ─────────────────────────────────────────────────────────────────────────────

(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "data.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;

currentEnvironment.keys.postln;


// ─────────────────────────────────────────────────────────────────────────────
// B. Inspect SHARC data for the scale
// ─────────────────────────────────────────────────────────────────────────────

// Post SHARC spectrum info for every scale degree
(
~myData[\scaleMidi].doWithIndex { |midi, i|
    var spect = ~myScoreFuncs[\sharcLookup].(midi, ~myData[\maxPartials]);
    "%-% MIDI % → SHARC key %, % partials above floor".format(
        ~myData[\scaleNames][i], " ".dup(4 - ~myData[\scaleNames][i].size).join,
        midi, spect[\midiKey], spect[\numPartials]
    ).postln;
    "  amps: %".format(
        spect[\amps].collect { |a| a.round(0.001) }
    ).postln;
}
)

// Check frequency-dependent sustain for first note (C4, 12 partials)
(
var spect = ~myScoreFuncs[\sharcLookup].(60, ~myData[\maxPartials]);
var n     = spect[\numPartials];
"Frequency-dependent sustain for C4 (% partials):".format(n).postln;
n.do { |i|
    var k   = i + 1;
    var tau = ~myScoreFuncs[\partialSustain].(
        k, n, ~myData[\noteDur], ~myData[\partialDecayExp]
    );
    "  partial % (%.1f Hz): τ = %.3f s".format(k, 261.63 * k, tau).postln
}
)


/////////////// explore interaction with scsynth & interpreter ///////////////

// ─────────────────────────────────────────────────────────────────────────────
// C. Boot RT server and open scopes
// ─────────────────────────────────────────────────────────────────────────────

s.boot;

FreqScope.new;
Stethoscope.new;


// ─────────────────────────────────────────────────────────────────────────────
// D. RT playback — single note, all partials  (middle C, cello_vibrato)
// ─────────────────────────────────────────────────────────────────────────────

// Build a mini CtkScore for one note and play it in RT
(
var midi    = 60;   // C4
var spect   = ~myScoreFuncs[\sharcLookup].(midi, ~myData[\maxPartials]);
var amps    = spect[\amps];
var nP      = spect[\numPartials];
var fund    = midi.midicps;
var score   = CtkScore.new;
var bIdx    = ~myScoreFuncs[\basisIndex].(~myData[\basisFunc]);

amps.doWithIndex { |a, i|
    var k   = i + 1;
    (a > 0).if {
        var tau = ~myScoreFuncs[\partialSustain].(
            k, nP, ~myData[\noteDur], ~myData[\partialDecayExp]
        );
        var dur = ~myData[\attack] + tau + ~myData[\release];
        var pan = (i / nP.max(1) - 0.5) * ~myData[\ensemblePan];

        score.add(
            ~myProtoNotes[\addStringSingle].note(startTime: 0.1, duration: dur)
            .partialNum_(k)
            .fundamental_(fund)
            .partialAmp_(a)
            .peakAmp_(~myData[\peakAmp])
            .attack_(~myData[\attack])
            .decay_(~myData[\decay])
            .sustainLvl_(~myData[\sustainLvl])
            .sustain_(tau)
            .release_(~myData[\release])
            .portamento_(~myData[\portamento])
            .randDevHz_(~myData[\randDevHz])
            .randDevRate_(~myData[\randDevRate])
            .vibratoRate_(~myData[\vibratoRate])
            .vibratoDepth_(~myData[\vibratoDepth])
            .vibratoOnset_(~myData[\vibratoOnset])
            .tremoloDepth_(~myData[\tremoloDepth])
            .tremoloRate_(~myData[\tremoloRate])
            .ensembleBeats_(~myData[\ensembleBeats])
            .basisNoiseFreq_(fund * k / 20.0)
            .basisDetuneHz_(~myData[\randDevHz] * k.sqrt)
            .basisIndex_(bIdx)
            .pan_(pan)
        )
    }
};

"Playing C4 — % partials, basis: %".format(nP, ~myData[\basisFunc]).postln;
score.play(s)
)


// ─────────────────────────────────────────────────────────────────────────────
// E. Compare basis functions — play same note with each
// ─────────────────────────────────────────────────────────────────────────────

/*
Evaluate this block to hear all four basis functions back-to-back (C4).
Each plays for ~noteDur + release seconds with a short gap.
*/
(
var midi    = 60;
var gap     = ~myData[\noteDur] + ~myData[\release] + 0.5;
var bases   = [\pure, \detuneStereoBeat, \ringNoiseMono, \fmNoiseStereo];

bases.doWithIndex { |sym, i|
    ~myData[\basisFunc] = sym;

    var spect = ~myScoreFuncs[\sharcLookup].(midi, ~myData[\maxPartials]);
    var amps  = spect[\amps];
    var nP    = spect[\numPartials];
    var fund  = midi.midicps;
    var score = CtkScore.new;
    var bIdx  = ~myScoreFuncs[\basisIndex].(sym);
    var t0    = 0.1;

    amps.doWithIndex { |a, j|
        var k   = j + 1;
        (a > 0).if {
            var tau = ~myScoreFuncs[\partialSustain].(
                k, nP, ~myData[\noteDur], ~myData[\partialDecayExp]
            );
            score.add(
                ~myProtoNotes[\addStringSingle].note(startTime: t0, duration: tau + ~myData[\release])
                .partialNum_(k).fundamental_(fund).partialAmp_(a)
                .peakAmp_(~myData[\peakAmp])
                .attack_(~myData[\attack]).decay_(~myData[\decay])
                .sustainLvl_(~myData[\sustainLvl]).sustain_(tau).release_(~myData[\release])
                .portamento_(~myData[\portamento])
                .randDevHz_(~myData[\randDevHz]).randDevRate_(~myData[\randDevRate])
                .vibratoRate_(~myData[\vibratoRate]).vibratoDepth_(~myData[\vibratoDepth])
                .vibratoOnset_(~myData[\vibratoOnset])
                .tremoloDepth_(~myData[\tremoloDepth]).tremoloRate_(~myData[\tremoloRate])
                .ensembleBeats_(~myData[\ensembleBeats])
                .basisNoiseFreq_(fund * k / 20.0)
                .basisDetuneHz_(~myData[\randDevHz] * k.sqrt)
                .basisIndex_(bIdx)
                .pan_((j / nP.max(1) - 0.5) * ~myData[\ensemblePan])
            )
        }
    };

    AppClock.sched(i * gap, {
        "Playing basis: %".format(sym).postln;
        score.play(s);
        nil
    })
};

// restore chosen basis
~myData[\basisFunc] = \detuneStereoBeat;
)


// ─────────────────────────────────────────────────────────────────────────────
// F. Spot-check frequency-dependent decay (C4 partials 1, 6, 12)
// ─────────────────────────────────────────────────────────────────────────────
(
var midi = 60;
var fund = midi.midicps;
var spect = ~myScoreFuncs[\sharcLookup].(midi, ~myData[\maxPartials]);
var nP   = spect[\numPartials];
var bIdx = ~myScoreFuncs[\basisIndex].(~myData[\basisFunc]);

[1, (nP / 2).round.asInteger, nP].do { |k|
    var a   = spect[\amps][k - 1];
    var tau = ~myScoreFuncs[\partialSustain].(k, nP, ~myData[\noteDur], ~myData[\partialDecayExp]);
    (a > 0).if {
        var score = CtkScore.new;
        score.add(
            ~myProtoNotes[\addStringSingle].note(startTime: 0.05, duration: tau + ~myData[\release])
            .partialNum_(k).fundamental_(fund).partialAmp_(a)
            .peakAmp_(0.3)
            .attack_(~myData[\attack]).decay_(~myData[\decay])
            .sustainLvl_(~myData[\sustainLvl]).sustain_(tau).release_(~myData[\release])
            .portamento_(~myData[\portamento])
            .randDevHz_(~myData[\randDevHz]).randDevRate_(~myData[\randDevRate])
            .vibratoRate_(~myData[\vibratoRate]).vibratoDepth_(~myData[\vibratoDepth])
            .vibratoOnset_(~myData[\vibratoOnset])
            .tremoloDepth_(~myData[\tremoloDepth]).tremoloRate_(~myData[\tremoloRate])
            .ensembleBeats_(~myData[\ensembleBeats])
            .basisNoiseFreq_(fund * k / 20.0)
            .basisDetuneHz_(~myData[\randDevHz] * k.sqrt)
            .basisIndex_(bIdx)
            .pan_(0.0)
        );
        "Partial %: %.1f Hz, τ = %.3f s".format(k, fund * k, tau).postln;

        AppClock.sched(k * (tau + 0.5), {
            score.play(s);
            nil
        })
    }
}
)


// ─────────────────────────────────────────────────────────────────────────────
// G. Full RT scale playback (preview before NRT render)
// ─────────────────────────────────────────────────────────────────────────────

(
var score = ~myScoreFuncs[\scoreScale].(~myData, ~myProtoNotes);
score.play(s)
)

// when we're all finished, free buffers (none used here — no action needed)
// s.freeAll;
