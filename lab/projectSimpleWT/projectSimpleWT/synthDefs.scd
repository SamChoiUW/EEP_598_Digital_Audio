/*
Project Title: projectSimpleWT
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

    // VERY similar to Dodge & Jerse, Figure 4.5
    /*
    Dodge, C., & Jerse, T. A. (1997). Computer music: synthesis, composition, and performance (Second edition.). Schirmer Books.
    */
    SynthDef.new(
        \dxarts46x_dodgeJerse_fig_4_5_wavetable,  // name - as Symbol

        { |dur = 1.0, gain = -14.0, riseTime = 0.1, decayTime = 0.1, freq = 440.0, panAngle = 0, bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var wtSig;
            var panSig;
            var outSig;

            // vars for control
            var phase = 0;
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

            // (wavetable) oscillator
            wtSig = Osc.ar(bufnum, freq, phase, ampEnvSig);  // Osc (audio rate)

            // stereo imager
            panSig = Pan2.ar(wtSig, pos);  // Pan2 (audio rate)

            // assign to out
            outSig = panSig;

            Out.ar(
                outBus,  // out bus - set as an argument
                outSig
            )  // Out (audio rate)
        }
    )
);