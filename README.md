# tin-whistle-tablature

MuseScore plugin to add tablature (fingering) diagrams to a tin whistle staff in a score

This provides a plugin to automatically add fingering / tab diagrams to the notes in scores for tin whistle. The plugin will adjust for tin whistles tuned to D, C and Bb, according to the instrument defined for each staff. Note that if the instrument is not a whistle then no tabs are applied, otherwise the plugin will adjust the tab diagram position for the lowest note possible (currently D, C or Bb).

This plugin relies on a font being installed, which is not included in this download but can be obtained from Blayne Chastain's site:

https://www.blaynechastain.com/wp-content/uploads/TinWhistleTab.zip

To install the font it is usually just a case of double-clicking the downloaded .ttf file and agreeing to the install process. If that does not work then on linux systems try copying the TinWhistleTab.ttf font file to /usr/share/fonts/truetype/.

# Installation
Download plugin for MuseScore 2.x : https://github.com/jgadsden/tin-whistle-tablature/archive/version2.zip

To use the plugin first install it according to the instructions in the MuseScore 2.x Handbook https://musescore.org/en/handbook/plugins#installation
