//
//  ContentView.swift
//  StickIt-Mac
//
//  Created by Alexander Rivera on 4/12/25.
//

import SwiftUI
import SwiftData


// TODO: This looks really bad. Simple, but in the bad way.
struct ContentView: View {

    @Query private var notes: [Note]
    @Namespace private var namespace
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var selectedNote: Note?
    @State private var addingNote = false
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        NavigationSplitView {
            List (selection: $selectedNote) {
                Section ("Notes") {
                    ForEach(notes, id: \.persistentModelID) {note in
                        NavigationLink("\(note.name)", value: note)
                    }
                }
            }
            
            .navigationTitle("Notes")
            .navigationSplitViewColumnWidth(min: 150, ideal: 175)
            .toolbar {
                ToolbarItem {
                    Button {
                        addingNote = true
                        selectedNote = nil
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            
        } detail: {
            if (addingNote) {
                NotesView()
                    .id("newNote")
            } else if let selectedNote = selectedNote {
                NotesView(noteItem: selectedNote)
                    .id(selectedNote.id)
            } else {
                Text("Select a note to view")
                    .onTapGesture {
                        addingNote.toggle()
                    }
            }
        }
        
        .toolbar(removing: .title)
        .onChange(of: selectedNote) {
            addingNote = false
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
