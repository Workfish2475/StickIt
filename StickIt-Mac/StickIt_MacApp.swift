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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Note.self])
                .frame(minWidth: 550, idealWidth: 600, minHeight: 450, idealHeight: 800)
        }
        .windowStyle(.hiddenTitleBar)
      
        WindowGroup("Note View", for: Note.self) { $note in
            if let unwrappedNote = note {
                StickyView(noteItem: unwrappedNote)
                    .modelContainer(for: [Note.self])
                    .frame(minWidth: 275, minHeight: 250)
                    .navigationTitle(unwrappedNote.name)
            }
        }
        
        .defaultSize(CGSize(width: 250, height: 225))
        .windowResizability(.contentMinSize)
        .windowStyle(.hiddenTitleBar)
        .windowLevel(.floating)
        
        Settings {
            SettingsView()
        }
    }
}

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
