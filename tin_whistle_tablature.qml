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

import QtQuick 2.9
import MuseScore 3.0

MuseScore {
   version: "3.0"
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
      var basePitch = 74   // D tuning (the most common)
      for (var staff = startStaff; staff <= endStaff; staff++) {
         // Musescore supports up to 4 voices, but tin whistle uses only one
         cursor.voice = 0
         cursor.rewind(1); // beginning of selection
         cursor.staffIdx = staff

         if (fullScore)  // no selection
            cursor.rewind(0); // beginning of score

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            if (cursor.element && cursor.element.type == Element.CHORD) {
               var text = newElement(Element.STAFF_TEXT)
               
               // put text below notes
               text.autoplace = false
               text.offsetY = 10.5
               
               // handle grace notes first
               var graceChords = cursor.element.graceNotes
               if (graceChords.length > 0) {
                  // grace note text
                  var graceText = newElement(Element.STAFF_TEXT)
               
                  // there are no chords when playing the tin whistle
                  var pitch = graceChords[0].notes[0].pitch
                  
                  // grace notes are shown a bit smaller
                  graceText.text = selectTab(pitch, basePitch, 25) 
                  
                  // there seems to be no way of knowing the exact horizontal pos.
                  // of a grace note, so we have to guess:
                  graceText.offsetX = -2.5
                  graceText.offsetY = 10.5
                  graceText.autoplace = false
                  cursor.add(graceText)
               }

               // there are no chords when playing the tin whistle, so use first note
               var pitch = cursor.element.notes[0].pitch
               text.text = selectTab(pitch, basePitch, 35)
               cursor.add(text)
            } // end if CHORD
            cursor.next()
         } // end while segment
      } // end for staff
      Qt.quit()
   } // end onRun
}
