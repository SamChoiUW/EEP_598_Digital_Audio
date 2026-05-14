/*
Project Title: Assignment 3a
Date: Mon May  4 13:52:09 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")
*/


// -------------------------
// instantiate CtkProtoNotes
~myPlayBufTransPNotes = CtkProtoNotes.new;  // protoNote dict for playing soundfiles


// -------------------------
// add synthDefs

~myPlayBufTransPNotes.add(

	/*
	Enveloped mono PlayBufs - Time Domain Transposition
	*/

	// ---------------------------------------------------------------------------------------------
	/*
	_downUp, where the "downward" integer frequency transposition occurs first, followed by the "upward" transposition.
	*/

	// 1:1 - do
	// degenerate ratio, e.g., just playback!
	SynthDef.new(
		\eep598_monoPlayBuf_downUp_1_1,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, refFreq = 440.0, minRefFreq = 20.0, panAngle = 0,
			bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
			var transSig;
            var panSig;
            var outSig;

            // vars for control
			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// vars for transposition
			// - multiplication
			var mul = 1;  // frequency multiplication ratio... degenerate, i.e., do nothing!

			// - division
			var div = 1;  // frequency division ratio... degenerate, i.e., do nothing!


			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum));

			// transposition - degenerate, i.e., do nothing!
			transSig = playBufSig;

			// apply -linen envelope
			transSig = transSig * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(transSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	),


	SynthDef.new(
		\eep598_monoPlayBuf_downUp_9_8,  // name - as Symbol
{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, refFreq = 440.0, minRefFreq = 20.0, panAngle = 0,
			bufnum = 0, outBus = 0|

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
			var transSigMul;
			var transSigDiv;
            var panSig;
            var outSig;

            // vars for control

			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// vars for transposition
			// - multiplication
			var mul = 9;  // frequency multiplication ratio
			var minFreq = mul * minRefFreq, freq = mul * refFreq;
			var order = mul - 1;

			// - division
			var div = 8;  // frequency division ratio
			var normFac = div.sqrt;  // maintains power (rms)
			var size = 4096;
			var padFac = 1 - (2 / div);
			var tableBuffer = LocalBuf.newFrom(~myUgenHelperFuncs[\hannPadWindowFunc].value(size, padFac).asWavetable);

			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)


			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum));
			// time domain transpose one
			transSigDiv = playBufSig * Osc.ar(tableBuffer, refFreq / div, mul: normFac);
			transSigMul = ~myUGenHelperFuncs[\maCombFunc].value(transSigDiv, minFreq, freq, order, order);

			// apply -linen envelope
			transSigMul = transSigMul * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(transSigMul, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	),


	/*
	TODO:

	• ratio 9:8 --> \eep598_monoPlayBuf_downUp_9_8
	• ratio 5:4 --> \eep598_monoPlayBuf_downUp_5_4
	• ratio 4:3 --> \eep598_monoPlayBuf_downUp_4_3
	• ratio 3:2 --> \eep598_monoPlayBuf_downUp_3_2
	• ratio 5:3 --> \eep598_monoPlayBuf_downUp_5_3
	• ratio 15:8 --> \eep598_monoPlayBuf_downUp_15_8
	*/

	// 2:1 - do
	// semi-degenerate ratio, e.g., just frequency multiply
	SynthDef.new(
		\eep598_monoPlayBuf_downUp_2_1,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, refFreq = 440.0, minRefFreq = 20.0, panAngle = 0,
			bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
			var transSig;
            var panSig;
            var outSig;

            // vars for control
			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// vars for transposition
			// - multiplication
			var mul = 2;  // frequency multiplication ratio
			var minFreq = mul * minRefFreq, freq = mul * refFreq;
			var order = mul - 1;

			// - division
			var div = 1;  // frequency division ratio... degenerate, i.e., do nothing!


			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum));

			// time domain transpose - just multiply!
			transSig = ~myUGenHelperFuncs[\maCombFunc].value(playBufSig, minFreq, freq, order, order);

			// apply -linen envelope
			transSig = transSig * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(transSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	),



	// ---------------------------------------------------------------------------------------------
	/*
	_upDown, where the "upward" integer transposition takes place first, followed by the "downward".
	*/

	// 1:1 - do
	// degenerate ratio, e.g., just playback!
	SynthDef.new(
		\eep598_monoPlayBuf_upDown_1_1,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, refFreq = 440.0, minRefFreq = 20.0, panAngle = 0,
			bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
			var transSig;
            var panSig;
            var outSig;

            // vars for control
			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// vars for transposition
			// - multiplication
			var mul = 1;  // frequency multiplication ratio... degenerate, i.e., do nothing!

			// - division
			var div = 1;  // frequency division ratio... degenerate, i.e., do nothing!


			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum));

			// transposition - degenerate, i.e., do nothing!
			transSig = playBufSig;

			// apply -linen envelope
			transSig = transSig * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(transSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	),

	/*
	TODO:

	• ratio 9:8 --> \eep598_monoPlayBuf_upDown_9_8
	• ratio 5:4 --> \eep598_monoPlayBuf_upDown_5_4
	• ratio 4:3 --> \eep598_monoPlayBuf_upDown_4_3
	• ratio 3:2 --> \eep598_monoPlayBuf_upDown_3_2
	• ratio 5:3 --> \eep598_monoPlayBuf_upDown_5_3
	• ratio 15:8 --> \eep598_monoPlayBuf_upDown_15_8
	*/

	// 2:1 - do
	// semi-degenerate ratio, e.g., just frequency multiply
	SynthDef.new(
		\eep598_monoPlayBuf_upDown_2_1,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, refFreq = 440.0, minRefFreq = 20.0, panAngle = 0,
			bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
			var transSig;
            var panSig;
            var outSig;

            // vars for control
			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// vars for transposition
			// - multiplication
			var mul = 2;  // frequency multiplication ratio
			var minFreq = mul * minRefFreq, freq = mul * refFreq;
			var order = mul - 1;

			// - division
			var div = 1;  // frequency division ratio... degenerate, i.e., do nothing!


			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum));

			// time domain transpose - just multiply!
			transSig = ~myUGenHelperFuncs[\maCombFunc].value(playBufSig, minFreq, freq, order, order);

			// apply -linen envelope
			transSig = transSig * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(transSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);
