/*
Project Title: projectSimpleAS
Date: Tue Apr 14 13:28:42 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
Example of Additive Synthesis via a scoring function

*/

// post project files & folders
(
    "Files & folders in this project:\n".postln;
    PathName.new(
        Document.current.dir
    ).streamTree(Post, 1);
    "".postln
);
  