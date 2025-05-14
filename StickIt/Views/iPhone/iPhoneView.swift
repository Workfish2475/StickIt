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
    @Environment(\.modelContext) private var context
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            VStack {
                Group {
                    let pinnedNotes = notes.filter({ $0.isPinned })
                    let generalNotes = notes.filter({ !$0.isPinned })
                    
                    if pinnedNotes.isEmpty && generalNotes.isEmpty {
                        ContentUnavailableView {
                            Label("No Notes Found", systemImage: "note.text")
                                .foregroundStyle(Color.accentColor.gradient)
                        } description: {
                            Text("Add your first note by tapping the plus button in the bottom right corner.")
                        }
                    } else {
                        ScrollView {
                            if (!pinnedNotes.isEmpty) {
                                noteSection("Pinned", pinnedNotes)
                            }
                            
                            if (!generalNotes.isEmpty) {
                                noteSection("General", generalNotes)
                            }
                        }
                    }
                }
                
                .frame(maxWidth: .infinity)
            }
            
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
                .shadow(color: Color.primary.opacity(0.1), radius: 9, x: 0, y: 5)
        }
    }
    
    func noteSection(_ title: String ,_ noteItems: [Note]) -> some View {
        LazyVGrid (columns: columns, spacing: 10) {
            Section {
                ForEach(noteItems, id: \.persistentModelID) { note in
                    NavigationLink(value: note) {
                        NoteItem(noteItem: note)
                            .matchedTransitionSource(id: note.persistentModelID, in: namespace)
                            .frame(width: 160, height: 175)
                            .frame(maxWidth: 175, maxHeight: 175)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 1)
                    }
                }
            } header: {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 1)
        )
        .padding()
        .frame(maxWidth: .infinity)
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
