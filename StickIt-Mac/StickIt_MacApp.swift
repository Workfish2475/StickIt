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
                .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
        }
        .windowStyle(.hiddenTitleBar)
        
        WindowGroup("Note View", for: Note.self) { $note in
            if let unwrappedNote = note {
                StickyView(noteItem: unwrappedNote)
                    .modelContainer(for: [Note.self])
                    .frame(minWidth: 250, minHeight: 200)
                    .navigationTitle(unwrappedNote.name)
            }
        }
        
        .defaultSize(CGSize(width: 240, height: 250))
        .windowStyle(.hiddenTitleBar)
        .windowLevel(.floating)
    }
}
