/*
Project Title: Assignment 3b
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

	/*
	TODO:

	• ratio 15:16 --> \eep598_monoPlayBuf_downUp_15_16
	• ratio 5:6 --> \eep598_monoPlayBuf_downUp_5_6
	• ratio 3:4 --> \eep598_monoPlayBuf_downUp_3_4
	• ratio 2:3 --> \eep598_monoPlayBuf_downUp_2_3
	• ratio 5:8 --> \eep598_monoPlayBuf_downUp_5_8
	• ratio 9:16 --> \eep598_monoPlayBuf_downUp_9_16
	*/

	// 1:2 - do
	// semi-degenerate ratio, e.g., just frequency divide
	SynthDef.new(
		\eep598_monoPlayBuf_downUp_1_2,  // name - as Symbol

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
			var div = 2;  // frequency division ratio
			var size = 4096;
			var padFac = 1 - (2 / div);
			var tableBuffer = LocalBuf.newFrom(~myWindowFuncs[\hannPadWindowFunc].value(size, padFac).asWavetable);
			var normFac = div.sqrt;  // maintains power (rms)


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

			// transposition - just divide!
			transSig = playBufSig * Osc.ar(tableBuffer, refFreq / div, mul: normFac);

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

	• ratio 15:16 --> \eep598_monoPlayBuf_downUp_15_16
	• ratio 5:6 --> \eep598_monoPlayBuf_downUp_5_6
	• ratio 3:4 --> \eep598_monoPlayBuf_downUp_3_4
	• ratio 2:3 --> \eep598_monoPlayBuf_downUp_2_3
	• ratio 5:8 --> \eep598_monoPlayBuf_downUp_5_8
	• ratio 9:16 --> \eep598_monoPlayBuf_downUp_9_16
	*/

	// 1:2 - do
	// semi-degenerate ratio, e.g., just frequency divide
	SynthDef.new(
		\eep598_monoPlayBuf_upDown_1_2,  // name - as Symbol

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
			var div = 2;  // frequency division ratio
			var size = 4096;
			var padFac = 1 - (2 / div);
			var tableBuffer = LocalBuf.newFrom(~myWindowFuncs[\hannPadWindowFunc].value(size, padFac).asWavetable);
			var normFac = div.sqrt;  // maintains power (rms)


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

			// transposition - just divide!
			transSig = playBufSig * Osc.ar(tableBuffer, refFreq / div, mul: normFac);

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
