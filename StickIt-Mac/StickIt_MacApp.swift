//
//  StickIt_MacApp.swift
//  StickIt-Mac
//
//  Created by Alexander Rivera on 4/12/25.
//

import SwiftUI
import SwiftData

@main
struct StickIt_MacApp: App {
    
    @Query private var notes: [Note]
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Note.self])
        }
      
        WindowGroup("Note View", for: Note.self) { $note in
            if let unwrappedNote = note {
                StickyView(noteItem: unwrappedNote)
                    .modelContainer(for: [Note.self])
                    .frame(minWidth: 275, minHeight: 250)
                    .navigationTitle(unwrappedNote.name)
            }
        }
        
        .windowStyle(.hiddenTitleBar)
        .commands {
            SettingCommands()
        }
        
        Settings {
            SettingsView()
        }
    }
}

struct SettingCommands: Commands {
    var body: some Commands {
        CommandMenu("Settings") {
            Button ("Test Settings") {
                
            }
            
            .keyboardShortcut("n", modifiers: .command)
        }
        
    }
}

struct StickyWindowScene: View {
    @Environment(\.modelContext) private var context
    @Query private var notes: [Note]
    let noteID: Note.ID

    var note: Note? {
        notes.first(where: { $0.id == noteID })
    }

    var body: some View {
        if let note {
            StickyView(noteItem: note)
                .navigationTitle(note.name)
        } else {
            Text("Note not found")
        }
    }
}

// TODO: This needs to be moved into menu bar.
struct SettingsView: View {
    
    @State private var selection: Int = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section ("General") {
                    NavigationLink(destination: TextColorPicker()) {
                        Label("Text Color", systemImage: "character")
                    }
                    
                    NavigationLink(destination: TextColorPicker()) {
                        Label("Theme", systemImage: "moon")
                    }
                }
            }
        }
    }
}


struct AppearancePicker: View {
    var body: some View {
        Text("Appearance Picker")
    }
}

#Preview ("Settings View") {
    SettingsView()
}
