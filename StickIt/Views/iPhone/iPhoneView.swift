//
//  iPhoneView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/20/25.
//

import SwiftUI
import SwiftData

struct iPhoneView: View {
    
    @Query private var notes: [Note]
    @Namespace private var namespace
    @State private var showingEntry: Bool = false
    @Environment(\.colorScheme) private var scheme
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
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
            
            .frame(maxWidth: .infinity)
            
            buttonView()
                .matchedTransitionSource(id: "newNote", in: namespace)
        }
        
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
        LazyVGrid (columns: columns, spacing: 10) {
            Section {
                ForEach(noteItems, id: \.persistentModelID) { note in
                    NavigationLink(value: note) {
                        NoteItem(noteItem: note)
                            .matchedTransitionSource(id: note.persistentModelID, in: namespace)
                            .frame(width: 175, height: 175)
                    }
                }
            } header: {
                HStack {
                    Text("\(title)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
        }
        
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview ("iPhone Empty View") {
    ContentView()
}

#Preview ("iPhone Populated View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)

    let context = container.mainContext

    let sampleNotes = [
        Note(name: "Shopping List", content: "- Eggs \n- Milk\n- Bread", color: ".red", isPinned: false, lastModified: .now),
        Note(name: "Puppy", content: "This is a demo note for the puppy", color: ".green", isPinned: true, lastModified: .now),
        Note(name: "Work Progress", content: "Work demo note. Do stuff \n \n ", color: "orange", isPinned: false, lastModified: .now),
        Note(name: "testing", content: "Something goes here", color: "red", isPinned: false, lastModified: .now),
    ]

    for note in sampleNotes {
        context.insert(note)
    }

    return ContentView()
        .modelContainer(container)
}
