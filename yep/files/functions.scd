/*
Project Title: myLastName_Assignment_2b
Date: Wed Apr 15 17:21:21 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
functions here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


// -------------------------
// instantiate dictionaries
~myBufferFuncs = Dictionary.new;

~myWTScoringFuncs = Dictionary.new;
~myWPScoringFuncs = Dictionary.new;

~myScoreFuncs = Dictionary.new;


// -------------------------
// add associations


// -------------
// ~myBufferFuncs

// (no custom buffer-fill functions needed for this project —
//  wavetable buffers are built directly in data.scd via CtkBuffer:-sine3)


// -------------
// ~myWTScoringFuncs

/*
\singleTone
Score a single multi-segment wavetable tone.
One CtkNote → one oscillator linearly interpolated across three wavetables.

Arguments:
  start           score start time (seconds)
  dur             total note duration (seconds)
  gain            overall amplitude (dB)
  freq            playback frequency (Hz)
  fundamentalFreq reference frequency of the wavetables (Hz)
  riseTime        amplitude attack (seconds)
  decayTime       amplitude release (seconds)
  crescTime       time to ff peak from note start (seconds)
  decrescTime     time from ff peak back to pp (seconds)
  vibratoRate     vibrato rate (Hz)
  vibratoDepth    vibrato depth (semitones)
  vibratoDelay    seconds before vibrato begins
  vibratoOnset    vibrato fade-in duration (seconds)
  pitchNoise      random pitch deviation (semitones)
  wtSelLead       seconds wavetable selection leads amplitude
  wtBufs          Array of 3 CtkBuffers [ pp, ff, pp ]
  panAngle        stereo pan angle (degrees)
  outBus          output bus
  ctkProtoNotes   Dictionary of CtkSynthDef prototypes
*/
~myWTScoringFuncs[\singleTone] = { |
    start           = 0.0,
    dur             = 8.0,
    gain            = -12.0,
    freq            = 440.0,
    fundamentalFreq = 440.0,
    riseTime        = 0.10,
    decayTime       = 0.30,
    crescTime       = 4.5,
    decrescTime     = 4.0,
    vibratoRate     = 5.5,
    vibratoDepth    = 0.40,
    vibratoDelay    = 0.80,
    vibratoOnset    = 0.60,
    pitchNoise      = 0.08,
    wtSelLead       = 0.30,
    wtBufs,
    panAngle        = 0.0,
    outBus          = 0,
    ctkProtoNotes |

    var noteParams = Dictionary.new;

    noteParams[\synthdefname]    = [ \synthDef_msWT ];
    noteParams[\starttime]       = [ start ];
    noteParams[\dur]             = [ dur ];
    noteParams[\duration]        = [ dur ];
    noteParams[\gain]            = [ gain ];
    noteParams[\freq]            = [ freq ];
    noteParams[\fundamentalFreq] = [ fundamentalFreq ];
    noteParams[\riseTime]        = [ riseTime ];
    noteParams[\decayTime]       = [ decayTime ];
    noteParams[\crescTime]       = [ crescTime ];
    noteParams[\decrescTime]     = [ decrescTime ];
    noteParams[\vibratoRate]     = [ vibratoRate ];
    noteParams[\vibratoDepth]    = [ vibratoDepth ];
    noteParams[\vibratoDelay]    = [ vibratoDelay ];
    noteParams[\vibratoOnset]    = [ vibratoOnset ];
    noteParams[\pitchNoise]      = [ pitchNoise ];
    noteParams[\wtSelLead]       = [ wtSelLead ];
    noteParams[\buf0]            = [ wtBufs[0].bufnum ];
    noteParams[\buf1]            = [ wtBufs[1].bufnum ];
    noteParams[\buf2]            = [ wtBufs[2].bufnum ];
    noteParams[\panAngle]        = [ panAngle ];
    noteParams[\outBus]          = [ outBus ];

    CtkScore.newFromDict(noteParams, ctkProtoNotes)
};


