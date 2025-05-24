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
        
        .navigationTitle("StickIt")
        .onChange(of: selectedNote) {
            addingNote = false
        }
    }
}

// MARK: - Test AppKit implementation
struct MyAppKitView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let myView = NSView()
        myView.wantsLayer = true
        myView.layer?.backgroundColor = NSColor.red.cgColor

        DispatchQueue.main.async {
            if let window = myView.window {
                let toolbar = NSToolbar(identifier: "MyToolbar")
                toolbar.delegate = context.coordinator
                window.toolbar = toolbar
            }
        }

        return myView
    }

    // Read docs for this function
    func updateNSView(_ nsView: NSView, context: Context) {
        // You could update the toolbar here if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, NSToolbarDelegate {
        func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return [.toggleSidebar, .flexibleSpace]
        }

        func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return [.toggleSidebar, .showColors]
        }

        func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            
            return item
        }

        //Need to implement action here.
        @objc func toggleAction() {
            print("Toggle toolbar item tapped")
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MyAppKitView_Previews : PreviewProvider {
    static var previews: some View {
        MyAppKitView()
    }
}
