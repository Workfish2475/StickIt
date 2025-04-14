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
        
        WindowGroup("Note View", for: Note.ID.self) { $noteId in
            if let noteId {
                StickyView(noteID: noteId)
                    .modelContainer(for: [Note.self])
            }
        }
        
        .defaultSize(CGSize(width: 240, height: 250))
        .windowStyle(.hiddenTitleBar)
        .windowLevel(.floating)
    }
}
