/*
Project Title: projectSimpleWS
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

// recall, each note name (pitch) has an associated nominal reference frequency:
~myBassClarData[\d2][\refFreq];

// synthesizing the waveform at the reference frequency reproduces the measured bass clarinet spectrum


// --- waveshaping ---
/*
if we'd like to resynthesize the waveforms _exactly_ with waveshaping synthesis, we need to pay
attention to the phases of partials of the target waveforms.

the _saw_ waveform requires a sum of sines, which corresponds to 2nd kind waveshaping

the _bass clarinet_ waveforms require a sum of cosines AND sines. we'll need 3rd kind waveshaping

*/

// the corresponding 2nd kind waveshaping table for saw will be
// ... plot as a signal to see the shape
Signal.chebyUFill(~plotSize, ~myClassicWaveData[\saw][\gains].dbamp).plot("sawtooth waveshaper");

// for comparison, the 3rd kind shapers for the bass clarinet
// ...takes a bit of time...
/*
cosine, sine --> chebyT, chebyU
*/
~myBassClarData.keysDo({ |noteName|
	Signal.chebyTUFill2(~plotSize,
		[
			~myBassClarData[noteName][\ratios],
			~myBassClarData[noteName][\gains].dbamp,
			~myBassClarData[noteName][\phases],
		].flop
	).plot("bass clarinet waveform: %".format(noteName));
});





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
NOTE: the are three, one for each waveshaping kind
*/



// -------------------------
// play w/ synthDef(s)

// boot (realtime) server
s.boot;


// -------------------------
// prepare waveshaping table(s) for synthesis - saw

/*
before we're able to synthesize any sound, we'll need to prepare waveshaping table(s)

*/

/*
in total, we'll need to prep 1 + (2 * 8) wavetables, which will be loaded into buffers on the server
*/
~myClassicWaveData.size + (2 * ~myBassClarData.size);

/*
a sensible approach, given we have dictionaries of data, would be to create similar
dictionaries of buffers filled with wavetables
*/

~myClassicWaveUBuffers = Dictionary.new(~myClassicWaveData.size);

~waveshaperSize = 8192;

~myClassicWaveData.keysValuesDo({ |key, waveData|
	var gains = waveData[\gains];  // note: we only need \gains, as we'll be using -chebyU (sines) to synthesize!!
	var amps = gains.dbamp;

	~myClassicWaveUBuffers[key] = CtkBuffer.collection(
		Wavetable.chebyUFill(~waveshaperSize.div(2) + 1, amps)  // shaper for sum of sines
	).load

});

// check..
~myClassicWaveUBuffers.size;  // so we have a dictionary w/ one wavetable
~myClassicWaveUBuffers[\saw];  // .. a buffer

~myClassicWaveUBuffers[\saw].plot;



// -------------------------
// synthesize some sounds (via -note)

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;


/*
let's first test with the sawtooth wave
*/

/*
given we're using the realtime server AND we've already loaded the waveshaping table,
we can just create a note instance and play...

i.e., we don't need to create a score
*/


// instantiate a note
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_2nd_kind].note(
	duration: 5.0
)
.dur_(5.0)
.riseTime_(1.0)  // exaggerate modulation envelope!!
.decayTime_(1.0)
.gain_(-9.0)
.freq_(73.195)  // d2
.bufnumU_(~myClassicWaveUBuffers[\saw].bufnum);  // buffer with saw waveshaping table!!


// play it
~testNote.play;


// instantiate a note - reduced index of modulation
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_2nd_kind].note(
	duration: 5.0
)
.dur_(5.0)
.riseTime_(1.0)  // exaggerate modulation envelope!!
.decayTime_(1.0)
.gain_(-9.0)
.freq_(73.195)  // d2
.modIndex_(0.9)  // <--
.bufnumU_(~myClassicWaveUBuffers[\saw].bufnum);  // buffer with saw waveshaping table!!


// play it
~testNote.play;


// instantiate a note - _more_ reduced index of modulation
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_2nd_kind].note(
	duration: 5.0
)
.dur_(5.0)
.riseTime_(1.0)  // exaggerate modulation envelope!!
.decayTime_(1.0)
.gain_(-9.0)
.freq_(73.195)  // d2
.modIndex_(0.8)  // <--
.bufnumU_(~myClassicWaveUBuffers[\saw].bufnum);  // buffer with saw waveshaping table!!


// play it
~testNote.play;


/*
when the _index of modulation_ is 1.0, we get all 64 partials of the sawtooth waveform

when it is less, we get a different balance between the various partials, dependent on the chosen _index_

in contrast with wavetable synthesis, waveshaping synthesis offers a dynamic spectral envelope!!
*/

// // free buffers when finished - or wait until the very end...
// ~myClassicWaveUBuffers.do({ |buffer| buffer.free });



// -------------------------
// prepare waveshaping table(s) for synthesis - bass clarinet


/*
as the bass clarinet waveform data _requires_ phases, we'll need to use 3rd kind waveshaping...
... which means that we'll need to use two buffers for each spectrum: chebyT AND chebyU

we'll use the function \fillWaveshaperTU for the job
*/
~myBassClarTUBuffers = ~myBufferFuncs[\fillWaveshaperTU].value(~myBassClarData, load: true, sync: true);


