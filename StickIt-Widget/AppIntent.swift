//
//  AppIntent.swift
//  StickIt-Widget
//
//  Created by Alexander Rivera on 4/14/25.
//

import WidgetKit
import AppIntents
import SwiftData

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "StickIt-Widget"
    static var description: IntentDescription = IntentDescription("Select a note to display")

    @Parameter(title: "Selected Note")
    var noteItem: Note?
}

extension Note: AppEntity {
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Note"
    static var defaultQuery = NoteQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct NoteQuery: EntityQuery {
    let context: ModelContext

    init() {
        do {
            let container = try ModelContainer(for: Note.self, configurations: .init(isStoredInMemoryOnly: false))
            self.context = ModelContext(container)
        } catch {
            fatalError("Error creating ModelContainer: \(error)")
        }
    }
    
    func entities(for identifiers: [Note.ID]) async throws -> [Note] {
        let fetchDescriptor = FetchDescriptor<Note>()
        let notes = try context.fetch(fetchDescriptor)
        return notes.filter { identifiers.contains($0.id) }
    }

    
    func suggestedEntities() async throws -> [Note] {
        let fetchDescriptor = FetchDescriptor<Note>()
        let notes = try context.fetch(fetchDescriptor)
        return notes
    }
    
    func defaultResult() async -> Note? {
        return Note.placeholder
    }
}
