/*
Project Title: projectSimpleAS
Date: Tue Apr 14 13:28:42 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
scratch here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
_scratchPad_ is the place to write test / scratch code, testing out ideas and
working on code that we'll later formally include in the project.

*/

/////////////// explore interaction with sclang & interpreter ///////////////

// -------------------------
// load functions & data

(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "data.scd").load;


/*
If we review data.scd, we see we have two dictionaries:

~myClassicWaveData
~myBassClarData

The first of these includes data (one waveform) to synthesize a saw wave via additive synthesis.

The second includes data to synthesize _eight_ waveforms necessary to synthesize the bass clarinet tones of a D-major scale.
*/

~myClassicWaveData.size;  // one entry
~myBassClarData.size;  // 8 entries


// let's review the saw data...
~myClassicWaveData[\saw];
~myClassicWaveData[\saw].keys;  // ratios, gains, phases

// ... and plot the waveform via the Signal class in sclang
~plotSize = 8192;
Signal.newClear(~plotSize).sineFill2(
	[
		~myClassicWaveData[\saw][\ratios],
		~myClassicWaveData[\saw][\gains].dbamp,
		~myClassicWaveData[\saw][\phases],
	].flop
).plot("sawtooth waveform");


/*
the squiggles are _partly_ result of truncating the waveform to 64 partials
.. the waveform is bandlimited.. though we can still get foldover if we choose a too high fundamental!!
*/
~myClassicWaveData[\saw][\ratios].size;


// for comparison, let's view the bass clarinet waveforms
~myBassClarData.keysDo({ |noteName|
	Signal.newClear(~plotSize).sineFill2(
		[
			~myBassClarData[noteName][\ratios],
			~myBassClarData[noteName][\gains].dbamp,
			~myBassClarData[noteName][\phases],
		].flop
	).plot("bass clarinet waveform: %".format(noteName));
});

/*
surprisingly, the waveforms for each note name (pitch) are fairly different from each other!

this shouldn't be completely unexpected if we recall that the frequency domain _spectral envelope_ is
the important aspect, rather than the time domain waveform. (See D&J chapter 2.5, especially )
*/

// something we should also note, is that each note name (pitch) has an associated nominal reference frequency:
~myBassClarData[\d2][\refFreq];

// synthesizing the waveform at the reference frequency reproduces the measured bass clarinet spectrum



/////////////// explore interaction with scsynth & interpreter ///////////////


// -------------------------
// load synthDefs (& ctkProtoNotes)

/*
Let's load the synthDefs found in the file named _synthDefs_
*/

(Document.current.dir +/+ "synthDefs.scd").load;


// -------------------------
// list project synthDefs
(
"This project has % synthDef(s), named:\n".format(~myDodgeJersePNotes.synthdefs.size).postln;
~myDodgeJersePNotes.synthdefs.do({ |synthDef|
	("\t" ++ synthDef.name.asString).postln
});
"".postln
);
/*
NOTE: there's only one!
*/


// -------------------------
// play w/ synthDef(s)

// boot (realtime) server
s.boot;



// -------------------------
// synthesize some sounds

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;


/*
let's first test with the sawtooth wave
*/

// test score
~testScore = CtkScore.new;

// additive synth function
~myASScoringFuncs[\simpleAS].value(
	~testScore,
	~myDodgeJersePNotes[\dxarts46x_dodgeJerse_phase_fig_4_5],
	~myClassicWaveData[\saw],
	dur: 10.0,
	gain: -9.0,
	freq: 73.195  // d2
);

// play it
~testScore.play;

/*
in the stethoscope we can see the sawtooth shape (yea!!)

in the freq analyzer we can see that we're seeing the result is bandlimited... only 64 partials!
*/


/*
let's try the bass clarinet...
*/

~testScore = CtkScore.new;

// additive synth function
~myASScoringFuncs[\simpleAS].value(
	~testScore,
	~myDodgeJersePNotes[\dxarts46x_dodgeJerse_phase_fig_4_5],
	~myBassClarData[\d2],
	dur: 10.0,
	gain: -9.0,
	freq: ~myBassClarData[\d2][\refFreq]  // d2 - 73.195 Hz
);

// play it
~testScore.play;

/*
it sounds bass clarinet like... so that's good!

... let's try another waveform / tone
*/


~testScore = CtkScore.new;

// additive synth function
~myASScoringFuncs[\simpleAS].value(
	~testScore,
	~myDodgeJersePNotes[\dxarts46x_dodgeJerse_phase_fig_4_5],
	~myBassClarData[\e2],
	dur: 10.0,
	gain: -9.0,
	freq: ~myBassClarData[\e2][\refFreq]  // e2 - 82.662 Hz
);

// play it
~testScore.play;

/*
NOTE: we updated both the waveform AND the fundamental frequency
*/


/*
now... let's write a loop to play a D-major scale.

NOTE: we could turn the below into a scoring function!
*/

~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~startTimes = Array.series(~noteNames.size, 0.0, 2.0);

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~myASScoringFuncs[\simpleAS].value(
		~testScore,
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_phase_fig_4_5],
		~myBassClarData[noteName],
		start: ~startTimes[index],
		dur: 2.0,
		gain: -9.0,
		freq: ~myBassClarData[noteName][\refFreq]
	);
});

// play it
~testScore.play;


/*
for curiosity, what does it sound like if we play a scale, but only use the waveform data of d2 ??

*/

~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~startTimes = Array.series(~noteNames.size, 0.0, 2.0);

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~myASScoringFuncs[\simpleAS].value(
		~testScore,
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_phase_fig_4_5],
		// ~myBassClarData[noteName],
		~myBassClarData[\d2],  // d2 data, rather than spectrum associated with frequency
		start: ~startTimes[index],
		dur: 2.0,
		gain: -9.0,
		freq: ~myBassClarData[noteName][\refFreq]
	);
});

// play it
~testScore.play;

/*
.. interestingly enough, it still sounds _clarinet like_, but towards the end of the scale
it sounds _nasal_

what we're hearing is the spectrum shifting upwards, so the formants (spectral envelope) don't
remain in place

with vocal sounds, we describe this as the _chipmunk_ or _mickey mouse_ effect
*/



// for fun, lets randomly sort the note order...
~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3].scramble;  // -scramble randomizes the ordering!
~startTimes = Array.series(~noteNames.size, 0.0, 0.5);

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~myASScoringFuncs[\simpleAS].value(
		~testScore,
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_phase_fig_4_5],
		// ~myBassClarData[noteName],
		~myBassClarData[\d2],  // d2 data, rather than spectrum associated with frequency
		start: ~startTimes[index],
		dur: 0.5,
		gain: -9.0,
		freq: ~myBassClarData[noteName][\refFreq]
	);
});

// play it
~testScore.play;

