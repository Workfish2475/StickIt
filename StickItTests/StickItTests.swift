//
//  StickItTests.swift
//  StickItTests
//
//  Created by Alexander Rivera on 4/12/25.
//

import Testing
@testable import StickIt
import SwiftData
import Foundation

struct StickItTests {
    @Test func setNote() {
        let newNote = Note(
            name: "Demo",
            content: "content",
            color: "red",
            isPinned: false,
            lastModified: .now
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(newNote)
        
        #expect(viewModel.noteItem == newNote)
        #expect(viewModel.titleField == "Demo")
        #expect(viewModel.contentField == "content")
        #expect(viewModel.noteColor == "red")
        #expect(!viewModel.isPinned)
        #expect(viewModel.lastModified.distance(to: .now) < 1)
    }
    
    @Test func saveNewNote() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        let context = ModelContext(container)
        
        let viewModel = NoteViewModel()
        viewModel.titleField = "New Note"
        viewModel.contentField = "New Content"
        viewModel.noteColor = "green"
        viewModel.isPinned = true
        
        viewModel.saveNote(context)
        
        #expect(viewModel.noteItem != nil)
        #expect(viewModel.noteItem?.name == "New Note")
        #expect(viewModel.noteItem?.content == "New Content")
        #expect(viewModel.noteItem?.color == "green")
        #expect(viewModel.noteItem?.isPinned == true)
        #expect(!viewModel.isEditing)
        
        let descriptor = FetchDescriptor<Note>()
        let savedNotes = try context.fetch(descriptor)
        #expect(savedNotes.count == 1)
        #expect(savedNotes.first?.name == "New Note")
    }
    
    @Test func saveExistingNote() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        let context = ModelContext(container)
        
        let existingNote = Note(
            name: "Original",
            content: "Original Content",
            color: "blue",
            isPinned: false,
            lastModified: .now
        )
        context.insert(existingNote)
        
        let viewModel = NoteViewModel()
        viewModel.setNote(existingNote)
        viewModel.titleField = "Updated Title"
        viewModel.contentField = "Updated Content"
        viewModel.noteColor = "yellow"
        viewModel.isPinned = true
        
        viewModel.saveNote(context)
        
