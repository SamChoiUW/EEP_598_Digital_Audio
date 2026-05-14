/*
Project Title: myLastName_Assignment_2a
Date: Wed Apr 15 17:20:57 2026

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



        // -------------
        // ~myBufferFuncs

        // fill CtkBuffers with wavetables
        // - return Dictionary of Arrays. Arrays of buffers are in pitchNames order
        ~myBufferFuncs[\fillWavetables] = { |size, instrNames, pitchNames, sharcData, load = false, sync = false |
            var bufferDict = Dictionary.new;

            instrNames.do({ |instrName|
                bufferDict.put(
                    instrName,
                    pitchNames.collect({ |pitchName|
                        var buffer = CtkBuffer.buffer(
                            size
                        ).sine3(
                            0.0, 1, 1, 1, sharcData[instrName][pitchName][\harmsAmpsPhases].flatten
                        );

                        (load == true).if({
                            buffer.load(  // must -load if wish to use RT server... otherwise, no need to if just using NRT
                                sync: sync
                            )
                        });

                        buffer
                    })
                )
            });

            bufferDict
        };

        // fill CtkBuffers with wave packets
        // - return Dictionary of Arrays. Arrays of buffers are in pitchNames order
        ~myBufferFuncs[\fillWavePackets] = { |size, instrNames, pitchNames, sharcData, load = false, sync = false |
            var bufferDict = Dictionary.new;

            instrNames.do({ |instrName|
                var cosTable = Signal.rfftCosTable(size.div(2) + 1);  // for Signal:-asCtkBuffer;
                bufferDict.put(
                    instrName,
                    pitchNames.collect({ |pitchName|
                        var buffer = CtkBuffer.buffer(
                            size
                        ).packet3(
                            0.0, 1, 0, 1, sharcData[instrName][pitchName][\harmsAmpsPhases].flatten
                        );

                        (load == true).if({
                            buffer.load(  // must -load if wish to use RT server... otherwise, no need to if just using NRT
                                sync: sync
                            )
                        });

                        buffer
                    })
                )
            });

            bufferDict
        };


        // -------------
        // ~myWTScoringFuncs

        // simple scale
        ~myWTScoringFuncs[\simpleScale] = { |start = 0.0, noteDur = 1.0, noteGain = 0.0, noteRiseTime = 0.1, noteDecayTime = 0.1, notePanAngle = 0.0,
            freqs = ([ 440.0 ]), bufnums = ([ 0 ]),
            outBus = 0, ctkProtoNotes|

            var synthDefName = \synthDef_assignment1A;  // fixed...
            var noteParams = Dictionary.new;
            var numNotes;  // number of note events
            var theseFreqs, theseBufnums;

            // mismatched array sizes? - set numNotes to largest array size
            numNotes = [ freqs.size, bufnums.size ].maxItem;

            // extend, as need be - repeat last element
            theseFreqs = freqs.clipExtend(numNotes);
            theseBufnums = bufnums.clipExtend(numNotes);


            // fill the note param dict
            noteParams[\synthdefname] = Array.fill(numNotes, { synthDefName });
            noteParams[\starttime] = Array.series(numNotes, start, noteDur);

            noteParams[\dur] = Array.fill(numNotes, { noteDur });  // UGen graph function dur - for EnvGen
            noteParams[\duration] = Array.fill(numNotes, { noteDur });  // note event duration - for scoring

            noteParams[\gain] = Array.fill(numNotes, { noteGain });
            noteParams[\riseTime] = Array.fill(numNotes, { noteRiseTime });
            noteParams[\decayTime] = Array.fill(numNotes, { noteDecayTime });
            noteParams[\panAngle] = Array.fill(numNotes, { notePanAngle });

            noteParams[\freq] = theseFreqs;  // these are already arrays...
            noteParams[\bufnum] = theseBufnums;

            noteParams[\outBus] = Array.fill(numNotes, { outBus });

            // return a score
            CtkScore.newFromDict(noteParams, ctkProtoNotes)
        };


        // -------------
        // ~myWPScoringFuncs

        // simple scale
        ~myWPScoringFuncs[\simpleScale] = { |start = 0.0, noteDur = 1.0, noteGain = 0.0, noteRiseTime = 0.1, noteDecayTime = 0.1, notePanAngle = 0.0,
            freqs = ([ 440.0 ]), refFreqs = ([ 440.0 ]), waveRatios = ([ 1.0 ]), bufnums = ([ 0 ]),
            outBus = 0, ctkProtoNotes|

            var synthDefName = \synthDef_assignment1A;  // fixed...
            var noteParams = Dictionary.new;
            var numNotes;  // number of note events
            var theseFreqs, theseRefFreqs, theseWaveRatios, theseBufnums;

            // mismatched array sizes? - set numNotes to largest array size
            numNotes = [ freqs.size, refFreqs.size, waveRatios.size, bufnums.size ].maxItem;

            // extend, as need be - repeat last element
            theseFreqs = freqs.clipExtend(numNotes);
            theseRefFreqs = refFreqs.clipExtend(numNotes);
            theseWaveRatios = waveRatios.clipExtend(numNotes);
            theseBufnums = bufnums.clipExtend(numNotes);


            // fill the note param dict
            noteParams[\synthdefname] = Array.fill(numNotes, { synthDefName });
            noteParams[\starttime] = Array.series(numNotes, start, noteDur);

            noteParams[\dur] = Array.fill(numNotes, { noteDur });  // UGen graph function dur - for EnvGen
            noteParams[\duration] = Array.fill(numNotes, { noteDur });  // note event duration - for scoring

            noteParams[\gain] = Array.fill(numNotes, { noteGain });
            noteParams[\riseTime] = Array.fill(numNotes, { noteRiseTime });
            noteParams[\decayTime] = Array.fill(numNotes, { noteDecayTime });
            noteParams[\panAngle] = Array.fill(numNotes, { notePanAngle });

            noteParams[\freq] = theseFreqs;  // these are already arrays...
            noteParams[\refFreq] = theseRefFreqs;
            noteParams[\waveRatio] = theseWaveRatios;
            noteParams[\bufnum] = theseBufnums;

            noteParams[\outBus] = Array.fill(numNotes, { outBus });

            // return a score
            CtkScore.newFromDict(noteParams, ctkProtoNotes)
        };
~myWTScoringFuncs[\additiveScale] = { |start = 0.0, noteDur = 1.0, noteGain = 0.0,
    noteRiseTime = 0.1, noteDecayTime = 0.1, notePanAngle = 0.0,
    durExp = 0.75,
    pitches, specDict, instrName = \violin_martele, buffers,
    outBus = 0, ctkProtoNotes|

    var synthDefName  = \synthDef_assignment1A;
    var noteParams    = Dictionary.new;
    var score;
    var allStartTimes = [];
    var allDurs       = [];
    var allGains      = [];
    var allFreqs      = [];
    var allPhases     = [];
    var allRiseTimes  = [];
    var allDecayTimes = [];
    var allBufnums    = [];
    var allPanAngles  = [];
    var allOutBuses   = [];

    pitches.do({ |p, noteIndex|
        var refFreq         = specDict[instrName][p][\refFreq];
        var harmsAmpsPhases = specDict[instrName][p][\harmsAmpsPhases];
        var noteStart       = start + (noteIndex * noteDur);

        harmsAmpsPhases.do({ |partial|
            var partialNum   = partial[0];
            var partialAmp   = partial[1];
            var partialPhase = partial[2];
            var partialFreq  = refFreq * partialNum;
            var partialDur   = noteDur * (1 / partialNum.pow(durExp));
            var partialDecay = noteDecayTime.min(partialDur * 0.5);

            allStartTimes = allStartTimes.add(noteStart);
            allDurs       = allDurs.add(partialDur);
            allGains = allGains.add(noteGain + partialAmp.ampdb - harmsAmpsPhases.size.ampdb);
            allFreqs      = allFreqs.add(partialFreq);
            allPhases     = allPhases.add(partialPhase);
            allRiseTimes  = allRiseTimes.add(noteRiseTime);
            allDecayTimes = allDecayTimes.add(partialDecay);
            allBufnums    = allBufnums.add(buffers[instrName][noteIndex].bufnum);
            allPanAngles  = allPanAngles.add(notePanAngle);
            allOutBuses   = allOutBuses.add(outBus);
        });
    });

    noteParams[\synthdefname] = Array.fill(allDurs.size, { synthDefName });
    noteParams[\starttime]    = allStartTimes;
    noteParams[\dur]          = allDurs;
    noteParams[\gain]         = allGains;
    noteParams[\freq]         = allFreqs;
    noteParams[\phase]        = allPhases;
    noteParams[\riseTime]     = allRiseTimes;
    noteParams[\decayTime]    = allDecayTimes;
    noteParams[\bufnum]       = allBufnums;
    noteParams[\panAngle]     = allPanAngles;
    noteParams[\outBus]       = allOutBuses;

    score = CtkScore.newFromDict(noteParams, ctkProtoNotes);
    buffers[instrName].do({ |buf| score.add(buf) });
    score
};
// -------------
// ~myBufferFuncs

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
  