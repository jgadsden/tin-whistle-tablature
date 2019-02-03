# tin-whistle-tablature
MuseScore plugin to add tablature (fingering) diagrams to a tin whistle staff in a score

This provides a plugin to automatically add fingering / tab diagrams to the notes in scores for tin whistle. The version for MuseScore 2 will adjust for tin whistles tuned to D, C and Bb, the version for MuseScore 3 does not do this and assumes a tin whistle tuned to D.

This plugin relies on a font being installed, which is not included in this download but can be obtained from Blayne Chastain's site:

https://www.blaynechastain.com/wp-content/uploads/TinWhistleTab.zip

To install the font it is usually just a case of double-clicking the downloaded .ttf file and agreeing to the install process. If that does not work then on linux systems try copying the TinWhistleTab.ttf font file to /usr/share/fonts/truetype/.

There are two versions of this plugin. One for MuseScore 2.x on a branch 'version2' and the other for Musecore 3.x which is on the master branch.

The version for MuseScore 2 will check that the staff is for  a tin whistle and adjust the tab diagram position for the lowest note possible. I have not been able to repeat this for MuseScore 3 so it just assumes that a whistle tuned to D is used - this being the most common.

Version for MuseScore 2.x : https://github.com/jgadsden/tin-whistle-tablature/archive/version2.zip

Version for MuseScore 3.x : https://github.com/jgadsden/tin-whistle-tablature/archive/master.zip

# Installation

To use the plugin first install it according to the instructions in the:
* 2.x Handbook https://musescore.org/en/handbook/plugins#installation

or the
* 3.x Handbook https://musescore.org/en/handbook/3/plugins#installation