        #expect(existingNote.name == "Updated Title")
        #expect(existingNote.content == "Updated Content")
        #expect(existingNote.color == "yellow")
        #expect(existingNote.isPinned == true)
        #expect(!viewModel.isEditing)
    }
    
    @Test func saveNoteWithEmptyTitle() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        let context = ModelContext(container)
        
        let viewModel = NoteViewModel()
        viewModel.titleField = ""
        viewModel.contentField = "Some content"
        
        viewModel.saveNote(context)
        
        #expect(viewModel.noteItem == nil)
        let descriptor = FetchDescriptor<Note>()
        let savedNotes = try context.fetch(descriptor)
        #expect(savedNotes.count == 0)
    }
    
    @Test func deleteNote() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        let context = ModelContext(container)
        
        let note = Note(
            name: "To Delete",
            content: "Content",
            color: "red",
            isPinned: false,
            lastModified: .now
        )
        context.insert(note)
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        
        viewModel.deleteNote(context)
        
        let descriptor = FetchDescriptor<Note>()
        let remainingNotes = try context.fetch(descriptor)
        #expect(remainingNotes.count == 0)
    }
    
    @Test func updateTitle() {
        let note = Note(
            name: "Original Title",
            content: "Content",
            color: "blue",
            isPinned: false,
            lastModified: .distantPast
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        viewModel.titleField = "New Title"
        
        let originalDate = note.lastModified
        viewModel.updateTitle()
        
        #expect(note.name == "New Title")
        #expect(note.lastModified > originalDate)
        #expect(viewModel.lastModified > originalDate)
    }
    
    @Test func updateContentString() {
        let note = Note(
            name: "Title",
            content: "Original Content",
            color: "blue",
            isPinned: false,
            lastModified: .distantPast
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        viewModel.contentField = "New Content"
        
        let originalDate = note.lastModified
        viewModel.updateContent()
        
        #expect(note.content == "New Content")
        #expect(note.lastModified > originalDate)
        #expect(viewModel.lastModified > originalDate)
        #expect(!viewModel.isEditing)
    }
    
    @Test func updateContentWithParameter() {
        let note = Note(
            name: "Title",
            content: "Original Content",
            color: "blue",
            isPinned: false,
            lastModified: .distantPast
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        
        let originalDate = note.lastModified
        viewModel.updateContent("Parameter Content")
        
        #expect(note.content == "Parameter Content")
        #expect(note.lastModified > originalDate)
        #expect(viewModel.lastModified > originalDate)
    }
    
    @Test func updatePinned() {
        let note = Note(
            name: "Title",
            content: "Content",
            color: "blue",
            isPinned: false,
            lastModified: .distantPast
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        
        let originalDate = note.lastModified
        viewModel.updatePinned()
        
        #expect(viewModel.isPinned == true)
        #expect(note.isPinned == true)
        #expect(note.lastModified > originalDate)
        #expect(viewModel.lastModified > originalDate)
        
        // Test toggling back
        viewModel.updatePinned()
        #expect(viewModel.isPinned == false)
        #expect(note.isPinned == false)
    }
    
    @Test func setColor() {
        let note = Note(
            name: "Title",
            content: "Content",
            color: "blue",
            isPinned: false,
            lastModified: .distantPast
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        
        let originalDate = note.lastModified
        viewModel.setColor("purple")
        
        #expect(viewModel.noteColor == "purple")
        #expect(note.color == "purple")
        #expect(note.lastModified > originalDate)
        #expect(viewModel.lastModified > originalDate)
    }
    
    @Test func getTime() {
        let testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15, hour: 14, minute: 30))!
        
        let viewModel = NoteViewModel()
        viewModel.lastModified = testDate
        
        let timeString = viewModel.getTime()
        #expect(timeString.contains("2:30") || timeString.contains("14:30"))
    }
    
    @Test func getDateToday() {
        let viewModel = NoteViewModel()
        viewModel.lastModified = Date.now
        
        let dateString = viewModel.getDate()
        #expect(dateString == "Today")
    }
    
    @Test func getDateNotToday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
        
        let viewModel = NoteViewModel()
        viewModel.lastModified = yesterday
        
        let dateString = viewModel.getDate()
        #expect(dateString != "Today")
        #expect(dateString.count > 0)
    }
    
    @Test func syncChangesNoUpdate() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        let context = ModelContext(container)
        
        let note = Note(
            name: "Test Note",
            content: "Content",
            color: "blue",
            isPinned: false,
            lastModified: .now
        )
        context.insert(note)
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        
        let originalName = viewModel.titleField
        viewModel.syncChanges(context)
        
        #expect(viewModel.titleField == originalName)
    }
    
    @Test func initializationDefaults() {
        let viewModel = NoteViewModel()
        
        #expect(viewModel.noteItem == nil)
        #expect(viewModel.titleField == "")
        #expect(viewModel.contentField == "")
        #expect(viewModel.noteColor == "blue")
        #expect(viewModel.isPinned == false)
        #expect(!viewModel.changingColor)
        #expect(!viewModel.isEditing)
        #expect(!viewModel.isShowingHeader)
        #expect(viewModel.lastModified.distance(to: .now) < 1)
    }
    
    @Test func updateLastModified() {
        let note = Note(
            name: "Title",
            content: "Content",
            color: "blue",
            isPinned: false,
            lastModified: Date(timeIntervalSinceNow: -100)
        )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(note)
        
        let originalDate = note.lastModified
        let originalViewModelDate = viewModel.lastModified
        
        viewModel.updateLastModified()
        
        #expect(viewModel.lastModified > originalViewModelDate)
        #expect(note.lastModified > originalDate)
        #expect(viewModel.lastModified.distance(to: .now) < 1)
    }
}
