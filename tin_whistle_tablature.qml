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
//  the file LICENCE
//=============================================================================

import QtQuick 2.15
import MuseScore 3.0
import Muse.UiComponents 1.0

MuseScore {
   version: "4.1"
   description: "This plugin provides fingering diagrams for the tin whistles, requires `TinWhistleTab.ttf` font"
   title: "Tin Whistle Tablature"
   categoryCode: "composing-arranging-tools"

   property string tabFontName: "Tin Whistle Tab"
   property bool whistleFound: false

   // The notes from the "Tin Whistle Tab" font, using key of D as standard
   property variant tabs : ["d", "i", "e", "j", "f", "g", "h", "a", "n", "b", "m", "c", "D", "I", "E", "J", "F", "G", "H", "A", "N", "B", "M", "C", '\u00CE']

   MessageDialog {
      id: fontMissingDialog
      title: "Missing Tin Whistle Tablature font!"
      text: "The Tin Whistle Tab font is not installed on your device."
      detailedText:  "You can download the font from the web here:\n\n" +
         "https://www.blaynechastain.com/wp-content/uploads/TinWhistleTab.zip\n\n" +
         "The Zip file contains the TinWhistleTab.ttf font file you need to install on your device.\n" +
         "If you are running Windows 10 you must install the font for \"all users\".\n" +
         "This is due to a quirk in the QT framework that MuseScore uses to implement the program.\n" +
         "Note that you will also need to restart MuseScore for it to recognize the new font."

      onAccepted: {
         quit();
      }

      visible: false;
   }

   MessageDialog {
      id: noWhistlesFound
      title: "No Staffs use a Tin Whistle"
      text: "No selected staff in the current score uses a tin whistle instrument.\n" +
            "Use tab \"Instruments -> Add\" to select instruments"

      onAccepted: {
         quit()
      }

      visible: false;
   }

   function selectTinTabCharacter (pitch, basePitch) {
      var tabText = ""
      var index = pitch - basePitch
      if (index < 0) {
         console.log("Skipped note as it was too low, pitch : " + pitch)
         return tabText
      }
      if (index > 24) {
         console.log("Skipped note as it was too high, pitch : " + pitch)
         return tabText
      }
      tabText = tabs[index]
      return tabText
   } // end selectTinTabCharacter

   function setTabCharacterFont (text, tabSize) {
      text.fontFace = tabFontName
      text.fontSize = tabSize
      // Vertical align to top. (0 = top, 1 = center, 2 = bottom, 3 = baseline)
      text.align = 0             // 'Align.TOP' is available in MuseScore 3.3
      // Place text to below the staff.
      text.placement = Placement.BELOW
      // Turn off note relative placement
      text.autoplace = false
   } // end setTabCharacterFont

   // For diagnostic use.
   function dumpObjectEntries (obj, showUndefinedVals, title) {
      console.log("VV -------- " + title + " ---------- VV")
      for (var key in obj) {
         if (showUndefinedVals || (obj[key])) {
            console.log(key + "=" + obj[key]);
         }
      }
      console.log("^^ -------- " + title + " ---------- ^^")
   } // end dumpObjectEntries

   function getWhistlePitch(instrument) {
      var pitch = none
      // MuseScore 3 returned the MusicXML instrument ID, some versions of MuseScore 4 returned their own instrument ID, search for both
      if (instrument === "c-tin-whistle" || instrument === "wind.flutes.whistle.tin.c" || instrument === "wind.flutes.whistle.tin") {
         pitch = "c"
      } else if (instrument === "bflat-tin-whistle" || instrument === "wind.flutes.whistle.tin.bflat") {
         pitch = "bflat"
      } else if (instrument === "d-tin-whistle" || instrument === "common-tin-whistle" || instrument === "wind.flutes.whistle.tin.d" || instrument === "wind.flutes.whistle.tin.common") {
         // D tuning is the most common
         pitch = "d"
      } else if (instrument === "eflat-tin-whistle" || instrument === "wind.flutes.whistle.tin.eflat") {
         pitch = "eflat"
      } else if (instrument === "f-tin-whistle" || instrument === "wind.flutes.whistle.tin.f") {
         pitch = "f"
      } else if (instrument === "g-tin-whistle" || instrument === "wind.flutes.whistle.tin.g") {
         pitch = "g"
      } else if (instrument === "d-low-whistle" || instrument === "wind.flutes.whistle.low.d") {
         pitch = "dlow"
      } else if (instrument === "f-low-whistle" || instrument === "wind.flutes.whistle.low.f") {
         pitch = "flow"
      } else if (instrument === "g-low-whistle" || instrument === "wind.flutes.whistle.low.g") {
         pitch = "glow"
      } else {
         console.log("No pitch found for instrumentId: " + instrument)
      }
      return pitch
   } // end getWhistlePitch

   function getBasePitch(whistlePitch) {
      var pitch = 0
      if (whistlePitch === "c") {
         pitch = 72
      } else if (whistlePitch === "bflat") {
         pitch = 70
      } else if (whistlePitch === "d") {
         pitch = 74
      } else if (whistlePitch === "eflat") {
         pitch = 75
      } else if (whistlePitch === "f") {
         pitch = 77
      } else if (whistlePitch === "g") {
         pitch = 79
      } else if (whistlePitch === "dlow") {
         pitch = 62
      } else if (whistlePitch === "flow") {
         pitch = 65
      } else if (whistlePitch === "glow") {
         pitch = 67
      } else {
         console.log("No offset found for instrumentId: " + instrument)
      }
      return pitch
   } // end getBasePitch

   function getTabOffset(whistlePitch) {
      var offset = 0
      if (whistlePitch === "c") {
         offset = 3.3
      } else if (whistlePitch === "bflat") {
         offset = 3.6
      } else if (whistlePitch === "d") {
         offset = 3.0
      } else if (whistlePitch === "eflat") {
         offset = 3.0
      } else if (whistlePitch === "f") {
         offset = 3.0
      } else if (whistlePitch === "g") {
         offset = 3.0
      } else if (whistlePitch === "dlow") {
         offset = 5.6
      } else if (whistlePitch === "flow") {
         offset = 4.6
      } else if (whistlePitch === "glow") {
         offset = 4.0
      } else {
         console.log("No offset found for instrumentId: " + instrument)
      }
      return offset
   } // end getTabOffset

   function removeDuplicatesInSegment(segment, elementToKeep) {
      var removables = [];

      for (var i = 0; i < segment.annotations.length; i++) {
         var element = segment.annotations[i];
         if (element.is(elementToKeep)) {
            continue;
         }

         if (element.offsetX == elementToKeep.offsetX && element.offsetY == elementToKeep.offsetY) {
            removables.push(element);
         }
      }

      for (var i = 0; i < removables.length; i++) {
         var element = segment.annotations[i];
         removeElement(element);
      }
   }

   function renderTinWhistleTablature () {
      curScore.startCmd();

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
         if (cursor.tick === 0) {
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
      var pitch
      var lastPitch = 0
      var tabOffsetY   // according to the lowest note for the type of whistle
      for (var staff = startStaff; staff <= endStaff; staff++) {

         // check that it is for a tin whistle
         var instrument;
         var hasInstrumentId = curScore.staves[staff].part.instrumentId !== undefined;
         if (hasInstrumentId) {
            instrument = curScore.staves[staff].part.instrumentId
         } else {
            // use the common whistle if the instrumentId property is missing
            // as some MuseScore versions do not implement it
            instrument = "common-tin-whistle"
         }

         var whistlePitch = getWhistlePitch(instrument)
         if (whistlePitch != "none") {
            whistleFound = true;
            basePitch = getBasePitch(whistlePitch)
            tabOffsetY = getTabOffset(whistlePitch)
            if (curScore.hasLyrics) {
               tabOffsetY += 2.8   // try not to clash with any lyrics
            }
         } else {
            basePitch = 0
            tabOffsetY = 0
            console.log("Skipped staff " + staff + " for instrumentId: " + instrument)
            continue
         }

         console.log("Staff " + staff + " whistle type: " + instrument + " with base pitch: " + basePitch + " and offset: " + tabOffsetY)

         // staff is for tin whistle, so init repeated note check
         lastPitch = 0

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
            if (cursor.element && cursor.element.type === Element.CHORD) {
               var text = newElement(Element.STAFF_TEXT);

               // Scan grace notes for existence and add to appropriate lists...
               var leadingLifo = [];
               var trailingFifo = [];
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
                        if (noteType === NoteType.GRACE8_AFTER || noteType === NoteType.GRACE16_AFTER ||
                              noteType === NoteType.GRACE32_AFTER) {
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
                     pitch = chord.notes[0].pitch;
                     // keep track of repeated notes
                     lastPitch = pitch

                     text.text = selectTinTabCharacter(pitch, basePitch)
                     // Note: Set text attributes *after* adding element to the score.
                     cursor.add(text)
                     // grace notes are shown a bit smaller
                     setTabCharacterFont(text, tabFontSizeGrace)
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

                     removeDuplicatesInSegment(cursor.segment, text);

                     // Create new text element for next tab placement
                     text = newElement(Element.STAFF_TEXT)
                  }
               }

               // Next process the parent note...
               if (cursor.element.notes[0].tieBack) {
                  // don't add tab if parent note is tied to previous note
                  console.log("Skipped tied parent note, pitches : " + pitch + ", " + lastPitch)
               }
               else {
                  // there are no chords when playing the tin whistle, so use first note
                  var chord = cursor.element;
                  pitch = chord.notes[0].pitch;

                  if (pitch === lastPitch) {
                     // don't add tab if parent note is same pitch as previous note
                     console.log("Skipped repeated parent note, pitches : " + pitch + ", " + lastPitch)
                  }
                  else {
                     // keep track of repeated notes
                     lastPitch = pitch

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
                     setTabCharacterFont(text, tabFontSizeNormal)
                     // At this point the text.offsetY value will contain the
                     // "Format/Style.../Staff Text" value for "below" regardless of what
                     // its previous value was.
                     // -
                     // Next, setting text.offsetY will actually ADD the new value
                     // to the current value thereby acting as a numerical integrator.
                     text.offsetY = tabOffsetY
                     // Place the whistle hole pattern to be centered under the note.
                     if (hasElementPos)
                        text.offsetX = chord.posX + 0.25
                     else
                        text.offsetX = 0.5

                     removeDuplicatesInSegment(cursor.segment, text);

                     // Create new text element for next tab placement
                     text = newElement(Element.STAFF_TEXT)
                  } // end if repeated
               } // end if tied back

               // Finally process trailing grace notes if any exist...
               if (trailingFifo.length > 0) {
                  // Set the starting offset to location of the first trailing grace note.
                  var graceLocationX = graceNoteNudgeTrailing;

                  for (var chordNum = 0; chordNum < trailingFifo.length; chordNum++) {
                     // there are no chords when playing the tin whistle
                     var chord = trailingFifo[chordNum];
                     pitch = chord.notes[0].pitch;
                     // keep track of repeated notes
                     lastPitch = pitch

                     text.text = selectTinTabCharacter(pitch, basePitch)
                     // Note: Set text attributes *after* adding element to the score.
                     cursor.add(text)
                     // grace notes are shown a bit smaller
                     setTabCharacterFont(text, tabFontSizeGrace)
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

                     removeDuplicatesInSegment(cursor.segment, text);

                     // Create new text element for next tab placement
                     text = newElement(Element.STAFF_TEXT)
                  }
               }
            } // end if CHORD
   
            cursor.next()
   
         } // end while segment
      } // end for staff

      curScore.endCmd();
      quit()
   
   } // end renderTinWhistleTablature

   onRun: {
      console.log("Hello tin whistle tablature")

      if (typeof curScore === 'undefined') {
         quit()
      }

      if (Qt.fontFamilies().indexOf("Tin Whistle Tab") >= 0) {
         renderTinWhistleTablature()
         if (!whistleFound) {
            noWhistlesFound.open()
         }
      } else {
         fontMissingDialog.open()
      }

      quit()

   } // end onRun

} // end MuseScore
