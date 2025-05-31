//
//  ContentView.swift
//  StickIt-Mac
//
//  Created by Alexander Rivera on 4/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Query private var notes: [Note]
    @Namespace private var namespace
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var selectedNote: Note?
    @State private var addingNote = false
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                VisualEffectView(
                    material: .hudWindow,
                    blendingMode: .behindWindow,
                    emphasized: true,
                    alphaValue: 0.9
                )
                .ignoresSafeArea()
                
                List (selection: $selectedNote) {
                    Section ("Notes") {
                        ForEach(notes, id: \.persistentModelID) {note in
                            NavigationLink("\(note.name)", value: note)
                        }
                    }
                }
                
                .scrollContentBackground(.hidden)
                .toolbar(removing: .sidebarToggle)
            }
            
            .safeAreaInset(edge: .bottom){
                Button {
                    addingNote = true
                    selectedNote = nil
                } label: {
                    Label("New Task", systemImage: "plus")
                }
                
                .padding()
            }
            
            .navigationTitle("Notes")
            .navigationSplitViewColumnWidth(min: 150, ideal: 175)
            
        } detail: {
            if (addingNote) {
                NotesView()
                    .id("newNote")
            } else if let selectedNote = selectedNote {
                NotesView(noteItem: selectedNote)
                    .id(selectedNote.id)
            } else {
                ContentUnavailableView {
                    Label("Select a note", systemImage: "note.text")
                } description: {
                    Text("Or wait for iCloud to finish syncing")
                }
                
                .onTapGesture {
                    addingNote.toggle()
                }
            }
        }
        
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

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State = .active
    var emphasized: Bool = false
    var alphaValue: CGFloat = 1.0
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.isEmphasized = emphasized
        view.alphaValue = alphaValue
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
        nsView.isEmphasized = emphasized
        nsView.alphaValue = alphaValue
    }
}
