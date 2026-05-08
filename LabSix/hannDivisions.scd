/*
Title: hannDivisions
Date: Wed Apr 29 15:25:25 2026

EE P 598a - Sp26
Authors: Joseph Anderson
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/


/*
for integer ratio "divisions" of the fundamental frequency of a periodic signal,
we can ring modulate against a carefully designed _windowing function_
to synthesize _additional_ harmonic partials of the desired ratio (of the fundamental)

padded hann windows are a suitable window choice

HelpBrowser.goTo("https://en.wikipedia.org/wiki/Hann_function")


we'll have two args to consider:
- freq: the (ring) modulating window fundamental frequency
- padFac: the window zero padding factor

*/


/*
let's start by writing a function that will return a hann window with given zero padding factor

*/

// as Signal
(
~hannPadWindowFunc = { |size = 4096, padFac = 0|
	Signal.hannWindow(
		size,
		(size * padFac).asInteger
	)
}
)


/*
to "multiply" the fundamental frequency by an iteger ratio, we'll set ring modulator oscillator frequency
and hann window padFac

- freq = freq / ratio
- padFac = 1 - (2 / ratio)

*/

// let's view the windows for each ratio >= 2

~numDivs = 7;
~divs = Array.series(~numDivs, 2);  // fundamental frequency division ratios, 2.. 8

~padFacs = 1 - (2 / ~divs);


~padFacs.collect({ |padFac|
	~hannPadWindowFunc.value(padFac: padFac)
}).plot("hann modulation windows", minval: 0.0, maxval: 1.0);




/*
let's collect ugenGraphs by division ratio to try this out....

NOTE:

since we're designing separate UGen graphs for each division ratio, we can use LocalBuf
so as to keep each modulating window included with each UGen graph... nice!!!

*/

// reset...
~numDivs = 8;
~divs = Array.series(~numDivs, 1);  // fundamental frequnecy division ratios, 1.. 8


// ... test with Saw source, first
(
~ugenGraphFuncs = ~divs.collect({ |div|

	(div == 1).if({
		{ |refFreq = 440.0, minRefFreq = 20.0, gain = -12.0|  // pass for div == 1

			Saw.ar(refFreq, gain.dbamp)
		}
	}, {
		{ |refFreq = 440.0, minRefFreq = 20.0, gain = -12.0|  // otherwise ring modulate
			var in;
			var size = 4096;
			var padFac = 1 - (2 / div);
			var tableBuffer = LocalBuf.newFrom(~hannPadWindowFunc.value(size, padFac).asWavetable);
			// var normFac = 1.0;  // no scaling - maintains waveform peak
			var normFac = div.sqrt;  // maintains power (rms)
			// var normFac = div;  // maintains original harmonic gain

			in = Saw.ar(refFreq, gain.dbamp);
			in * Osc.ar(tableBuffer, refFreq / div, mul: normFac)
		}
	})
})
);


/*
audition...
*/
s.boot;
s.quit;

s.scope;
FreqScope.new;

~refFreq = 440.0;

// play
~synth = ~ugenGraphFuncs.at(1 - 1).play;  // div 1
~synth = ~ugenGraphFuncs.at(2 - 1).play;  // div 2
~synth = ~ugenGraphFuncs.at(4 - 1).play;  // div 4
~synth = ~ugenGraphFuncs.at(8 - 1).play;  // div 8

~synth.set(\refFreq, ~refFreq);
~synth.set(\refFreq, ~refFreq * 2.pow(1));  // reset freq
~synth.set(\refFreq, ~refFreq * 2.pow(2));
~synth.set(\refFreq, ~refFreq * 2.pow(3));

~synth.free;





// ... now try with PlayBuf source
(
~ugenGraphFuncs = ~divs.collect({ |div|

	(div == 1).if({
		{ |refFreq = 440.0, minRefFreq = 20.0, gain = -12.0, playBufnum = 0|  // pass for mul == 1
			var numChannels = 1, loop = 1;

			gain.dbamp * PlayBuf.ar(
				numChannels,
				playBufnum,
				rate: BufRateScale.kr(playBufnum),
				loop: loop
			)
		}
	},
	{
		{ |refFreq = 440.0, minRefFreq = 20.0, gain = -12.0, playBufnum = 0|  // otherwise comb filter
			var in;
			var size = 4096;
			var padFac = 1 - (2 / div);
			var tableBuffer = LocalBuf.newFrom(~hannPadWindowFunc.value(size, padFac).asWavetable);
			// var normFac = 1.0;  // no scaling - maintains waveform peak
			var normFac = div.sqrt;  // maintains power (rms)
			// var normFac = div;  // maintains original harmonic gain
			var numChannels = 1, loop = 1;

			in = gain.dbamp * PlayBuf.ar(
				numChannels,
				playBufnum,
				rate: BufRateScale.kr(playBufnum),
				loop: loop
			);

			in * Osc.ar(tableBuffer, refFreq / div, mul: normFac)
		}
	})
})
);


// tones at A 440Hz...
~path = "/Users/joanders/Desktop/philharmonia/Brass/french horn/french-horn_A4_very-long_cresc-decresc_normal.mp3";
~path = "/Users/joanders/Desktop/philharmonia/Strings/violin/violin_A4_very-long_decrescendo_arco-normal.mp3";
~path = "/Users/joanders/Desktop/philharmonia/Woodwind/saxophone/saxophone_A4_very-long_cresc-decresc_normal.mp3";

~path = "/Users/joanders/Desktop/philharmonia/Strings/violin/violin_A4_very-long_crescendo_arco-normal.mp3";
~path = "/Users/joanders/Desktop/philharmonia/Woodwind/flute/flute_A4_very-long_cresc-decresc_normal.mp3";
~path = "/Users/joanders/Desktop/philharmonia/Strings/mandolin/mandolin_A4_very-long_forte_tremolo.mp3";


~sndbuf = CtkBuffer.playbuf(~path);
~sndbuf.load;
~sndbuf.free;


~refFreq = 440.0;

// play
~synth = ~ugenGraphFuncs.at(1 - 1).play;  // div 1
~synth = ~ugenGraphFuncs.at(2 - 1).play;  // div 2
~synth = ~ugenGraphFuncs.at(4 - 1).play;  // div 4
~synth = ~ugenGraphFuncs.at(8 - 1).play;  // div 8

~synth = ~ugenGraphFuncs.at(3 - 1).play;  // div 3
~synth = ~ugenGraphFuncs.at(5 - 1).play;  // div 5
~synth = ~ugenGraphFuncs.at(6 - 1).play;  // div 6
~synth = ~ugenGraphFuncs.at(7 - 1).play;  // div 7


~synth.free;

~synth.set(\gain, 0.0);
~synth.set(\gain, 6.0);
~synth.set(\gain, 9.0);
~synth.set(\gain, 12.0);
~synth.set(\gain, 15.0);


~synth.set(\refFreq, 429.7);  // sax is a bit flat!!
~synth.set(\refFreq, 433.4);  // as is flute!!
~synth.set(\refFreq, 437.3);  // as is french horn!!
~synth.set(\refFreq, 440.0);  // nominal
~synth.set(\refFreq, 446.7);  // better for violin w/ vibrato?

~synth.free;
