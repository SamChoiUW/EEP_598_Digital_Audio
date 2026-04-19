/*
Project Title: Assignment 1
Date: Sun Mar 29 16:35:26 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/


// -------------------------------------------------------------------------------------------
/*
1)

Determine your personal, subjective tolerance for aliasing of the following classic waveforms:

a) Sawtooth
b) Square
c) Impulse

Audition each waveform and report the following information:

· system sample rate
      48000.0
· fundamental frequency at which foldover becomes unacceptable
· highest partial number before unacceptable aliasing begins

*/

// ----------
/*
1a) Sawtooth

bandlimited UGen: Saw
non-bandlimited UGen: LFSaw
*/

// boot server.. if not already!!
s.boot;

// displays.. if not already!!
s.scope;
FreqScope.new;
// bandlimited test
(
~testUgenGraphFunc = {
	var gain = -12.0;
	var freq = MouseX.kr(20.0, 5000.0, \exponential);

	freq.poll(label: \freq);

	Saw.ar(freq, gain.dbamp).dup(2)
}
)


// audition
~test = ~testUgenGraphFunc.play; // Yea I cannot tell.....
~test.free;  // stop!


// non-bandlimited test
(
~testUgenGraphFunc = {
	var gain = -12.0;
	var freq = MouseX.kr(20.0, 5000.0, \exponential);

	freq.poll(label: \freq);

	LFSaw.ar(freq, mul: gain.dbamp).dup(2)
}
)

// audition
~test = ~testUgenGraphFunc.play; //800Hz ish
~test.free;  // stop!



// sampleRate
s.sampleRate;

// Nyquist frequency??
~nyquist = s.sampleRate / 2;

// freq??
~freq = 800.0;


// find partial number aliasing limit
~aliasPartialLimit = (~nyquist / ~freq).floor.asInteger;
~aliasPartialLimit * ~freq;  // highest unaliased freq


// report here:
/*
sampleRate: 48000.0
maxFreq: 800.0
aliased partial number limit: 30
*/



// ----------
/*
1b) Square

bandlimited UGen: Pulse  // width: 0.5
non-bandlimited UGen: LFPulse  // width: 0.5, remap waveform to ±1
*/

// bandlimited test

// ------------------- YOUR CODE HERE - start ------------------- //
(
~testUgenGraphFunc = {
	var gain = -12.0;
	var freq = MouseX.kr(20.0, 5000.0, \exponential);

	freq.poll(label: \freq);

	Pulse.ar(freq,0.5,2,-1.0).dup(2)
}
)


// ------------------- YOUR CODE HERE - end --------------------- //


// displays..
s.scope;
FreqScope.new;


// audition
~test = ~testUgenGraphFunc.play;
~test.free;  // stop!


// non-bandlimited test
// NOTE: LFPulse returns 0-1, remap ±1

// ------------------- YOUR CODE HERE - start ------------------- //
(
~testUgenGraphFunc = {
	var gain = -12.0;
	var freq = MouseX.kr(20.0, 5000.0, \exponential);

	freq.poll(label: \freq);

	LFPulse.ar(freq,0.0,0.5,2,-1).dup(2)
}



// ------------------- YOUR CODE HERE - end --------------------- //
)

// audition
~test = ~testUgenGraphFunc.play; //620 Hz
~test.free;  // stop!


// sampleRate
s.sampleRate;

// Nyquist frequency??
~nyquist = s.sampleRate / 2;

// freq??
~freq = 620.0;


// find partial number aliasing limit
/*
NOTE:

square wave has ONLY _odd_ harmonics!!

... so the reported limit should be and _odd_ partial number

... you can use -if and -odd OR just manually report
*/
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //


// report here:
/*
sampleRate:
maxFreq:
aliased partial number limit:
*/



// ----------
/*
1c) Impulse

bandlimited UGen: Blip
non-bandlimited UGen: Impulse
*/

// bandlimited test
// NOTE: set numharm to 2000 to generate full band spectrum
(
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //
)

// displays..
s.scope;
FreqScope.new;


// audition
~test = ~testUgenGraphFunc.play;
~test.free;  // stop!


// non-bandlimited test
(
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //
)

// audition
~test = ~testUgenGraphFunc.play;
~test.free;  // stop!



// sampleRate
s.sampleRate;

// Nyquist frequency??
~nyquist = s.sampleRate / 2;

// freq??
~freq = 0.0;


// find partial number aliasing limit
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //


// report here:
/*
sampleRate:
maxFreq:
aliased partial number limit:
*/



// -------------------------------------------------------------------------------------------
/*
2)

Determine your personal, subjective tolerance for aliasing of linear interpolating wavetable lookup oscillator sizes: 16 - 8192

Audition each wavetable and note the following information:

· system sample rate
· minimum size at which aliasing becomes unacceptable


UGen: Osc
*/

