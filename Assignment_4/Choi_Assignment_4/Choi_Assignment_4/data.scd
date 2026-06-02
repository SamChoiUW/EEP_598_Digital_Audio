/*
Project Title: Assignment 4
Date: Mon May 11 15:33:36 2026

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


// -------------------------
// instantiate dictionaries


// -------------------------
// add associations
~vowels = Dictionary[
    \a -> (freq: [800,  1150, 2900, 3900, 4950],
           bw:[80,   90,  120,  130,  140],
           amp: [1.0,  0.6,  0.3,  0.1,  0.1]),

    \e -> (freq: [350,  2000, 2800, 3600, 4950],
           bw:[60,  100,  120,  150,  200],
           amp: [1.0,  0.7,  0.5,  0.2,  0.1]),

    \i -> (freq: [270,  2140, 2950, 3900, 4950],
           bw:[60,   90,  100,  120,  120],
           amp: [1.0,  0.4,  0.3,  0.1,  0.1]),

    \o -> (freq: [450,   800, 2830, 3800, 4950],
           bw:[70,   80,  100,  130,  135],
           amp: [1.0,  0.9,  0.3,  0.1,  0.1]),

    \u -> (freq: [325,   700, 2700, 3800, 4950],
           bw:[50,   60,  170,  180,  200],
           amp: [1.0,  0.8,  0.1,  0.1,  0.1]),
];