/*
Project Title: myLastName_Assignment_2a
Date: Wed Apr 15 17:20:57 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
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


// s.quit;
Quarks.gui
ServerOptions.new.device
 ;
ServerOptions.devices;
s.options.inDevice = nil;
s.options.outDevice = "Nothing Ear (a)";
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 2;
s.options.sampleRate = 44000;

 s.boot;
(Document.current.dir +/+ "synthDefs.scd").load;
(Document.current.dir +/+ "functions.scd").load;


///////////////// set RT/NRT environment variables ///////////////

~sampleRate = s.sampleRate.isNil.if({   // set sampleRate
    "% sampleRate is %. Try booting rt server.".format(s, s.sampleRate).warn;
	"setting SR to 48000".postln;
	48000
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
*/

~mainScore = CtkScore.new;

~rootFreq    = 440.0;
~baseDur     = 3.0;
~numPartials = 12;
~durExp      = 0.75;
~startTime   = 0.0;

// loop over partials — one synth per partial
~numPartials.do({ |i|
    var partialNum  = i + 1;
    var partialFreq = ~rootFreq * partialNum;
    var partialDur  = ~baseDur * (1 / partialNum.pow(~durExp));
    var partialGain = -14.0 - (partialNum * 3.0);

    ~mainScore.add(
        ~myProtoNotes[\synthDef_assignment1A].note(~startTime, partialDur)
        .dur_(partialDur)
        .gain_(partialGain)
        .freq_(partialFreq)
		.phase_(0)
		.beats_(1.0)
        .riseTime_(0.1)
        .decayTime_((0.1).min(partialDur * 0.5))
        .noiseFreq_(0.5)
        .panAngle_(0)
        .outBus_(0)
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
  