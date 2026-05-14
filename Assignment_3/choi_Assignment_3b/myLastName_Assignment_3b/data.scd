/*
Project Title: Assignment 3b
Date: Mon May  4 13:52:09 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
data here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/

// source path
~path = "/Users/joanders/Desktop/philharmonia/Brass/french horn/french-horn_A2_05_fortissimo_normal.mp3";


// header details - for sampleRate!
~soundFile = SoundFile.new(~path);
~soundFile.openRead;
~soundFile.close;
~sampleRate = ~soundFile.sampleRate;

// read the complete signal
~signal = Signal.read(~path);

// estimate freq
~skipTime = 0.352;
~freq = 111.0;  // guesstimate
~order = 2;  // number of periods to average - could do less, or more!

// returns estimated frequency & correlation
~freqCorr = ~signal.estimateFreq(~skipTime * ~sampleRate , ~freq, order: ~order, sampleRate: ~sampleRate );


// -------------------------
// instantiate dictionaries


// -------------------------
// add associations

