//
//  ContentView.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Query private var notes: [Note]
    
    @State private var showingEntry: Bool = false
    @State private var showingSettings: Bool = false
    
    @State private var selectedNote: Note? = nil
    
    @Environment(\.colorScheme) private var scheme
    
    @Namespace private var namespace
    
    var pinnedNotes: [Note] {
        return notes.filter { $0.isPinned }
    }
    
    var regularNotes: [Note] {
        return notes.filter { !$0.isPinned }
    }
    
    // MARK: - gets current device type (phone or pad)
    var currentDevice: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    var adaptiveColumns: [GridItem] {
        if currentDevice == .pad {
            return Array(repeating: GridItem(.flexible()), count: 4)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 2)
        }
    }
    
    var itemSize: CGSize {
        if currentDevice == .pad {
            return CGSize(width: 275, height: 225)
        } else {
            return CGSize(width: 175, height: 175)
        }
    }
    
    var spacing: CGFloat {
        if currentDevice == .pad {
            return 20
        } else {
            return 10
        }
    }
    
    var body: some View {
    NavigationStack {
        ZStack (alignment: .bottomTrailing) {
            ScrollView {
                if (!pinnedNotes.isEmpty) {
                    LazyVGrid (columns: adaptiveColumns, spacing: spacing) {
                        Section {
                            ForEach(pinnedNotes, id: \.persistentModelID) { note in
                                NavigationLink(value: note) {
                                    noteItem(note)
                                        .matchedTransitionSource(id: note.persistentModelID, in: namespace)
                                        .frame(width: itemSize.width, height: itemSize.height)
                                }
                            }
                        } header: {
                            HStack {
                                Text("Pinned")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                if (!regularNotes.isEmpty) {
                    LazyVGrid (columns: adaptiveColumns, spacing: spacing) {
                        Section {
                            ForEach(regularNotes, id: \.persistentModelID) { note in
                                NavigationLink(value: note) {
                                    noteItem(note)
                                        .matchedTransitionSource(id: note.persistentModelID, in: namespace)
                                        .frame(width: itemSize.width, height: itemSize.height)
                                }
                            }
                        } header: {
                            HStack {
                                Text("General")
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
            
            .scrollIndicators(.hidden)
            .navigationTitle("StickIt")
            .toolbar {
                ToolbarItem (placement: .topBarTrailing) {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    func noteItem(_ noteItem: Note) -> some View {
        VStack(alignment: .leading) {
            Text("\(noteItem.name)")
                .font(.title3.bold())
            Text("\(getTimeString(noteItem))")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            ZStack (alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(name: noteItem.color))
                Text("\(noteItem.content)")
                    .font(.caption.bold())
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
        }
        
        .padding()
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(name: noteItem.color).opacity(0.8).gradient)
        )
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
    
    func getTimeString(_ noteItem: Note) -> String {
        let lastModified = noteItem.lastModified
        
        if Calendar.current.isDateInToday(lastModified) {
            return "\(lastModified.formatted(.dateTime.hour().minute()))"
        } else {
            return "\(lastModified.formatted(.dateTime.month().day().year()))"
        }
    }
}
    
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)

    let context = container.mainContext

    let sampleNotes = [
        Note(name: "Shopping List", content: "# h1 Heading testing", color: ".red", isPinned: false, lastModified: .now),
        Note(name: "Puppy", content: "testing testing testing", color: ".green", isPinned: true, lastModified: .now),
        Note(name: "Work Progress", content: "testing testing testing", color: "orange", isPinned: false, lastModified: .now),
        Note(name: "testing", content: "Something goes here", color: "red", isPinned: false, lastModified: .now),
    ]

    for note in sampleNotes {
        context.insert(note)
    }

    return ContentView()
        .modelContainer(container)
}
