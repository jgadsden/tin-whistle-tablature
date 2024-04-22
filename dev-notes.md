There are three branches for this plugin in the code [repository][repo]:

* MuseScore 2.x is on branch 'version2'
* MuseScore 3.x is on branch 'version3'
* the 'main' branch is for MuseScore 4.x

Note that the instrument ID changed for version 4.0.x and then changed back again for 4.1

### test

* Load the plugin and makes sure the Plugin Manager can enable/disable it
* MuseScore 4.x onwards removed the Plugin Creator tool,
    so if you want console logs then run MuseScore itself from command line
* Apply tabs to the range test examples, all staves should have the same tabs:
  * whistle range test: `examples/tin_whistle_range_test.mscz`
  * low whistle range test: `examples/low_whistle_range_test.mscz`

### release

There are _two_ release areas, MuseScore community and also github repo release

#### github release

* Make sure to update the version of the plugin, for example `version: "4.1"`
* Go to 'Releases' area and 'Draft a new release'
* 'Choose a tag' along the lines of `v4.1` on target branch `main`
* 'Release title' something like `v4.1 for MuseScore 4`
* Add files:
  * Font file `TinWhistleTab.ttf`
  * Plugin file: `tin_whistle_tablature.qml`
  * Whistle instrument file: `all-whistles-v4.xml`
* Set as the latest release
* Add the release notes along the lines of:

```text
Version 4.1 Tin Whistle plugin tested on MuseScore 4 v4.1.0

Plugin file: `tin_whistle_tablature.qml`
Whistle instrument file: `all-whistles-v4.xml`

Note that this is may not be compatible with earlier versions of [MuseScore 3][ms3]
and [MuseScore 2][ms2] - use the previous releases for those.

A font file `TinWhistleTab.ttf` is attached for convenience from Blayne Chastain and states:

_Tin Whistle Tab font is free of charge for both personal and commercial use. Distribution for a fee is not allowed._
_Please credit Blayne Chastain in any publication in which this font appears with the following copyright notice:_
_"Tin Whistle Tab font © Blayne Chastain / [www.blaynechastain.com][bc]"_

[bc]: http://www.blaynechastain.com/
[ms2]: https://github.com/jgadsden/tin-whistle-tablature/releases/tag/v2.3.2
[ms3]: https://github.com/jgadsden/tin-whistle-tablature/releases/tag/v3.4
```

When all is good then publish the release, it can always be edited at a later date

#### MuseScore community release

* Login to [MuseScore community][login] and access plugin from [plugins download area][plugins]
* Or login direct to ['Tin Whistle Tablature' project][project]
* Choose 'Edit' from the 3 dots menu (vertical ellipsis)
* Remove the files that are about to change, for example `tin_whistle_tablature_v4.qml`
* Prepare the new file name, for example `tin_whistle_tablature_v4.qml` copied from `tin_whistle_tablature.qml`
* Upload the new file and provide a description such as 'Tin Whistle Tablature Plugin for MuseScore Versions 4.0 and above'
* Preview and then Save

[login]: https://musescore.com/user/login
[plugins]: https://musescore.org/en/plugins
[repo]: https://github.com/jgadsden/tin-whistle-tablature/
[project]: https://musescore.org/en/project/tin-whistle-tablature
