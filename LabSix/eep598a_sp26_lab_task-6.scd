/*
Title: labTask6
Date: Thu May  7 14:22:46 2026

EE P 598a - Sp26
Authors: Joseph Anderson
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
Review:

• hannDivisions.scd
• combMultiplications.scd

*/

/*
Create _two_ UGen graph functions (ala, Function:-play) that will return
a 3:2 frequency transposition of a soundfile played via PlayBuf.


Implement the first as frequency division followed by frequency multiplication (_downUp),
and the second as frequency multiplication followed by frequency division (_upDown).


Audition the results using a soundfile drawn from the London Philharmonia archive:
https://philharmonia.co.uk/resources/sound-samples/

*/

/*
You may also like to review the frequency transposition implementations found in:

• myLastName_Assignment_3a
• myLastName_Assignment_3b

*/

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


(
~hannPadWindowFunc = { |size = 4096, padFac = 0|
	Signal.hannWindow(
		size,
		(size * padFac).asInteger
	)
}
);

~ugen_downUp = {|refFreq = 440.0, minRefFreq = 20.0, gain = -12.0, playBufnum = 0, mul = 3, div = 2|
	var in;
	var size = 4096;
	var padFac = 1 - (2 / div);
	var tableBuffer = LocalBuf.newFrom(~hannPadWindowFunc.value(size, padFac).asWavetable);
	// var normFac = 1.0;  // no scaling - maintains waveform peak
	var normFac = div.sqrt;  // maintains power (rms)
	// var normFac = div;  // maintains original harmonic gain
	var numChannels = 1, loop = 1;

	var minFreq = mul * minRefFreq, freq = mul * refFreq;
	var order = mul - 1;

	var divided,multiplied;

	in = gain.dbamp * PlayBuf.ar(
		numChannels,
		playBufnum,
		rate: BufRateScale.kr(playBufnum),
		loop: loop
	);
	divided = in * Osc.ar(tableBuffer, refFreq / div, mul: normFac);
	multiplied = ~maCombFunc.value(divided, minFreq, freq, order, order);

}

~ugen_upDown = {|refFreq = 440.0, minRefFreq = 20.0, gain = -12.0, playBufnum = 0, mul = 3, div = 2|
	var in;
	var size = 4096;
	var padFac = 1 - (2 / div);
	var tableBuffer = LocalBuf.newFrom(~hannPadWindowFunc.value(size, padFac).asWavetable);
	// var normFac = 1.0;  // no scaling - maintains waveform peak
	var normFac = div.sqrt;  // maintains power (rms)
	// var normFac = div;  // maintains original harmonic gain
	var numChannels = 1, loop = 1;

	var minFreq = mul * minRefFreq, freq = mul * refFreq;
	var order = mul - 1;

	var divided,multiplied;

	in = gain.dbamp * PlayBuf.ar(
		numChannels,
		playBufnum,
		rate: BufRateScale.kr(playBufnum),
		loop: loop
	);

	multiplied = ~maCombFunc.value(in, minFreq, freq, order, order);
	divided = multiplied * Osc.ar(tableBuffer, refFreq / div, mul: normFac);

}



// tones at A 440Hz...
~path = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/LPO_SOUNDS/french horn/french-horn_A4_very-long_cresc-decresc_normal.mp3";
~path = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/LPO_SOUNDS/violin/violin_A4_very-long_decrescendo_arco-normal.mp3";
~path = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/LPO_SOUNDS/saxophone/saxophone_A4_very-long_cresc-decresc_normal.mp3";
~path = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/LPO_SOUNDS/violin/violin_A4_very-long_crescendo_arco-normal.mp3";
~path = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/LPO_SOUNDS/flute/flute_A4_very-long_cresc-decresc_normal.mp3";
~path = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/LPO_SOUNDS/mandolin/mandolin_A4_very-long_forte_tremolo.mp3";
"banjo"

~path = "/home/roux/Documents/temp.mp3"
~sndbuf = CtkBuffer.playbuf(~path);
~sndbuf.load;
~sndbuf.free;


~refFreq = 440.0;

// play
~synth = ~ugen_downUp.play;  // div 1
~synth = ~ugen_upDown.play;  // div 1


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