// check..
~myBassClarTUBuffers.size;  // so we have a dictionary w/ eight dictionaries...
~myBassClarTUBuffers;  // ... which contain T AND U shapers

~myBassClarTUBuffers[\d2][\T].plot;  // squiggles are a result of wavetable interpolation coefficients
~myBassClarTUBuffers[\d2][\U].plot;


// test...

// instantiate a note
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind].note(
	duration: 5.0
)
.dur_(5.0)
.riseTime_(1.0)  // exaggerate modulation envelope!!
.decayTime_(1.0)
.gain_(-9.0)
.freq_(~myBassClarData[\d2][\refFreq])  // d2 - 73.195 Hz
.bufnumT_(~myBassClarTUBuffers[\d2][\T].bufnum)  // buffers with bass clarinet waveshaping table!!
.bufnumU_(~myBassClarTUBuffers[\d2][\U].bufnum);


// play it
~testNote.play;  // nice!!



// instantiate a note - reduced index of modulation
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind].note(
	duration: 5.0
)
.dur_(5.0)
.riseTime_(1.0)  // exaggerate modulation envelope!!
.decayTime_(1.0)
.gain_(-9.0)
.freq_(~myBassClarData[\d2][\refFreq])  // d2 - 73.195 Hz
.modIndex_(0.7)  // <--
.bufnumT_(~myBassClarTUBuffers[\d2][\T].bufnum)  // buffers with bass clarinet waveshaping table!!
.bufnumU_(~myBassClarTUBuffers[\d2][\U].bufnum);


// play it
~testNote.play;  // nice!!


// instantiate a note - _more_ reduced index of modulation
~testNote = ~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind].note(
	duration: 5.0
)
.dur_(5.0)
.riseTime_(1.0)  // exaggerate modulation envelope!!
.decayTime_(1.0)
.gain_(-9.0)
.freq_(~myBassClarData[\d2][\refFreq])  // d2 - 73.195 Hz
.modIndex_(0.5)  // <--
.bufnumT_(~myBassClarTUBuffers[\d2][\T].bufnum)  // buffers with bass clarinet waveshaping tables!!
.bufnumU_(~myBassClarTUBuffers[\d2][\U].bufnum);


// play it
~testNote.play;  // nice!!



/*
as we've done with wavetable synthesis, let's write a loop to play a D-major scale.

NOTE: we could turn the below into a scoring function!
NOTE: we're using a score
NOTE: since we're using the realtime server we don't need to add the buffers to the score
*/

~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~startTimes = Array.series(~noteNames.size, 0.0, 2.0);

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~testScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind].note(
			starttime: ~startTimes[index],
			duration: 2.0
		)
		.dur_(2.0)
		// .riseTime_(0.05)
		// .decayTime_(0.25)
		// .decayTime_(0.5)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.bufnumT_(~myBassClarTUBuffers[noteName][\T].bufnum)  // buffers with bass clarinet waveshaping tables!!
		.bufnumU_(~myBassClarTUBuffers[noteName][\U].bufnum)
	)
});

// play it
~testScore.play;

/*
what are we hearing here?
*/


// how about increasing indexes of modulation ??

~noteNames = [\d2, \e2, 'f#2', \g2, \a2, \b2, 'c#3', \d3];
~startTimes = Array.series(~noteNames.size, 0.0, 0.5);
~modIndexs = Array.interpolation(~noteNames.size, 0.1, 1.0);
// ~modIndexs = Array.interpolation(~noteNames.size, 0.1, 1.0).sqrt;  // sounds better?

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~testScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind].note(
			starttime: ~startTimes[index],
			duration: 0.5
		)
		.dur_(0.5)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.modIndex_(~modIndexs[index])
		.bufnumT_(~myBassClarTUBuffers[noteName][\T].bufnum)  // buffers with bass clarinet waveshaping tables!!
		.bufnumU_(~myBassClarTUBuffers[noteName][\U].bufnum)
	)
});

// play it
~testScore.play;


// how about random indexes of modulation on d2 ??

~noteNames = Array.fill(32, { \d2 });
~startTimes = Array.series(~noteNames.size, 0.0, 0.5);
~modIndexs = Array.rand(~noteNames.size, 0.1, 1.0);
// ~modIndexs = Array.rand(~noteNames.size, 0.1, 1.0).sqrt;  // sounds better?

~testScore = CtkScore.new;

~noteNames.do({ |noteName, index|
	~testScore.add(
		~myDodgeJersePNotes[\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind].note(
			starttime: ~startTimes[index],
			duration: 0.5
		)
		.dur_(0.5)
		.gain_(-9.0)
		.freq_(~myBassClarData[noteName][\refFreq])
		.modIndex_(~modIndexs[index])
		.bufnumT_(~myBassClarTUBuffers[noteName][\T].bufnum)  // buffers with bass clarinet waveshaping tables!!
		.bufnumU_(~myBassClarTUBuffers[noteName][\U].bufnum)
	)
});

// play it
~testScore.play;



// free (all) buffers when finished
~myBassClarTUBuffers.do({ |bufferKindDict|
	bufferKindDict.do({ |buffer|
		buffer.free
	})
});
~myClassicWaveUBuffers.do({ |buffer| buffer.free });  // if we haven't already

/*
... we'll want to have a quick look to see what using the nrt server looks like...

see main
*/
