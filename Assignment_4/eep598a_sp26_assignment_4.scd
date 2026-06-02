/*
Project Title: Assignment 4
Date: Mon May 11 15:33:36 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
Assignment 4

Implement, demonstrate and describe a sound synthesis or signal processing technique as a SynthDef,
or collection of SynthDefs. Source this algorithm from (any of) the listed texts.†

Observe the procedures, guidelines and style found in:
• Function: -play to SynthDef: *new
• Flowchart to SynthDef: *new

Algorithms are often illustrated in a condensed, basic form. Appropriately expand the network for
real-world deployment. E.g., include amplitude and other parameter envelopes; include stereo synthesis
techniques, etc.

In your SCD project and demonstration, illustrate a suitable range of results the given algorithm may return.



†See list at bottom of this page. A number of techniques will be reviewed in multiple texts.
If so, include this in your discussion, and / or implementation.

*/

/*
Start by downloading the resource found on the Canvas link for Assignment 4:

• myLastName_assignment_4

*/

/*
Unzip myLastName_Assignment_4 and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

*/

/*
Deliverables:

- SCD project folder

- _two_ network flow graphs
-- core algorithm(s)
-- synthDef implementation

- 500 word overview of technique / implementation
-- cite source(s)

- (in person) presentation: Jun 12, 4:30pm - 6:20pm
-- discussion
-- demonstration
-- question(s)

*/


/*
--------
primary texts

Dodge, C., & Jerse, T. A. (1997). Computer music : synthesis, composition, and performance (Second edition.). Schirmer Books.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99111315690001452
[ Canvas link ]

Zölzer, U. (2011). DAFX : digital audio effects (2nd ed.). Wiley.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99162157562101452

Lazzarini, V. (2021). Spectral music design : a computational approach. Oxford University Press.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99332146771101451


----------
secondary texts

Puckette, M. (2007). The theory and technique of electronic music. World Scientific Publishing Co.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99146849280001452
[ online link ]

Roads, C., & Strawn, J. (1995). The computer music tutorial. MIT Press.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99148512600001452

Roads, C., & Strawn, J. (Eds.). (1985). Foundations of computer music. MIT Press.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99111183150001452

Moore, F. R. (1990). Elements of computer music. Prentice Hall.
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99107032490001452

Risset, J.-C. (1969). An Introductory Catalogue of Computer Synthesized Sounds. Murray Hill, New Jersey: Bell Laboratories.
https://archive.org/details/an-introductory-catalogue-of-computer-synthesized-sounds

Computer music journal. (1977).
https://orbiscascade-washington.primo.exlibrisgroup.com/permalink/01ALLIANCE_UW/6psp7h/alma99157819390001452

*/