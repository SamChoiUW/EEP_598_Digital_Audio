/*
Project Title: myLasName Assignment 1b
Date: Sun Mar 29 16:35:26 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
DESCRIBE project here

See notes found in eep598a_sp26_assignment_1b.scd

*/

// post project files & folders
(
	"Files & folders in this project:\n".postln;
	PathName.new(
		Document.current.dir
	).streamTree(Post, 1);
	"".postln
);