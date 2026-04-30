/*
Project Title: projectSharcWTsWPs
Date: Tue Apr 21 13:31:32 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
This project illustrates Wavetable and WavePacket Synthesis. The wavetables and wave packets
are designed from SHARC spectral data recorded in data.scd. Once designed, these are loaded on
the server for synthesis. By generating the same pitch sequence, we're able to directly compare
the results of these two synthesis methods.


Let's start by reviewing this project structure.

Evaluate the codeblock in parentheses directly below:
*/

// post project files & folders
(
"Files & folders in this project:\n".postln;
PathName.new(
    Document.current.dir
).streamTree(Post, 1);
"".postln
);

/*
Project files and folders posted in the Post window.

*/

/*
Our primary focus will be exploring the files named _scratchPad_ and _main_

open: scratchPad.scd, main.scd
*/
(
// a function does the job...
{
    var fileNames = [ "scratchPad.scd", "main.scd" ];
    
    PathName.new(Document.current.dir).filesDo({ |pathName|
        fileNames.asSet.includes(
            pathName.fileName
        ).if({
            Document.open(pathName.fullPath)
        });
    });
    
    // return to this document
    Document.current.front
}.value
);

// now... review / explore _scratchPad_
/*
Navigate to _scratchPad_ via SC-IDE...

... when finished, return to this file, _readme_.
*/


/*
Presumably, we've just returned from exploring _scratchPad_
*/


// now... review / explore _main_
/*
Navigate to _main_ via SC-IDE...

... when finished, return to this file, _readme_.
*/

/*
Presumably, we've just returned from exploring _main_

If we've just rendered ~mainScore, we'll now see the rendered file in the _sounds_ folder:
*/

// post project files & folders
(
"Files & folders in this project:\n".postln;
PathName.new(
    Document.current.dir
).streamTree(Post, 1);
"".postln
);
  