/*
\ascendingScale
Score an ascending scale of multi-segment wavetable tones.
All notes share the same three wavetable buffers (derived from the A4
recording); playback frequency is set per note so pitch transposes correctly.

Additional arguments vs \singleTone:
  freqs       Array of playback frequencies (Hz) for each scale step
  noteDur     duration of each note (seconds)
  noteGap     silence between consecutive notes (seconds)
  crescTime   if nil, defaults to 40% of noteDur
  decrescTime if nil, defaults to 45% of noteDur
  panAngles   Array of pan angles (degrees); nil = all centred
*/
~myWTScoringFuncs[\ascendingScale] = { |
    start           = 0.0,
    noteDur         = 6.0,
    noteGap         = 0.3,
    gain            = -12.0,
    fundamentalFreq = 440.0,
    freqs,
    riseTime        = 0.08,
    decayTime       = 0.25,
    crescTime,
    decrescTime,
    vibratoRate     = 5.5,
    vibratoDepth    = 0.35,
    vibratoDelay    = 0.70,
    vibratoOnset    = 0.50,
    pitchNoise      = 0.08,
    wtSelLead       = 0.25,
    wtBufs,
    panAngles,
    outBus          = 0,
    ctkProtoNotes |

    var numNotes    = freqs.size;
    var noteStep    = noteDur + noteGap;
    var thisCresc   = crescTime   ?? { noteDur * 0.40 };
    var thisDecresc = decrescTime ?? { noteDur * 0.45 };
    var noteParams  = Dictionary.new;

    noteParams[\synthdefname]    = Array.fill(numNotes, { \synthDef_msWT });
    noteParams[\starttime]       = Array.series(numNotes, start, noteStep);
    noteParams[\dur]             = Array.fill(numNotes, { noteDur });
    noteParams[\duration]        = Array.fill(numNotes, { noteDur });
    noteParams[\gain]            = Array.fill(numNotes, { gain });
    noteParams[\freq]            = freqs;
    noteParams[\fundamentalFreq] = Array.fill(numNotes, { fundamentalFreq });
    noteParams[\riseTime]        = Array.fill(numNotes, { riseTime });
    noteParams[\decayTime]       = Array.fill(numNotes, { decayTime });
    noteParams[\crescTime]       = Array.fill(numNotes, { thisCresc });
    noteParams[\decrescTime]     = Array.fill(numNotes, { thisDecresc });
    noteParams[\vibratoRate]     = Array.fill(numNotes, { vibratoRate });
    noteParams[\vibratoDepth]    = Array.fill(numNotes, { vibratoDepth });
    noteParams[\vibratoDelay]    = Array.fill(numNotes, { vibratoDelay });
    noteParams[\vibratoOnset]    = Array.fill(numNotes, { vibratoOnset });
    noteParams[\pitchNoise]      = Array.fill(numNotes, { pitchNoise });
    noteParams[\wtSelLead]       = Array.fill(numNotes, { wtSelLead });
    noteParams[\buf0]            = Array.fill(numNotes, { wtBufs[0].bufnum });
    noteParams[\buf1]            = Array.fill(numNotes, { wtBufs[1].bufnum });
    noteParams[\buf2]            = Array.fill(numNotes, { wtBufs[2].bufnum });
    noteParams[\panAngle]        = (panAngles ?? { Array.fill(numNotes, { 0.0 }) }).clipExtend(numNotes);
    noteParams[\outBus]          = Array.fill(numNotes, { outBus });

    CtkScore.newFromDict(noteParams, ctkProtoNotes)
};


// -------------
// ~myWPScoringFuncs

// (wave packet synthesis not used in this assignment)


// -------------
// ~myScoreFuncs

// helper score inspection function
~myScoreFuncs[\postNotes] = { |ctkScore, sort = true|
    var ctkScoreKey = currentEnvironment.findKeyForValue(ctkScore);
    var notes = ctkScore.notes(sort);
    var scoreSize = notes.size;
    var firstNote, score;

    (scoreSize > 0).if({
        firstNote = ctkScore.notes(true).first;
        score = Score.new(ctkScore.score);  // actual score with final timestamp

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
        "\tendtime: \t\t%".format(score.endTime).postln;
        "".postln
    }, {
        "CtkScore ~% is filled with NO CtkNotes.".format(ctkScoreKey).postln
    });

    // return ctkScore
    ctkScore
};

// helper score write SFPlayer function
~myScoreFuncs[\scoreWriteOpenSFPlayer] = { |score, outputFilePath|
    var scoreKey = currentEnvironment.findKeyForValue(score);

    // function to return
    { |exitCode, pid|
        (exitCode == 0).if({
            "\n~% rendered to: %\n".format(
                scoreKey,
                outputFilePath.fileName
            ).postln
        }, {
            Error.new("\n~% could not be rendered!\nError: %".format(
                scoreKey,
                exitCode
            )
            ).throw
        });

        // open in SFPlayer - when finished!
        {
            SFPlayer(outputFilePath.fullPath).gui
        }.defer
    }
};
