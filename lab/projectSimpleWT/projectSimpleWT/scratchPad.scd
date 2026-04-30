/*
Project Title: projectSimpleWT
Date: Tue Apr 21 11:25:12 2026

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
~myClassicWaveData[\saw][\ratios].size;  // 64


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
// prepare wavetable(s) for synthesis - saw

/*
before we're able to synthesize any sound, we'll need to prepare wavetables

when we do so, we're synthesizing (via additve synthesis) one period of the target waveform

this is _much more_ efficient than having separate oscillators for each partial!!
*/

/*
in total, we'll need to prep 9 wavetables, which will be loaded into buffers on the server
*/
~myClassicWaveData.size + ~myBassClarData.size;

/*
a sensible approach, given we have dictionaries of data, would be to create similar
dictionaries of buffers filled with wavetables
*/

~myClassicWaveBuffers = Dictionary.new(~myClassicWaveData.size);

~wavetableSize = 8192;

~myClassicWaveData.keysValuesDo({ |key, waveData|
	var ratios = waveData[\ratios];
	var gains = waveData[\gains];
	var phases = waveData[\phases];
	var harmsAmpsPhases = [ ratios, gains.dbamp, phases ].flop.flatten;  // form required by CtkBuffer: -sine3

	~myClassicWaveBuffers[key] = CtkBuffer.buffer(
		~wavetableSize
	).sine3(
		0.0, // now!
		1,  // normalize peak
		// 0,  // wavetable format (for interpolating oscillator, Osc) - for plotting!
		1,  // wavetable format (for interpolating oscillator, Osc) - for synthesis!
		1,  // clear buffer before filling
		harmsAmpsPhases
	).load
});

// check..
~myClassicWaveBuffers.size;  // so we have a dictionary w/ one wavetable
~myClassicWaveBuffers[\saw];  // .. a buffer

~myClassicWaveBuffers[\saw].plot;



// -------------------------
// synthesize some sounds (via -note)

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;



/*
let's first test with the sawtooth wave
*/

/*
given we're using the realtime server AND we've already loaded the wavetable,
we can just create a note instance and play...

i.e., we don't need to create a score
*/

// instantiate a note
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
	duration: 10.0
)
.dur_(10.0)
.gain_(-9.0)
.freq_(73.195)  // d2
.bufnum_(~myClassicWaveBuffers[\saw].bufnum);  // buffer with saw wavetable!!


// play it
~testNote.play;

/*
the resulting waveform & spectrum _should_ look and sound familiar to what we got when we synthesized
each partial of the sawtooth waveform with a separate SinOsc oscillator... 64 of them!

here, we're using just a single Osc oscillator for the job —— we can think of the wavetable loaded in the
buffer as _pre-synthesized_ additive synthesis

*/

// // free buffers when finished - or wait until the very end...
// ~myClassicWaveBuffers.do({ |buffer| buffer.free });




// -------------------------
// prepare wavetable(s) for synthesis - bass clarinet

/*
to load the buffers for the bass clarinet, we could just repeat what is illustrated in
lines 156 - 176

a smarter way would be to use a function for the job...
... luckily we've already written one!
*/

~myBassClarBuffers = ~myBufferFuncs[\fillWavetables].value(~myBassClarData, load: true, sync: true);


// check..
~myBassClarBuffers.size;  // so we have a dictionary w/ eight wavetables
~myBassClarBuffers;

~myBassClarBuffers[\d2].plot;  // squiggles are a result of wavetable interpolation coefficients

// test...

// instantiate a note
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
	duration: 10.0
)
.dur_(10.0)
.gain_(-9.0)
.freq_(~myBassClarData[\d2][\refFreq])  // d2 - 73.195 Hz
.bufnum_(~myBassClarBuffers[\d2].bufnum);  // buffer with bass clarinet wavetable!!


// play it
~testNote.play;


/*
it sounds bass clarinet like... so that's good!

... let's try another waveform / tone
*/
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
	duration: 10.0
)
.dur_(10.0)
.gain_(-9.0)
.freq_(~myBassClarData[\e2][\refFreq])  // e2 - 82.662  Hz
.bufnum_(~myBassClarBuffers[\e2].bufnum);  // buffer with bass clarinet wavetable!!


// play it
~testNote.play;

/*
NOTE: we updated both the buffer / wavetable AND the fundamental frequency
*/



/*
now... let's write a loop to play a D-major scale.

NOTE: we could turn the below into a scoring function!
NOTE: we're using a score
NOTE: since we're using the realtime server we don't need to add the buffers to the score
*/

~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~startTimes = Array.series(~noteNames.size, 0.0, 2.0);

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~testScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
			starttime: ~startTimes[index],
			duration: 2.0
		)
		.dur_(2.0)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.bufnum_(~myBassClarBuffers[noteName].bufnum)
	)
});

// play it
~testScore.play;


/*
as we tried earlier, what does it sound like if we play a scale, but only use the waveform data of d2 ??

*/

~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~startTimes = Array.series(~noteNames.size, 0.0, 2.0);

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~testScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
			starttime: ~startTimes[index],
			duration: 2.0
		)
		.dur_(2.0)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		// .bufnum_(~myBassClarBuffers[noteName].bufnum)
		.bufnum_(~myBassClarBuffers[\d2].bufnum)  // d2 buffer, rather than spectrum associated with frequency
	)
});

// play it
~testScore.play;


/*
we hear that same _nasal_ effect as we did before when using single oscillators, SinOsc

what we're hearing is the spectrum shifting upwards, so the formants (spectral envelope) don't
remain in place

with vocal sounds, we describe this as the _chipmunk_ or _mickey mouse_ effect
*/



// for fun, lets randomly sort the note order...
~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3].scramble;  // -scramble randomizes the ordering!
~startTimes = Array.series(~noteNames.size, 0.0, 0.5);

~testScore = CtkScore.new;


~noteNames.do({ |noteName, index|
	~testScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
			starttime: ~startTimes[index],
			duration: 0.5
		)
		.dur_(0.5)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.bufnum_(~myBassClarBuffers[noteName].bufnum)
	)
});

// play it
~testScore.play;


// free (all) buffers when finished
~myBassClarBuffers.do({ |buffer| buffer.free });
~myClassicWaveBuffers.do({ |buffer| buffer.free });  // if we haven't already

/*
... we'll want to have a quick look to see what using the nrt server looks like...

see main
*/

