/*
Project Title: choi_Assignment_2b
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


// -------------
// ~myWTScoringFuncs

~myWTScoringFuncs[\tone] = { |
    start           = 0.0,
    dur             = 9.5,
    gain            = -12.0,
    freq            = 440.0,
    fundamentalFreq = 440.0,
    riseTime        = 0.10,
    decayTime       = 0.30,
    crescTime       = 4.5,
    decrescTime     = 4.5,
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
    noteParams[\pitchNoise]      = [ pitchNoise ];
    noteParams[\wtSelLead]       = [ wtSelLead ];
    noteParams[\buf0]            = [ wtBufs[0].bufnum ];
    noteParams[\buf1]            = [ wtBufs[1].bufnum ];
    noteParams[\buf2]            = [ wtBufs[2].bufnum ];
    noteParams[\buf3]            = [ wtBufs[3].bufnum ];
    noteParams[\buf4]            = [ wtBufs[4].bufnum ];
    noteParams[\buf5]            = [ wtBufs[5].bufnum ];
    noteParams[\buf6]            = [ wtBufs[6].bufnum ];
    noteParams[\buf7]            = [ wtBufs[7].bufnum ];
    noteParams[\panAngle]        = [ panAngle ];
    noteParams[\outBus]          = [ outBus ];

    CtkScore.newFromDict(noteParams, ctkProtoNotes)
};

// -------------
// ~myWPScoringFuncs


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
  