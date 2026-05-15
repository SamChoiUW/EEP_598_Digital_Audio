/*
Project Title: Assignment 3a
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
s.boot;
s.quit;
~dataFolderPath = "/home/roux/Documents/Skoo/EE_P_598_The_Digital_Audio_One/Assignment_3/choi_Assignment_3a/myLastName_Assignment_3a/sounds/trumpet_C4_1_forte_normal.wav".standardizePath;

// 1. Load the mp3 into the buffer
b = Buffer.read(s, ~dataFolderPath);

// 2. Play the buffer to verify it loaded correctly
x = { PlayBuf.ar(1, 0, BufRateScale.kr(b), loop: 1) * 0.5 }.play;
b.free;
x.free;
// -------------------------
// instantiate dictionaries


// -------------------------
// add associations
