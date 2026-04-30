/*
Project Title: projectSimpleWS
Date: Tue Apr 21 11:25:12 2026

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
~myDodgeJersePNotes = CtkProtoNotes.new;


// -------------------------
// add synthDefs

/*
HelpBrowser.openLink("link::Tutorials/Getting Going/WTOscs#Osc::")
HelpBrowser.openLink("link::Tutorials/Getting Started/FlowchartToSynthDef#... now, make it Ours!::")
*/
~myDodgeJersePNotes.add(

	// 1st kind waveshaping - sum of cosines
	//
    // similar to Dodge & Jerse, Figure 5.19
	// - _amplitude_ AND _index of modulation_ use same envelope
	// - single waveshaping table --> -chebyTFill
	// - requires one cosine oscillator
    /*
    Dodge, C., & Jerse, T. A. (1997). Computer music: synthesis, composition, and performance (Second edition.). Schirmer Books.
    */
    SynthDef.new(
        \dxarts46x_dodgeJerse_fig_5_19_like_1st_kind,  // name - as Symbol

        { |dur = 1.0, gain = -14.0, riseTime = 0.1, decayTime = 0.1, freq = 440.0, modIndex = 1.0, panAngle = 0, bufnumT = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var envSig;
            var cosSig;
			var shapeSig;
            var panSig;
            var outSig;

            // vars for control
            var phase = 0.5pi;
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;


            // ----
            // synthesis

            // modulation AND amplitude envelope - scaled 0.0 - 1.0
            envSig = EnvGen.kr(
                Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
                doneAction: Done.freeSelf
            );  // EnvGen (control rate)

            // cosine oscillator
			// NOTE: envSig is applied 2x to further avoid (DC) clicks
            cosSig = SinOsc.ar(freq, phase, modIndex * envSig.sqrt);  // Osc (audio rate)

			// waveshaper
			shapeSig = Shaper.ar(bufnumT, cosSig);  // chebyT

			// remove DC
			shapeSig = LeakDC.ar(shapeSig);

			// amplitude envelope
			// NOTE: envSig is applied 2x to further avoid (DC) clicks
			shapeSig = (amp / modIndex * envSig.sqrt) * shapeSig;

            // stereo imager
            panSig = Pan2.ar(shapeSig, pos);  // Pan2 (audio rate)

            // assign to out
            outSig = panSig;

            Out.ar(
                outBus,  // out bus - set as an argument
                outSig
            )  // Out (audio rate)
        }
    )
);


~myDodgeJersePNotes.add(

	// 2nd kind waveshaping - sum of sines
	//
    // similar to Dodge & Jerse, Figure 5.19 (and Figure 5.30, due to required ring modulation!)
	// - _amplitude_ AND _index of modulation_ use same envelope
	// - single waveshaping table --> -chebyUFill
	// - requires two oscillators: cosine, sine
    /*
    Dodge, C., & Jerse, T. A. (1997). Computer music: synthesis, composition, and performance (Second edition.). Schirmer Books.
    */
    SynthDef.new(
        \dxarts46x_dodgeJerse_fig_5_19_like_2nd_kind,  // name - as Symbol

        { |dur = 1.0, gain = -14.0, riseTime = 0.1, decayTime = 0.1, freq = 440.0, modIndex = 1.0, panAngle = 0, bufnumU = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var envSig;
            var quadOsc;
			var shapeSig;
            var panSig;
            var outSig;

            // vars for control
            var phase = [ 0.5pi, 0.0 ];  // quadrature: cosine & sine
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;


            // ----
            // synthesis

            // modulation AND amplitude envelope - scaled 0.0 - 1.0
            envSig = EnvGen.kr(
                Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
                doneAction: Done.freeSelf
            );  // EnvGen (control rate)

			// quadrature oscillators [cosine, sine]
			// NOTE: envSig is applied 2x to further avoid (DC) clicks
			quadOsc = SinOsc.ar(freq, phase, modIndex * envSig.sqrt);  // Osc (audio rate)

			// waveshaper
			shapeSig = Shaper.ar(bufnumU, quadOsc[0], quadOsc[1]);  // chebyU

			// remove DC
			shapeSig = LeakDC.ar(shapeSig);

			// amplitude envelope
			// NOTE: envSig is applied 2x to further avoid (DC) clicks
			shapeSig = (amp / modIndex * envSig.sqrt) * shapeSig;

            // stereo imager
            panSig = Pan2.ar(shapeSig, pos);  // Pan2 (audio rate)

            // assign to out
            outSig = panSig;

            Out.ar(
                outBus,  // out bus - set as an argument
                outSig
            )  // Out (audio rate)
        }
    )
);


~myDodgeJersePNotes.add(

	// 3rd kind waveshaping - sum of cosines & sines
	//
    // similar to Dodge & Jerse, Figure 5.19 (and Figure 5.30, due to required ring modulation!)
	// - _amplitude_ AND _index of modulation_ use same envelope
	// - dual waveshaping tables --> -chebyTFill, -chebyUFill
	// - requires two oscillators: cosine, sine
    /*
    Dodge, C., & Jerse, T. A. (1997). Computer music: synthesis, composition, and performance (Second edition.). Schirmer Books.
    */
	SynthDef.new(
		\dxarts46x_dodgeJerse_fig_5_19_like_3rd_kind,  // name - as Symbol

		{ |dur = 1.0, gain = -14.0, riseTime = 0.1, decayTime = 0.1, freq = 440.0, modIndex = 1.0, panAngle = 0, bufnumT = 0, bufnumU = 1, outBus = 0|  // UGen graph function

			// vars for UGens
			var envSig;
			var quadOsc;
			var shapeSig;
			var panSig;
			var outSig;

			// vars for control
			var phase = [ 0.5pi, 0.0 ];  // quadrature: cosine & sine
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;


			// ----
			// synthesis

			// modulation AND amplitude envelope - scaled 0.0 - 1.0
			envSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// quadrature oscillators [cosine, sine]
			// NOTE: envSig is applied 2x to further avoid (DC) clicks
			quadOsc = SinOsc.ar(freq, phase, modIndex * envSig.sqrt);  // Osc (audio rate)

			// waveshaper
			shapeSig = Shaper.ar(bufnumT, quadOsc[0]) + Shaper.ar(bufnumU, quadOsc[0], quadOsc[1]);  // chebyT & chebyU

			// remove DC
			shapeSig = LeakDC.ar(shapeSig);

			// amplitude envelope
			// NOTE: envSig is applied 2x to further avoid (DC) clicks
			shapeSig = (amp / modIndex * envSig.sqrt) * shapeSig;

			// stereo imager
			panSig = Pan2.ar(shapeSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);
