/*
Project Title: Choi Assignment 3c
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
	Implement implement a single synthDef similar to those found in Assignment 3a, but where
	the transposition is synthesized through the use of PitchShiftPA.

	As well as _refFreq_ and _minRefFreq_, expose _pitchRatio_ and _formantRatio_ as synthDef
	arguments.
	*/

	SynthDef.new(
		\eep598_monoPlayBuf,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, refFreq = 440.0, minRefFreq = 20.0,pitchRatio = 1, formantRatio = 1, panAngle = 0,
			bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
			var transSig;
            var panSig;
            var outSig;

            // vars for control
			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
			var loop = 1;
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;



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
			transSig = PitchShiftPA.ar(playBufSig, refFreq, pitchRatio, formantRatio);

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