// boot server.. if not already!!
s.boot;

// displays.. if not already!!
s.scope;
FreqScope.new;



// design wavetables
~sizes = Array.geom(10, 16, 2).reverse;  // powers of 2

~buffers = ~sizes.collect({ |thisSize|
	Buffer.alloc(
		s,
		thisSize
	).sine1(
		[ 1.0 ],  // fundamental only
		asWavetable: true  // Osc requires wavetable format
	)
});

// plot, for fun!!
~buffers.do({ |thisBuffer| thisBuffer.plot });  // should see interpolation coeffs!!

// check buffer numbers...
~buffers.do({ |thisBuffer| thisBuffer.bufnum.postln });  // consecutive...


// test ugen graph func
(
~testUgenGraphFunc = { |bufnum = 0|  // one argument
	var gain = -24.0;
	var freq = MouseX.kr(20.0, 5000.0, \exponential);

	freq.poll(label: \freq);

	Osc.ar(bufnum, freq, mul: gain.dbamp).dup(2)
}
)

// audition
~test = ~testUgenGraphFunc.play;

// default is buffer 0, size = 8192
// try the next
~test.set(\bufnum, 0); // 8192
~test.set(\bufnum, 1); // 4096

// ... and the next...
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //


~test.free;  // stop!
~buffers.do({ |thisBuffer| thisBuffer.free });


// report here:
/*
sampleRate:
minSize:
*/



// -------------------------------------------------------------------------------------------
/*
3)

Determine your personal, subjective tolerance for aliasing of non-interpolating wavetable lookup oscillator sizes: 16 - 8192

Audition each wavetable and note the following information:

· system sample rate
· minimum size at which aliasing becomes unacceptable


UGen: OscN
*/

// boot server.. if not already!!
s.boot;

// displays.. if not already!!
s.scope;
FreqScope.new;


// design wavetables
~sizes = Array.geom(10, 16, 2).reverse;  // powers of 2

// NOTE: wavetable flag should be false!!
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //

// plot, for fun!!
~buffers.do({ |thisBuffer| thisBuffer.plot });  // direclty sampled waveforms - should see sample sines

// check buffer numbers...
~buffers.do({ |thisBuffer| thisBuffer.bufnum.postln });  // consecutive...


// test ugen graph func
// NOTE: use OscN
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //


// audition
~test = ~testUgenGraphFunc.play;

// default is buffer 0, size = 8192
// try the next
~test.set(\bufnum, 0); // 8192
~test.set(\bufnum, 1); // 4096

// ... and the next...
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //

~test.free;  // stop!
~buffers.do({ |thisBuffer| thisBuffer.free });


// report here:
/*
sampleRate:
minSize:
*/



// -------------------------------------------------------------------------------------------
/*
4)

Determine your personal equal loudness contour(s) (listener * headphone OR loudspeaker)

· 3 freqs / octave
· 2 levels
· reference to 1 kHz, as perceived gain match

https://en.wikipedia.org/wiki/Equal-loudness_contour
https://www.iso.org/standard/83117.html
https://cdn.standards.iteh.ai/samples/83117/6afa5bd94e0e4f32812c28c3b0a7b8ac/ISO-226-2023.pdf


Audition and note the following information:

· system sample rate
· gain matching at 2 reference levels: -36, -46 dB


UGen: SinOsc
*/
/*
NOTE:

Sinusoid gain perception is significantly dependent upon loudspeaker (and/or headphone) relationship to listener!!
*/


// boot server.. if not already!!
s.boot;

// displays.. if not already!!
s.scope;
FreqScope.new;


// report here:
/*
sampleRate:
system: [ loudspeaker or headphone make & model ]
*/


// ISO 226:2023
(
~freqs = [
	20.0, 25.0, 31.5,
	40.0, 50.0, 63.0,
	80.0, 100.0, 125.0,
	160.0, 200.0, 250.0,
	315.0, 400.0, 500.0,
	630.0, 800.0, 1000.0,
	1250.0, 1600.0, 2000.0,
	2500.0, 3150.0, 4000.0,
	5000.0, 6300.0, 8000.0,
	10000.0, 12500.0  // doesn't complete last octave!
];  // 29 freqs
)


// test ugen graph func
(
~testUgenGraphFunc = { |freq0 = 1000.0, gain0 = -36.0, freq1 = 1000.0, gain1 = -36.0, toggleRate = 0.5|
	var lagTime = toggleRate.reciprocal * 0.25;

	(
		SinOsc.ar(
			[ freq0, freq1 ],
			mul: [ gain0, gain1 ].dbamp
		) * Lag.kr(
			LFPulse.kr(toggleRate, mul: [ 1, -1 ], add: [ 0, 1 ]),
			lagTime
		)
	).sum.dup(2)
}
)


