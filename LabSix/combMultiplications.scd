/*
Title: combMultiplications
Date: Wed Apr 29 15:25:25 2026

EE P 598a - Sp26
Authors: Joseph Anderson
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/


/*
for integer ratio "multiplications" of the fundamental frequency of a periodic signal,
we can comb filter to _select_ harmonic partials of the desired ratio (of the fundamental)

the "moving average" comb filter is well suited for this task


we'll have two args to consider:
- freq: the comb's fundamental frequency
- order: the number of periods averaged

*/

/*
let's design a function for that will return a moving average comb filter

NOTE: we could add this to SuperCollider as a Pseudo-UGen

HelpBrowser.openLink("link::Guides/WritingUGens#Pseudo-UGens::")
*/

// make the args similar to CombAZC... which is actually a 1st order moving average comb!
(
~maCombFunc = { |in = 0.0, minFreq = 20.0, freq = 440.0, order = 1, mul = 1.0, add = 0.0|
	var maxDelayTime = minFreq.reciprocal, delayTime = freq.reciprocal;
	var normFac = order.reciprocal;
	var delay, comb;

	// initialize
	comb = normFac * Array.with(in, in);

	// cascade
	order.do({
		delay = DelayC.ar(comb.at(1), maxDelayTime, delayTime);  // cubic interpolation
		comb = Array.with(
			comb.at(0) + delay,
			delay
		)
	});

	comb.at(0).madd(mul, add)
}
);


/*
to "multiply" the fundamental frequency by an iteger ratio, we'll set the comb filter args

- freq = ratio * freq
- order = ratio - 1

*/


/*
let's collect ugenGraphs by multiply ratio to try this out....

*/

~numMuls = 8;
~muls = Array.series(~numMuls, 1);  // fundamental frequnecy multiply ratios

// ... test with Saw source, first
(
~ugenGraphFuncs = ~muls.collect({ |mul|

	(mul == 1).if({
		{ |refFreq = 440.0, minRefFreq = 20.0, gain = -12.0|  // pass for mul == 1

			Saw.ar(refFreq, gain.dbamp)
		}
	}, {
		{ |refFreq = 440.0, minRefFreq = 20.0, gain = -12.0|  // otherwise comb filter
			var in;
			var minFreq = mul * minRefFreq, freq = mul * refFreq;
			var order = mul - 1;

			in = Saw.ar(refFreq, gain.dbamp);

			~maCombFunc.value(in, minFreq, freq, order, order)
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
~synth = ~ugenGraphFuncs.at(1 - 1).play;  // mul 1
~synth = ~ugenGraphFuncs.at(2 - 1).play;  // mul 2
~synth = ~ugenGraphFuncs.at(4 - 1).play;  // mul 4
~synth = ~ugenGraphFuncs.at(8 - 1).play;  // mul 8

~synth.set(\refFreq, ~refFreq);
~synth.set(\refFreq, ~refFreq * 2.pow(-1));  // reset freq
~synth.set(\refFreq, ~refFreq * 2.pow(-2));
~synth.set(\refFreq, ~refFreq * 2.pow(-3));

~synth.free;




// ... now try with PlayBuf source
(
~ugenGraphFuncs = ~muls.collect({ |mul|

	(mul == 1).if({
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
			var minFreq = mul * minRefFreq, freq = mul * refFreq;
			var order = mul - 1;
			var numChannels = 1, loop = 1;

			in = gain.dbamp * PlayBuf.ar(
				numChannels,
				playBufnum,
				rate: BufRateScale.kr(playBufnum),
				loop: loop
			);

			~maCombFunc.value(in, minFreq, freq, order, order)
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
~synth = ~ugenGraphFuncs.at(1 - 1).play;  // mul 1
~synth = ~ugenGraphFuncs.at(2 - 1).play;  // mul 2
~synth = ~ugenGraphFuncs.at(4 - 1).play;  // mul 4
~synth = ~ugenGraphFuncs.at(8 - 1).play;  // mul 8

~synth = ~ugenGraphFuncs.at(3 - 1).play;  // mul 3
~synth = ~ugenGraphFuncs.at(5 - 1).play;  // mul 5
~synth = ~ugenGraphFuncs.at(6 - 1).play;  // mul 6
~synth = ~ugenGraphFuncs.at(7 - 1).play;  // mul 7


~synth.free;

~synth.set(\gain, 0.0, \sndBufnum, ~sndbuf.bufnum);
~synth.set(\gain, -3.0, \sndBufnum, ~sndbuf.bufnum);
~synth.set(\gain, 9.0, \sndBufnum, ~sndbuf.bufnum);
~synth.set(\gain, 12.0, \sndBufnum, ~sndbuf.bufnum);


~synth.set(\refFreq, 429.7);  // sax is a bit flat!!
~synth.set(\refFreq, 433.4);  // as is flute!!
~synth.set(\refFreq, 437.3);  // as is french horn!!
~synth.set(\refFreq, 440.0);  // nominal
~synth.set(\refFreq, 446.7);  // better for violin w/ vibrato?

~synth.free;
