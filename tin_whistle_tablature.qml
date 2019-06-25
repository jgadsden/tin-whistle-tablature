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

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
   version: "3.0"
   description: qsTr("This plugin provides fingering diagrams for the tin whistle. Ensure font `TinWhistleTab.ttf` is installed")
   menuPath: "Plugins.Tin Whistle.Add tablature"

   // The notes from the "Tin Whistle Tab" font, using key of D as standard
   property variant tabs : ["d", "i", "e", "j", "f", "g", "h", "a", "n", "b", "m", "c", "D", "I", "E", "J", "F", "G", "H", "A", "N", "B", "M", "C", '\u00CE']

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
      text.fontFace = "Tin Whistle Tab"
      text.fontSize = tabSize
      // Vertical align to top. (0 = top, 1 = center, 2 = bottom, 3 = baseline)
      text.align = 0
      // Set text to below the staff.
      text.placement = Placement.BELOW
      // Turn off note relative placement
      text.autoplace = false
   }

   // For diagnostic use.
   function dumpObjectEntries (obj, showUndefinedVals, title) {
      console.log("VV -------- " + title + " ---------- VV")
      for (let [key, value] of Object.entries(obj)) {
         if (showUndefinedVals || (value != null)) {
            console.log(key + "=" + value); 
         }
      }
      console.log("^^ -------- " + title + " ---------- ^^")
   }

   onRun: {
      console.log("hello tin whistle tablature")

      if (typeof curScore === 'undefined')
         Qt.quit()

      // select either the full score or just the selected staves
      var cursor = curScore.newCursor()
      var startStaff
      var endStaff
      var endTick
      var fullScore = false
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
         var instrument
         if (curScore.parts[staff].instrumentId !== undefined) {
            instrument = curScore.parts[staff].instrumentId
         } else {
            // Assume a D whistle if running MuseScore version is missing 
            // the instrumentId property.
            instrument = "wind.flutes.whistle.tin.d"
         }

         if (instrument == "wind.flutes.whistle.tin") {
            basePitch = 72   // default is C tuning (even though D is the most common)
            tabOffsetY = -0.7
         } else if (instrument == "wind.flutes.whistle.tin.c") {
            basePitch = 72   // C tuning
            tabOffsetY = -0.7
         } else if (instrument == "wind.flutes.whistle.tin.bflat") {
            basePitch = 70   // B flat tuning
            tabOffsetY = -0.4
         } else if (instrument == "wind.flutes.whistle.tin.d") {
            basePitch = 74   // D tuning
            tabOffsetY = -1.0
         } else if (instrument == "wind.flutes.whistle.tin.common") {
            basePitch = 74   // D tuning (the most common)
            tabOffsetY = -1.0
         } else if (instrument == "wind.flutes.whistle.tin.eflat") {
            basePitch = 71   // E flat tuning
            tabOffsetY = -1.0
         } else if (instrument == "wind.flutes.whistle.tin.f") {
            basePitch = 77   // F tuning
            tabOffsetY = -1.0
         } else if (instrument == "wind.flutes.whistle.tin.g") {
            basePitch = 79   // G tuning
            tabOffsetY = -1.0
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
         cursor.rewind(1); // beginning of selection
         cursor.staffIdx = staff

         if (fullScore)  // no selection
            cursor.rewind(0); // beginning of score

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            if (cursor.element && cursor.element.type == Element.CHORD) {
               var text = newElement(Element.STAFF_TEXT)

               // handle grace notes first
               var graceChords = cursor.element.graceNotes
               if (graceChords.length > 0) {
                  // This code only assumes that grace notes can only precede the main note.
                  // The assumption is based on the fact that MusicXML doesn't support the grace
                  // linkage to the preceding note. They will be attached to the next note in 
                  // XML sequence.

                  var graceNoteWidth = 1.2;     // Assumed grace note width
                  var graceNoteNudge = 0.0;     // Assumed note cluster offset from main note
                  // Compute starting offset to location of the current grace note.
                  var graceLocationX = graceChords.length * -graceNoteWidth + graceNoteNudge;
                  for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
                     // there are no chords when playing the tin whistle
                     var pitch = graceChords[chordNum].notes[0].pitch
                     text.text = selectTinTabCharacter(pitch, basePitch)

                     // Note: Set text attributes *after* adding element to the score.
                     cursor.add(text)

                     // grace notes are shown a bit smaller
                     setTinTabCharacterFont(text, 25)

                     // there seems to be no way of knowing the exact horizontal pos.
                     // of a grace note, so we have to guess:
                     text.offsetX = graceLocationX
                     // Move to the next note location.
                     graceLocationX += graceNoteWidth;
                     // (See the note below about behaviour of the text.offsetY property.)
                     text.offsetY = tabOffsetY   // place the tab below the staff

                     // Create new text for next element
                     text = newElement(Element.STAFF_TEXT)                 
                  }
               }

               // don't add tab if note is tied to previous note
               if (cursor.element.notes[0].tieBack == null) {
                  // there are no chords when playing the tin whistle, so use first note
                  var pitch = cursor.element.notes[0].pitch
                  text.text = selectTinTabCharacter(pitch, basePitch)

                  // NOTE - text.offsetY behaviour oddity:
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
                  setTinTabCharacterFont(text, 35)
                  // At this point the text.offsetY value will contain the 
                  // "Format/Style.../Staff Text" value for "below" regardless of what 
                  // its previous value was.
                  // -
                  // Next, setting text.offsetY will actually ADD the new value to the current value thereby
                  // acting as a numerical integrator.
                  text.offsetY = tabOffsetY
                  // Nudge the hole pattern to be centered under the note.
                  text.offsetX = 0.5
               }
            } // end if CHORD
            cursor.next()
         } // end while segment
      } // end for staff
      Qt.quit()
   } // end onRun
}
