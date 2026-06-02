/*
Project Title: Assignment 3d
Date: Mon May  4 13:52:09 2026

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

~mainScore = CtkScore.new;  // the main score to be rendered


//////////////////////// add buffers /////////////////////////
/*
NOTE: we could write functions to do this!
*/

// 1) collect soundFiles - and instance ctkBuffers
~mySoundFiles = SoundFile.collect(Document.current.dir +/+ "sounds/*");

/*
buffers are collected into a dictionary, where the key is the soundfile name
*/
~mySFBufferDict = Dictionary.newFrom(
	~mySoundFiles.collect({ |item|
		var itemPath = item.path;
		[
			PathName.new(itemPath).fileNameWithoutExtension.replace(".", "_").asSymbol,
			CtkBuffer.playbuf(itemPath)
		]
	}).flatten
);


// 2) add buffers to score
~mySFBufferDict.do({ |item|
	~mainScore.add(item)
});


// list the keys... these are the buffers (soundfiles)!
~mySFBufferDict.keys;


//////////////////////// add note events /////////////////////////


// synthesize descending scales here... 2x!
/*
Descending ratios:
1:1, 15:16, 5:6, 3:4, 2:3, 5:8, 9:16, 1:2  // do, ti, la, sol, fo, mi, re, do

• for the first, pass the descending ratios to _pitchRatio_
• for the second, pass the descending ratios to _formantRatio_

*/


~pitchRatios   = [1, 15/16, 5/6, 3/4, 2/3, 5/8, 9/16, 1/2];
~formantRatios = [1, 15/16, 5/6, 3/4, 2/3, 5/8, 9/16, 1/2];

~start = 0.0;
~gain = 6.0;
~refFreq = 261.5;
~buffer = ~mySFBufferDict[\trumpet_C4_1_forte_normal];
~synthDefKeys = \eep598_monoPlayBuf;


~pitchRatios.do({ |pitchRatios, i|
	~mainScore.add(
		~myPlayBufTransPNotes[~synthDefKeys].note(
			starttime: ~start + (i * ~buffer.duration),
			duration: ~buffer.duration
		)
		.pitchRatio_(pitchRatios)
		.formantRatio_(1)
		.dur_(~buffer.duration)
		.gain_(~gain)
		.refFreq_(~refFreq)
		.bufnum_(~buffer.bufnum)
	)
});

~start = 0.0 + (~pitchRatios.size * ~buffer.duration);
~gain = 6.0;
~refFreq = 261.5;
~buffer = ~mySFBufferDict[\trumpet_C4_1_forte_normal];
~synthDefKeys = \eep598_monoPlayBuf;


~formantRatios.do({ |formantRatios, i|
	~mainScore.add(
		~myPlayBufTransPNotes[~synthDefKeys].note(
			starttime: ~start + (i * ~buffer.duration),
			duration: ~buffer.duration
		)
		.pitchRatio_(1)
		.formantRatio_(formantRatios)
		.dur_(~buffer.duration)
		.gain_(~gain)
		.refFreq_(~refFreq)
		.bufnum_(~buffer.bufnum)
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