//
//  NoteViewModel.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftUI
import SwiftData

@Observable
class NoteViewModel {
    
    var noteItem: Note?
    
    var titleField: String = ""
    var contentField: String = ""
    var noteColor: String = "blue"
    var isPinned: Bool = false
    var lastModified: Date = Date.now
    
    var changingColor: Bool = false
    var isEditing: Bool = false
    
    func setNote(_ note: Note) {
        self.noteItem = note
        self.titleField = note.name
        self.contentField = note.content
        self.noteColor = note.color
        self.lastModified = note.lastModified
        self.isPinned = note.isPinned
    }
    
    func saveNote(_ context: ModelContext) -> Void {
        if titleField.isEmpty {
            return
        }

        if let existingNote = noteItem {
            existingNote.name = titleField
            existingNote.content = contentField
            existingNote.color = noteColor
            existingNote.isPinned = isPinned
            existingNote.lastModified = lastModified
        } else {
            let newNote = Note(
                name: titleField,
                content: contentField,
                color: noteColor,
                isPinned: isPinned,
                lastModified: lastModified
            )
            context.insert(newNote)
            self.noteItem = newNote
        }

        do {
            try context.save()
        } catch {
            print("error saving: \(error)")
        }
    }
    
    func deleteNote(_ context: ModelContext) -> Void {
        context.delete(noteItem!)
    }
    
    func updateTitle() -> Void {
        if let existingNote = noteItem {
            existingNote.name = self.titleField
        }
        
        updateLastModified()
    }
    
    func updateContent() -> Void {
        if let existingNote = noteItem {
            existingNote.content = self.contentField
        }
        
        updateLastModified()
        isEditing = false
    }
    
    func updateLastModified() -> Void {
        self.lastModified = Date.now
        
        if let existingNote = noteItem {
            existingNote.lastModified = self.lastModified
        }
    }
    
    func updatePinned() -> Void {
        self.isPinned.toggle()
        
        if let existingNote = noteItem {
            existingNote.isPinned = self.isPinned
        }
        
        updateLastModified()
    }
    
    func setColor(_ color: String) -> Void {
        self.noteColor = color
        
        if let existingNote = noteItem {
            existingNote.color = self.noteColor
        }
        
        updateLastModified()
    }
    
    func getTime() -> String {
        return "\(self.lastModified.formatted(.dateTime.hour().minute()))"
    }
    
    func getDate() -> String {
        let isToday = Calendar.current.isDateInToday(lastModified)
        
        if (isToday) {
            return "Today"
        } else {
            return "\(self.lastModified.formatted(.dateTime.month().day()))"
        }
    }
    
    func getNoteItemFromID(_ id: UUID, context: ModelContext) {
        
    }
}
