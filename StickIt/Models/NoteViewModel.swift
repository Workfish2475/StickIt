//
//  NoteViewModel.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftUI
import SwiftData
import WidgetKit

@Observable
class NoteViewModel {
    
    var noteItem: Note?
    
    // MARK: - General business logic (not specific to mobile or desktop)
    var titleField: String = ""
    var contentField: String = ""
    var noteColor: String = "blue"
    var isPinned: Bool = false
    var lastModified: Date = Date.now
    var changingColor: Bool = false
    var isEditing: Bool = false
    
    var viewColor: Color {
        return Color(name: noteColor)
    }
    
    // MARK: - Platform specific logic or members
    var isShowingHeader: Bool = false
    var scrollOffset: CGFloat = 0
    
    func setNote(_ note: Note) {
        self.noteItem = note
        self.titleField = note.name
        self.contentField = note.content
        self.noteColor = note.color
        self.lastModified = note.lastModified
        self.isPinned = note.isPinned
    }
    
    func saveNote(_ context: ModelContext) -> Void {
        guard let noteItem = noteItem else {
            if !titleField.isEmpty || !contentField.isEmpty {
                let newNote = Note(
                    name: titleField,
                    content: contentField,
                    color: noteColor,
                    isPinned: isPinned,
                    lastModified: lastModified
                )
                
                self.noteItem = newNote
                context.insert(newNote)
                
                do {
                    try context.save()
                    WidgetCenter.shared.reloadAllTimelines()
                } catch {
                    print("error saving new note: \(error)")
                }
            }
            
            return
        }
        
        
        if noteItem.name == titleField &&
            noteItem.content == contentField &&
            noteItem.color == noteColor &&
            noteItem.isPinned == isPinned {
            return
        }
        
        noteItem.name = titleField
        noteItem.content = contentField
        noteItem.color = noteColor
        noteItem.isPinned = isPinned
        noteItem.lastModified = Date()
        
        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("error saving updated note: \(error)")
        }
    }
    
    func deleteNote(_ context: ModelContext) -> Void {
        context.delete(noteItem!)
        
        WidgetCenter.shared.reloadAllTimelines()
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
    
    func updateContent(_ newText: String) -> Void {
        if let existingNote = noteItem {
            existingNote.content = newText
        }
        
        updateLastModified()
    }
    
    func updateLastModified() -> Void {
        self.lastModified = Date.now
        
        if let existingNote = noteItem {
            existingNote.lastModified = self.lastModified
        }
        
        WidgetCenter.shared.reloadAllTimelines()
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
    
    // Fetches the most updated version of the note from iCloud.
    func syncChanges(_ context: ModelContext) {
        if let existingNote = noteItem {
            let noteID = existingNote.id
            let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == noteID })
            
            do {
                let newNote = try context.fetch(descriptor).first
                
                if newNote?.lastModified == existingNote.lastModified {
                    return
                }
                
                guard let newNote = newNote else {
                    print("No updated note found for ID: \(noteID)")
                    return
                }
                
                setNote(newNote)
            } catch {
                print("error fetching note: \(error)")
            }
        }
    }
}
