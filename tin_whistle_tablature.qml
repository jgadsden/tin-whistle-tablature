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
import MuseScore 1.0

MuseScore {
   version: "2.1"
   description: qsTr("This plugin provides fingering diagrams for the tin whistle. Ensure font `TinWhistleTab.ttf` is installed")
   menuPath: "Plugins.Tin Whistle.Add tablature"

   // The notes from the "Tin Whistle Tab" font, using key of D as standard
   property variant tabs : ["d", "i", "e", "j", "f", "g", "h", "a", "n", "b", "m", "c", "D", "I", "E", "J", "F", "G", "H", "A", "N", "B", "M", "C", '\u00CE']

   function selectTab (pitch, basePitch, tabSize) {
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
      tabText = "<font size=\"" + tabSize + "\"><font face=\"Tin Whistle Tab\">" + tabs[index] + "</font></font>"
      return tabText
   }

   onRun: {
      console.log("hello tin whistle tablature")
      if (typeof curScore === 'undefined')
         Qt.quit()

      var score = curScore
      console.log(curScore)
      console.log(score.name)

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
         var instrument = curScore.parts[staff].instrumentId
         if (instrument == "wind.flutes.whistle.tin") {
            basePitch = 72   // default is C tuning (even though D is the most common)
            tabOffsetY = 10.3
         } else if (instrument == "wind.flutes.whistle.tin.c") {
            basePitch = 72   // C tuning
            tabOffsetY = 10.3
         } else if (instrument == "wind.flutes.whistle.tin.bflat") {
            basePitch = 70   // B flat tuning
            tabOffsetY = 10.6
         } else if (instrument == "wind.flutes.whistle.tin.d") {
            basePitch = 74   // D tuning
            tabOffsetY = 10
         } else if (instrument == "wind.flutes.whistle.tin.common") {
            basePitch = 74   // D tuning (the most common)
            tabOffsetY = 10
         } else if (instrument == "wind.flutes.whistle.tin.eflat") {
            basePitch = 71   // E flat tuning
            tabOffsetY = 10
         } else if (instrument == "wind.flutes.whistle.tin.f") {
            basePitch = 77   // F tuning
            tabOffsetY = 10
         } else if (instrument == "wind.flutes.whistle.tin.g") {
            basePitch = 79   // G tuning
            tabOffsetY = 10
         } else {
            console.log("Skipped staff " + staff + " for instrument: " + instrument)
            continue
         }
         console.log("Staff " + staff + " whistle type: " + instrument)
         
         if (curScore.hasLyrics) {
            tabOffsetY += 3   // try not to clash with any lyrics
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
                  // there are no chords when playing the tin whistle
                  var pitch = graceChords[0].notes[0].pitch
                  // grace notes are shown a bit smaller
                  text.text = selectTab(pitch, basePitch, 25) 
                  // there seems to be no way of knowing the exact horizontal pos.
                  // of a grace note, so we have to guess:
                  text.pos.x = -2.5
                  text.pos.y = tabOffsetY   // place the tab below the staff
                  cursor.add(text)
                  // new text for next element
                  text  = newElement(Element.STAFF_TEXT)
               }
               
               // don't add tab if note is tied to previous note
               if(cursor.element.notes[0].tieBack == null) {
                   // there are no chords when playing the tin whistle, so use first note
                  var pitch = cursor.element.notes[0].pitch
                  text.text = selectTab(pitch, basePitch, 35)
                  text.pos.y = tabOffsetY   // place the tab below the staff
                  cursor.add(text)
               }
            } // end if CHORD
            cursor.next()
         } // end while segment
      } // end for staff
      Qt.quit()
   } // end onRun
}
