/*
Project Title: projectSimpleWT
Date: Tue Apr 21 11:25:12 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
_main_ is where we'll organize the "main" tasks of our project.

*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


///////////////// load functions, data & synthDefs ///////////////

/*
If we haven't already, we'll want to load functions, data and synthDefs.

*/
(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "data.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;



///////////////// set RT/NRT environment variables ///////////////

~sampleRate = s.sampleRate.isNil.if({   // set sampleRate
    "% sampleRate is %. Try booting rt server.".format(s, s.sampleRate).warn;
}, {
    s.sampleRate.asInteger
});
~serverOptions = ServerOptions.new;
~serverOptions.numOutputBusChannels = 2;  // stereo --> 2 channels
~headerFormat = "WAV";                    // soundfile header format
~sampleFormat = "int24";                  // soundfile sample format

~outputFilePath = PathName.new(
    "%/%/_%.%".format(
        Document.current.dir,
        "sounds",
        PathName.new(Document.current.dir).fileName,
        ~headerFormat.toLower
    )
);


///////////////// set scoring parameter values //////////////////

/*
create score(s)...

e.g.:

~mainScore = ...;
*/
~mainScore = CtkScore.new;


// add buffers - using function & iteration

// 1) collect ctkBuffers in dictionaries
~myClassicWaveBuffers = ~myBufferFuncs[\fillWavetables].value(~myClassicWaveData);  // NRT, so don't need to load or sync
~myBassClarBuffers = ~myBufferFuncs[\fillWavetables].value(~myBassClarData);

// 2) add buffers to score
~myClassicWaveBuffers.do({ |buffer|
	~mainScore.add(buffer)
});
~myBassClarBuffers.do({ |buffer|
	~mainScore.add(buffer)
});


// now add notes to score...

// instantiate a note - saw
~mainScore.add(
	~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
		starttime: 0.0,
		duration: 5.0
	)
	.dur_(5.0)
	.gain_(-9.0)
	.freq_(73.195)  // d2
	.bufnum_(~myClassicWaveBuffers[\saw].bufnum)  // buffer with saw wavetable!!
);

// instantiate a note - bass clar
~mainScore.add(
	~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
		starttime: 5.0,
		duration: 5.0
	)
	.dur_(5.0)
	.gain_(-9.0)
	.freq_(~myBassClarData[\d2][\refFreq])  // d2 - 73.195 Hz
	.bufnum_(~myBassClarBuffers[\d2].bufnum)  // buffer with bass clarinet wavetable!!
);


// ... and a scale...
~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~scaleStart = 10.0;
~noteDur = 1.0;
~startTimes = Array.series(~noteNames.size, ~scaleStart, ~noteDur);

~noteNames.do({ |noteName, index|
	~mainScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
			starttime: ~startTimes[index],
			duration: ~noteDur
		)
		.dur_(~noteDur)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.bufnum_(~myBassClarBuffers[noteName].bufnum)
	)
});


// ... let's go rando!!!
~noteNames = ~noteNames.dupEach(4).scramble;
~scaleStart = ~startTimes.last + ~noteDur;
~noteDur = ~noteDur / 4;
~startTimes = Array.series(~noteNames.size, ~scaleStart, ~noteDur);

~noteNames.do({ |noteName, index|
	~mainScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
			starttime: ~startTimes[index],
			duration: ~noteDur
		)
		.dur_(~noteDur)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.bufnum_(~myBassClarBuffers[noteName].bufnum)
	)
});


///////////////// render the main score //////////////////


// write score to sound file with the -write message, and then open with helper score function, \scoreWriteOpenSFPlayer
(
    ~mainScore.write(
        path: ~outputFilePath.fullPath,
        sampleRate: ~sampleRate,
        headerFormat: ~headerFormat,
        sampleFormat: ~sampleFormat,
        options: ~serverOptions,
        action: ~myScoreFuncs[\scoreWriteOpenSFPlayer].value(~mainScore, ~outputFilePath)
    )
);

/*
NOTE:

we could synthesize and then open "by hand"...
*/
/*
(
~mainScore.write(
path: ~outputFilePath.fullPath,
sampleRate: ~sampleRate,
headerFormat: ~headerFormat,
sampleFormat: ~sampleFormat,
options: ~serverOptions,
)
);

// wait until final nextOSCPacket is posted...
"Wait until nextOSCPacket % is posted before opening SFPlayer.".format(Score.new(~mainScore.score).endTime).postln;

// ... open in SFPlayer...
SFPlayer.new(~outputFilePath.fullPath).gui;
*/


// ... when finished, free buffers...
/*
it is always good practice to free up buffers when finished!!
- if we want to continue modifying the scores, it is fine to leave the buffers loaded
*/

/*
NOTE:

If we've only used the non-realtime server, this step is not necessary.

For instance, if we've only used -write rather than -play, we don't need to free buffers.

*/
  