/*
Project Title: projectSimpleAS
Date: Tue Apr 14 13:28:42 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
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
~myASScoringFuncs = Dictionary.new;

~myScoreFuncs = Dictionary.new;


// -------------------------
// add associations


// -------------
// ~~myAddSynScoringFuncs

// (general) additive synthesis - scoring function
~myASScoringFuncs[\simpleAS] = { |ctkScore, synthDef, partialData,
	start = 0.0, dur = 20.0, gain = 0.0, riseTime = 0.1, decayTime = 0.1, freq = 440.0, panAngle = 0, outBus = 0|

	var numNotes = partialData.values.collect({ |item| item.size }).maxItem;  // number of note events
	var normDb;

	// catch mismatched array sizes for \ratios, \gains, \phases
	(
		partialData[\gains].size != (partialData[\ratios].size & partialData[\phases].size)
	).if({
		Error.new("Partial data gains, ratios, phases sizes do not match!").throw
	});

	// calcs
	normDb = partialData[\gains].dbamp.sum.ampdb.neg;  // L1-norm - rescale gain

	// add notes to score...
	numNotes.do({ |partialNum|  // count through each partial number (index)

		ctkScore.add(

			synthDef.note(
				start,  // starttime - note event
				dur,  // duration - note event
			)
			.dur_(dur)  // dur - synthDef
			.gain_(gain + normDb + partialData[\gains][partialNum])  // gain - synthDef
			.riseTime_(riseTime)  // riseTime - synthDef
			.decayTime_(decayTime)  // decayTime - synthDef
			.freq_(freq * partialData[\ratios][partialNum])  // freq - synthDef
			.phase_(partialData[\phases][partialNum])  // phase - synthDef
			.panAngle_(panAngle)  // panAngle - synthDef
			.outBus_(outBus)  // outBus - synthDef
		)

	});

	// ... and return the score
	ctkScore
};



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
  