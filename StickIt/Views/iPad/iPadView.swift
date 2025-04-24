//
//  iPadView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/20/25.
//

import SwiftUI
import SwiftData

struct iPadView: View {
    
    @Query private var notes: [Note]
    @Namespace private var namespace
    @State private var showingEntry: Bool = false
    @Environment(\.colorScheme) private var scheme
    
    var pinnedNotes: [Note] {
        return notes.filter { $0.isPinned }
    }
    
    var generalNotes: [Note] {
        return notes.filter { !$0.isPinned }
    }
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            ScrollView {
                if (!pinnedNotes.isEmpty) {
                    noteSection("Pinned", pinnedNotes)
                }
                
                if (!generalNotes.isEmpty) {
                    noteSection("General", generalNotes)
                }
            }
            
            buttonView()
                .matchedTransitionSource(id: "newNote", in: namespace)
        }
        
        .navigationTitle("StickIt")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationDestination(for: Note.self) { note in
            NoteView(noteItem: note)
                .navigationTransition(.zoom(sourceID: note.persistentModelID, in: namespace))
        }
    
        .navigationDestination(for: String.self) { id in
            if id == "newNote" {
                NoteView()
                    .navigationTransition(.zoom(sourceID: "newNote", in: namespace))
            }
        }
    }
    
    func buttonView() -> some View {
        NavigationLink(value: "newNote") {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .zIndex(1)
                .frame(width: 45, height: 45)
                .padding()
                .frame(alignment: .bottomTrailing)
        }
    }
    
    func noteSection(_ title: String ,_ noteItems: [Note]) -> some View {
        VStack (alignment: .leading) {
            Text("\(title)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            FlowLayout (spacing: 10, alignment: .leading) {
                ForEach(noteItems, id:\.persistentModelID){ note in
                    NavigationLink(value: note) {
                        NoteItem(noteItem: note)
                            .matchedTransitionSource(id: note.persistentModelID, in: namespace)
                            .frame(width: 275, height: 200)
                            .frame(maxWidth: 275, maxHeight: 200)
                    }
                }
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        .frame(maxWidth: .infinity)
        .padding()
    }
}


#Preview ("iPadView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)

    let context = container.mainContext

    let sampleNotes = [
        Note(name: "Shopping List", content: "# h1 Heading testing  \t\t\t\t\n\n\n\n\n\n", color: ".red", isPinned: false, lastModified: .now),
        Note(name: "Puppy", content: "testing testing testing ", color: ".green", isPinned: true, lastModified: .now),
        Note(name: "Work Progress", content: "testing testing testing\n\n\n\n\n\n", color: "orange", isPinned: false, lastModified: .now),
        Note(name: "To Do", content: "Something goes here", color: "indigo", isPinned: false, lastModified: .now),
    ]

    for note in sampleNotes {
        context.insert(note)
    }

    return ContentView()
        .modelContainer(container)
}
