//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Tin Whistle Tab Plugin
//  Requires the tin whistle font downloaded from Blayne Chastain:
//     https://www.blaynechastain.com/tin-whistle-tab-sibelius-plugin/
//
//  Based on the Note Names Plugin which is:
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013 - 2016 Joachim Schmitz
//  Copyright (C) 2014 Jörn Eichler
//
//  and also based on the Recorder Woodwind Tablature plugin:
//  Copyright (C)2011 Dario Escobedo, Werner Schweer, Jens Iwanenko and others
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import QtQuick.Dialogs 1.1

import MuseScore 3.0

MuseScore {
   version: "3.3"
   description: qsTr("This plugin provides fingering diagrams for the tin whistle. Ensure font `TinWhistleTab.ttf` is installed")
   menuPath: "Plugins.Tin Whistle.Add tablature"

   property var tabFontName: "Tin Whistle Tab"
   property var whistleFound: false

   // The notes from the "Tin Whistle Tab" font, using key of D as standard
   property variant tabs : ["d", "i", "e", "j", "f", "g", "h", "a", "n", "b", "m", "c", "D", "I", "E", "J", "F", "G", "H", "A", "N", "B", "M", "C", '\u00CE']

   MessageDialog {
      id: fontMissingDialog
      icon: StandardIcon.Warning
      standardButtons: StandardButton.Ok
      title: "Missing Tin Whistle Tablature font!"
      text: "The Tin Whistle Tab font is not installed on your device."
      detailedText:  "You can download the font from the web here:\n\n" +
         "https://www.blaynechastain.com/wp-content/uploads/TinWhistleTab.zip\n\n" +
         "The Zip file contains the TinWhistleTab.ttf font file you need to install on your device.\n" +
         "You will also need to restart MuseScore for it to recognize the new font."
      onAccepted: {
         Qt.quit()
      }
   }

   MessageDialog {
      id: noWhistlesFound
      icon: StandardIcon.Warning
      standardButtons: StandardButton.Ok
      title: "No Staffs use a Tin Whistle"
      text: "No selected staff in the current score uses a tin whistle instrument.\n" +
            "Use menu command \"Edit -> Instruments\" to select your instrument."
      onAccepted: {
         Qt.quit()
      }
   }

   function selectTinTabCharacter (pitch, basePitch) {
      var tabText = ""
      var index = pitch - basePitch
      if (index < 0) {
         console.log("Skipped note as it was too low : " + pitch)
         return tabText
      }
      if (index > 24) {
         console.log("Skipped note as it was too high, index : " + pitch)
         return tabText
      }
      tabText = tabs[index]
      return tabText
   }

   function setTinTabCharacterFont (text, tabSize) {
      text.fontFace = tabFontName
      text.fontSize = tabSize
      // Vertical align to top. (0 = top, 1 = center, 2 = bottom, 3 = baseline)
      text.align = 0             // 'Align.TOP' is available in MuseScore 3.3
      // Place text to below the staff.
      text.placement = Placement.BELOW
      // Turn off note relative placement
      text.autoplace = false
   }

   // For diagnostic use.
   function dumpObjectEntries(obj, showUndefinedVals, title) {
      console.log("VV -------- " + title + " ---------- VV")
      for (var key in obj) {
         if (showUndefinedVals || (obj[key] != null)) {
            console.log(key + "=" + obj[key]);
         }
      }
      console.log("^^ -------- " + title + " ---------- ^^")
   }

   function renderTinWhistleTablature() {
      // select either the full score or just the selected staves
      var cursor = curScore.newCursor();
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;
      cursor.rewind(1)
      if (!cursor.segment) { // no selection
         fullScore = true
         startStaff = 0; // start with 1st staff
         endStaff  = curScore.nstaves - 1; // and end with last
         console.log("Full score staves " + startStaff + " - " + endStaff)
      } else {
         startStaff = cursor.staffIdx
         cursor.rewind(2)
         if (cursor.tick == 0) {
            // when the selection includes the last measure of the score:
            // rewind(2) goes behind the last segment (where there's none)
            // and sets tick=0. Need to fix up tick
            endTick = curScore.lastSegment.tick + 1
         } else {
            endTick = cursor.tick
         }
         endStaff = cursor.staffIdx
         console.log("Selected staves " + startStaff + " - " + endStaff + " - " + endTick)
      }

      // walk through the score for each (tin whistle) staff
      var basePitch
      var tabOffsetY   // according to the lowest note for the type of whistle
      for (var staff = startStaff; staff <= endStaff; staff++) {
         // check that it is for a tin whistle
         var instrument;
         var hasInstrumentId = curScore.parts[staff].instrumentId !== undefined;
         if (hasInstrumentId) {
            instrument = curScore.parts[staff].instrumentId
         } else {
            // Assume a D whistle if currently running MuseScore version is missing
            // the instrumentId property.
            instrument = "wind.flutes.whistle.tin.d"
         }

         if (instrument == "wind.flutes.whistle.tin") {
            basePitch = 72   // default is C tuning (even though D is the most common)
            tabOffsetY = -0.7
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.c") {
            basePitch = 72   // C tuning
            tabOffsetY = -0.7
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.bflat") {
            basePitch = 70   // B flat tuning
            tabOffsetY = -0.4
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.d") {
            basePitch = 74   // D tuning
            tabOffsetY = -1.0
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.common") {
            basePitch = 74   // D tuning (the most common)
            tabOffsetY = -1.0
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.eflat") {
            basePitch = 75   // E flat tuning
            tabOffsetY = -1.0
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.f") {
            basePitch = 77   // F tuning
            tabOffsetY = -1.0
            whistleFound = true;
         } else if (instrument == "wind.flutes.whistle.tin.g") {
            basePitch = 79   // G tuning
            tabOffsetY = -1.0
            whistleFound = true;
         } else {
            console.log("Skipped staff " + staff + " for instrumentId: " + instrument)
            continue
         }
         console.log("Staff " + staff + " whistle type: " + instrument)

         if (curScore.hasLyrics) {
            tabOffsetY += 2.5   // try not to clash with any lyrics
         }

         // Musescore supports up to 4 voices, but tin whistle uses only one
         cursor.voice = 0
         cursor.rewind(1)  // beginning of selection
         cursor.staffIdx = staff

         if (fullScore)  // no selection
            cursor.rewind(0) // beginning of score

         // Some positioning values used to render grace notes.
         // Note that these are determined by observation of the results
         // and appear to be consistent. It would be better to find the actual
         // location of the grace notes but that capability isn't exposed until
         // version 3.3 of MuseScore. So for the earlier releases we use these
         // heuristics.
         var graceNoteWidth = 1.2         // Assumed grace note width
         var graceNoteNudgeLeading = 0.0  // Assumed leading note cluster offset from main note
         var graceNoteNudgeTrailing = 3.0 // Assumed trailing note cluster offset from main note

         // TinWhistleTab.ttf character image font sizes.
         var tabFontSizeNormal = 35       // Size of normal sized whistle tab image
         var tabFontSizeGrace = 25        // Size of grace note sized whistle tab image

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            if (cursor.element && cursor.element.type == Element.CHORD) {
               var text = newElement(Element.STAFF_TEXT);

               // Scan grace notes for existence and add to appropriate lists...
               var leadingLifo = new Array();
               var trailingFifo = new Array();
               var graceChords = cursor.element.graceNotes;
               // Determine if Element.posX and Element.posY is supported. (MuseScore 3.3+)
               var hasElementPos = cursor.element.posX !== undefined;

               // Build separate lists of leading and trailing grace note chords.
               if (graceChords.length > 0) {
                  // Determine if Note.noteType is supported. (MuseScore 3.2.1)
                  var hasNoteType = graceChords[0].notes[0] !== undefined;
                  if (hasNoteType) {
                     for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
                        var noteType = graceChords[chordNum].notes[0].noteType
                        if (noteType == NoteType.GRACE8_AFTER || noteType == NoteType.GRACE16_AFTER ||
                              noteType == NoteType.GRACE32_AFTER) {
                           trailingFifo.unshift(graceChords[chordNum])
                        } else {
                           leadingLifo.push(graceChords[chordNum])
                        }
                     }
                  } else {
                     // Assume all grace notes are of the leading variety since
                     // the NoteType capability doesn't exist in the running version of
                     // MuseScore.
                     for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
                        leadingLifo.unshift(graceChords[chordNum])
                     }
                  }
               }

               // First render leading grace notes if any exist...
               if (leadingLifo.length > 0) {
                  // Compute starting offset to location of the lead leftmost grace note.
                  var graceLocationX = leadingLifo.length * -graceNoteWidth + graceNoteNudgeLeading;
                  for (var chordNum = 0; chordNum < leadingLifo.length; chordNum++) {
                     // there are no chords when playing the tin whistle
                     var chord = leadingLifo[chordNum];
                     var pitch = chord.notes[0].pitch;

                     text.text = selectTinTabCharacter(pitch, basePitch)
                     // Note: Set text attributes *after* adding element to the score.
                     cursor.add(text)
                     // grace notes are shown a bit smaller
                     setTinTabCharacterFont(text, tabFontSizeGrace)
                     if (hasElementPos) {
                        // X position the tab image under the grace note
                        text.offsetX = chord.posX
                     }
                     else {
                        // there seems to be no way of knowing the exact horizontal pos.
                        // of a grace note, so we have to guess:
                        text.offsetX = graceLocationX
                        // Move to the next note location.
                        graceLocationX += graceNoteWidth;
                     }
                     // (See the note below about behavior of the text.offsetY property.)
                     text.offsetY = tabOffsetY   // place the tab below the staff

                     // Create new text element for next tab placement
                     text = newElement(Element.STAFF_TEXT)
                  }
               }

               // Next process the parent note...
               if (cursor.element.notes[0].tieBack == null) {  // don't add tab if note is tied to previous note
                  // there are no chords when playing the tin whistle, so use first note
                  var chord = cursor.element;
                  var pitch = chord.notes[0].pitch;
                  text.text = selectTinTabCharacter(pitch, basePitch)

                  // NOTE - text.offsetY behavior oddity:
                  // When you cursor.add() a staff text element to the current cursor
                  // location after changing its placement to "below", the text.offsetY
                  // value is replaced by the UI menu "Format/Style.../Staff Text" value
                  // specified for the "below" placement. Thereafter any values set to
                  // text.offsetY are now ADDED to the current value making it grow larger
                  // with every assignment.

                  // -- more explicitly --
                  // Prior to the cursor.add() the text.offsetY value will contain
                  // the "Format/Style.../Staff Text" value
                  // for placement "above".
                  cursor.add(text)      // Add the staff text at the cursor
                  // Set text attributes *after* adding element to the score.
                  setTinTabCharacterFont(text, tabFontSizeNormal)
                  // At this point the text.offsetY value will contain the
                  // "Format/Style.../Staff Text" value for "below" regardless of what
                  // its previous value was.
                  // -
                  // Next, setting text.offsetY will actually ADD the new value to the current value thereby
                  // acting as a numerical integrator.
                  text.offsetY = tabOffsetY
                  // Place the whistle hole pattern to be centered under the note.
                  if (hasElementPos)
                     text.offsetX = chord.posX + 0.25
                  else
                     text.offsetX = 0.5

                  // Create new text element for next tab placement
                  text = newElement(Element.STAFF_TEXT)
               }

               // Finally process trailing grace notes if any exist...
               if (trailingFifo.length > 0) {
                  // Set the starting offset to location of the first trailing grace note.
                  var graceLocationX = graceNoteNudgeTrailing;

                  for (var chordNum = 0; chordNum < trailingFifo.length; chordNum++) {
                     // there are no chords when playing the tin whistle
                     var chord = trailingFifo[chordNum];
                     var pitch = chord.notes[0].pitch;

                     text.text = selectTinTabCharacter(pitch, basePitch)
                     // Note: Set text attributes *after* adding element to the score.
                     cursor.add(text)
                     // grace notes are shown a bit smaller
                     setTinTabCharacterFont(text, tabFontSizeGrace)
                     if (hasElementPos) {
                        // X position the tab image under the grace note
                        text.offsetX = chord.posX
                     }
                     else {
                        // there seems to be no way of knowing the exact horizontal pos.
                        // of a grace note, so we have to guess:
                        text.offsetX = graceLocationX
                        // Move to the next note location.
                        graceLocationX += graceNoteWidth;
                     }
                     // (See the note below about behavior of the text.offsetY property.)
                     text.offsetY = tabOffsetY   // place the tab below the staff

                     // Create new text element for next tab placement
                     text = newElement(Element.STAFF_TEXT)
                  }
               }
            } // end if CHORD
            cursor.next()
         } // end while segment
      } // end for staff
      Qt.quit()
   }

   onRun: {
      console.log("Hello tin whistle tablature")

      if (typeof curScore === 'undefined')
         Qt.quit()

      if (Qt.fontFamilies().indexOf("Tin Whistle Tab") >= 0) {
         renderTinWhistleTablature()
         if (!whistleFound)
            noWhistlesFound.open()
      }
      else
         fontMissingDialog.open()
      Qt.quit()
   } // end onRun
}
