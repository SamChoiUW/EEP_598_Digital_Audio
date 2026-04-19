/*
Project Title: myLasName Assignment 1b
Date: Sun Mar 29 16:35:26 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
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

s.boot;

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


// ---------------------------------
FreqScope.new;
s.scope;


// ---------------------------------
/*
score risset bell partials for \rissetBell_1210 via scoring function \simpleBell

*/


// first set up starttime, dur, gain & freq values to be used
// ... we'll need to use variables to do so, as they'll be used repeatedly
~bellStarttime = 0.0;  // in seconds
~bellDur = 20.0;  // in seconds
~bellGain = -20.0;  // in dB
~bellFreq = 400.0;  // in Hz


// call the \simpleBell function
~myBellScoringFuncs[\simpleBell].value(
	~mainScore,
	~myRissetBellPNotes[\dxarts46x_percSinOsc],  // single oscillator per partial
	~myBellData[\rissetBell_1210],
	~bellStarttime,
	~bellDur,
	~bellGain + 20.0,
	freq: ~bellFreq
);

~myBellScoringFuncs[\simpleBell].value(
	~mainScore,
	~myRissetBellPNotes[\dxarts46x_percSinOscQ],  // quadrature oscillator pairs per partial
	~myBellData[\rissetBell_1210],
	~bellStarttime + 10.0,
	~bellDur,
	~bellGain + 20.0,
	freq: ~bellFreq
);

/*
update ~bellFreq to 178.57

score \rissetBell_1700
at time ~bellStarttime + 20.0

use quadrature oscillator synth: \dxarts46x_percSinOscQ
*/
~bellFreq = 178.57;
~myBellScoringFuncs[\simpleBell].value(
	~mainScore,
	~myRissetBellPNotes[\dxarts46x_percSinOscQ],  // quadrature oscillator pairs per partial
	~myBellData[\rissetBell_1700],
	~bellStarttime + 20.0,
	~bellDur,
	~bellGain + 20.0,
	freq: ~bellFreq
);
/*
update ~bellFreq to 459.8
update ~bellDur as per Slaymaker & Meeker, Table II

score 'germantown_a#4'
at time ~bellStarttime + 30.0

use quadrature oscillator synth: \dxarts46x_percSinOscQ
*/
~bellFreq = 459.8;
~bellDur = 42.8;
~myBellScoringFuncs[\simpleBell].value(
	~mainScore,
	~myRissetBellPNotes[\dxarts46x_percSinOscQ],  // quadrature oscillator pairs per partial
	~myBellData['germantown_a#4'],
	~bellStarttime + 30.0,
	~bellDur,
	~bellGain + 20.0,
	freq: ~bellFreq
);
/*
update ~bellFreq to 462.7
update ~bellDur as per Slaymaker & Meeker, Table VI

score 'valley_forge_a#4'
at time ~bellStarttime + 40.0

use quadrature oscillator synth: \dxarts46x_percSinOscQ
*/

~bellFreq = 462.7;
~bellDur = 42.9;
~myBellScoringFuncs[\simpleBell].value(
	~mainScore,
	~myRissetBellPNotes[\dxarts46x_percSinOscQ],  // quadrature oscillator pairs per partial
	~myBellData['valley_forge_a#4'],
	~bellStarttime + 10.0,
	~bellDur,
	~bellGain + 30.0,
	freq: ~bellFreq
);
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