// ------
// 4a) begin by referencing to 1000 Hz @ -36 dB
/*
set hardware volume to comfortable level

*/

// audition
~test = ~testUgenGraphFunc.play;  // 1000.0 Hz, -36 dB


// test freq1 descending... assign \gain1 to perceptually match
~test.set(\freq1, ~freqs.at(16)); // 800.0
~test.set(\gain1, -36.0);

~test.set(\freq1, ~freqs.at(15)); // 630.0
~test.set(\gain1, -36.0);

// manually continue test sequence... 500.0 - 20.0 Hz
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //


// test freq1 ascending... assign \gain1 to perceptually match
~test.set(\freq1, ~freqs.at(18)); // 1250.0
~test.set(\gain1, -36.0);

// manually continue test sequence... 1600.0 - 12500.0 Hz
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //

~test.free;


// manually consolidate gains into an array: referenced to -36dB
// collect from 20.0 to 12500.0 Hz
// ... be sure to include gain for 1000.0 Hz, -36dB
~gains1 = [
	// ------------------- YOUR CODE HERE - start ------------------- //


	// ------------------- YOUR CODE HERE - end --------------------- //
];
// placeholder vals - comment out when measured gains are determined
~gains1 = -36.0.dup(~freqs.size);

~gains1.plot("equal loudness contour: 1000 Hz @ -36 dB");




// ------
// 4b) second test, referencing to 1000 Hz @ -46 dB
/*
leave hardware volume set to level as in 4a)

*/


// audition
~test = ~testUgenGraphFunc.play;  // 1000.0 Hz, -36 dB

// reset levels: -46.0
~test.set(\gain0, -46.0);
~test.set(\gain1, -46.0);


// test freq1 descending... assign \gain1 to perceptually match
~test.set(\freq1, ~freqs.at(16)); // 800.0
~test.set(\gain1, -46.0);

// manually continue test sequence... 630.0 - 20.0 Hz
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //



// test freq1 ascending... assign \gain1 to perceptually match
~test.set(\freq1, ~freqs.at(18)); // 1250.0
~test.set(\gain1, -46.0);

// manually continue test sequence... 1600.0 - 12500.0 Hz
// ------------------- YOUR CODE HERE - start ------------------- //


// ------------------- YOUR CODE HERE - end --------------------- //

~test.free;


// manually consolidate gains into an array: referenced to -46dB
// collect from 20.0 to 12500.0 Hz
// ... be sure to include gain for 1000.0 Hz, -46dB
~gains2 = [
	// ------------------- YOUR CODE HERE - start ------------------- //


	// ------------------- YOUR CODE HERE - end --------------------- //
];
// placeholder vals - comment out when measured gains are determined
~gains2 = -46.0.dup(~freqs.size);

~gains2.plot("equal loudness contour: 1000 Hz @ -46 dB");

// for a linear system, we'd expect to see a 10 dB difference...
(~gains1 - ~gains2).plot("equal loudness contour, difference");



/*
audition the contours
*/

// fill buffers for audition...
~freqsBuf = Buffer.loadCollection(s, ~freqs);
~freqsBuf.bufnum;
~freqsBuf.plot;

~gainsBuf1 = Buffer.loadCollection(s, ~gains1);
~gainsBuf1.bufnum;
~gainsBuf1.plot;

~gainsBuf2 = Buffer.loadCollection(s, ~gains2);
~gainsBuf2.bufnum;
~gainsBuf2.plot;

~gainsBuf2.numFrames


// test ugen graph func
(
~testUgenGraphFunc = { |freqsBufnum = 0, gainsBufnum = 1|  // two arguments
	var index = MouseX.kr(0, ~freqs.size - 1);  // 0 to ~freqs.size - 1
	var freq = IndexL.kr(freqsBufnum, index);
	var gain = IndexL.kr(gainsBufnum, index);

	freq.poll(label: \freq);
	gain.poll(label: \gain);

	SinOsc.ar(freq, mul: gain.dbamp).dup(2)
}
)

// audition
/*
for either of these, we may wish to update gains
*/

/*
confirm - gains1
*/
~test = ~testUgenGraphFunc.play;
~test.free;

/*
confirm - gains2
*/
~test = ~testUgenGraphFunc.play;
~test.set(\gainsBufnum, ~gainsBuf2.bufnum)
~test.free;


// free all buffers on the server...
Buffer.freeAll(s);

// ... or with a -do loop
[
	~freqsBuf,
	~gainsBuf1,
	~gainsBuf2
].do({ |thisBuffer| thisBuffer.free });


// quit the server!
s.quit;