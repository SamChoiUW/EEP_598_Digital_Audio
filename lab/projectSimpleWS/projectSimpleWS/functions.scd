/*
Project Title: projectSimpleWS
Date: Tue Apr 21 11:25:12 2026

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
~myBufferFuncs = Dictionary.new;

~myScoreFuncs = Dictionary.new;


// -------------------------
// add associations


// -------------
// ~myBufferFuncs

// fill CtkBuffers with waveshaping tables
// - return Dictionary of CtkBuffers
// - args same as \fillWavetables

// 1st kind
// server side: CtkBuffer: -cheby
/*
~myBufferFuncs[\fillWaveshaperT] = { |partialData, size = 8192, time = 0.0, normalize = 1, wavetable = 1, clear = 1, load = false, sync = false|
	var bufferDict = Dictionary.new(partialData.size);

	partialData.keysValuesDo({ |key, waveData|
		var gains = waveData[\gains];  // note: we only need \gains, as we'll be using -chebyT (cosines) to synthesize!!
		var amps = gains.dbamp;
		var buffer = CtkBuffer.buffer(
			size
		).cheby(
			time,
			normalize,
			wavetable,
			clear,
			amps
		);

		(load == true).if({
			buffer.load(  // must -load if wish to use RT server... otherwise, no need to if just using NRT
				sync: sync
			)
		});

		bufferDict[key] = buffer
	});

	bufferDict
};
*/

// 1st kind
// language side: Signal: -chebyTFill or Wavetable: -chebyTFill
~myBufferFuncs[\fillWaveshaperT] = { |partialData, size = 8192, time = 0.0, normalize = 1, wavetable = 1, clear = 1, load = false, sync = false|
	var bufferDict = Dictionary.new(partialData.size);

	partialData.keysValuesDo({ |key, waveData|
		var gains = waveData[\gains];  // note: we only need \gains, as we'll be using -chebyT (cosines) to synthesize!!
		var amps = gains.dbamp;
		var shaper = (wavetable == 1).if({
			Wavetable.chebyTFill(size.div(2) + 1, amps, (normalize == 1))
		}, {
			Signal.chebyTFill(size, amps, (normalize == 1))
		});
		var buffer = CtkBuffer.collection(
			shaper
		);

		(load == true).if({
			buffer.load(  // must -load if wish to use RT server... otherwise, no need to if just using NRT
				sync: sync
			)
		});

		bufferDict[key] = buffer
	});

	bufferDict
};


// 2nd kind
// language side: Signal: -chebyUFill or Wavetable: -chebyUFill
~myBufferFuncs[\fillWaveshaperU] = { |partialData, size = 8192, time = 0.0, normalize = 1, wavetable = 1, clear = 1, load = false, sync = false|
	var bufferDict = Dictionary.new(partialData.size);

	partialData.keysValuesDo({ |key, waveData|
		var gains = waveData[\gains];  // note: we only need \gains, as we'll be using -chebyT (cosines) to synthesize!!
		var amps = gains.dbamp;
		var shaper = (wavetable == 1).if({
			Wavetable.chebyUFill(size.div(2) + 1, amps, (normalize == 1))
		}, {
			Signal.chebyUFill(size, amps, (normalize == 1))
		});
		var buffer = CtkBuffer.collection(
			shaper
		);

		(load == true).if({
			buffer.load(  // must -load if wish to use RT server... otherwise, no need to if just using NRT
				sync: sync
			)
		});

		bufferDict[key] = buffer
	});

	bufferDict
};


// 3rd kind
// language side: Signal: -chebyTUFill or Wavetable: -chebyTUFill
/*
returns T, U pairs in dictionary, indexed by \T, \U
*/
~myBufferFuncs[\fillWaveshaperTU] = { |partialData, size = 8192, time = 0.0, normalize = 1, wavetable = 1, clear = 1, load = false, sync = false|
	var bufferDict = Dictionary.new(partialData.size);

	partialData.keysValuesDo({ |key, waveData|
		var kindKeys = [ \T, \U ];
		var gains = waveData[\gains];
		var phases = waveData[\phases];
		var amps = gains.dbamp;
		var shapers = (wavetable == 1).if({
			Wavetable.chebyTUFill(size.div(2) + 1, amps, phases, (normalize == 1))
		}, {
			Signal.chebyTUFill(size, amps, phases, (normalize == 1))
		});
		var bufferKindDict = Dictionary.new(kindKeys.size);

		// dictionary
		kindKeys.do({ |kindKey, index|
			bufferKindDict.put(
				kindKey,
				CtkBuffer.collection(shapers[index])
			)
		});

		(load == true).if({
			bufferKindDict.do({ |buffer|
				buffer.load(  // must -load if wish to use RT server... otherwise, no need to if just using NRT
					sync: sync
				)
			})
		});

		bufferDict[key] = bufferKindDict
	});

	bufferDict
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
  