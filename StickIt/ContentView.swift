//
//  ContentView.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var showingEntry: Bool = false
    @State private var showingSettings: Bool = false
    
    @State private var selectedNote: Note?
    
    @Environment(\.modelContext) private var context
    
    @AppStorage("appearance") private var appearance: Appearance = .system
    @AppStorage("showingNew") private var showingNew: Bool = true
    
    // MARK: - gets current device type (phone or pad)
    var currentDevice: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    var body: some View {
    NavigationStack {
        deviceView()
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
        
            .navigationDestination(item: $selectedNote) {note in
                NoteView(noteItem: note)
            }
        }
        
        .preferredColorScheme(appearance.colorScheme)
        
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        
        .sheet(isPresented: $showingNew) {
            NavigationStack {
                WhatsNew()
            }
        }
        
        .onOpenURL { url in
            guard let id = UUID(uuidString: url.lastPathComponent) else {
                print("Invalid UUID")
                return
            }

            if let note = fetchNote(id) {
                selectedNote = note
            }
        }
    }
    
    @ViewBuilder
    func deviceView() -> some View {
        if currentDevice == .phone {
            iPhoneView()
        } else {
            iPadView()
        }
    }
    
    private func fetchNote(_ id: UUID) -> Note? {
        
        var desc = FetchDescriptor<Note>()
        desc.predicate = #Predicate<Note> {
            $0.id == id
        }
        
        do {
            return try context.fetch(desc).first
        } catch {
            print("Error fetching note: \(error)")
            return nil
        }
    }
}
    
#Preview {
    let defaults = UserDefaults.standard
    //defaults.set(true, forKey: "showingNew")
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)

    let context = container.mainContext

    let sampleNotes = [
        Note(name: "Shopping List", content: "# h1 Heading testing", color: ".red", isPinned: false, lastModified: .now),
        Note(name: "Puppy", content: "testing testing testing", color: ".green", isPinned: true, lastModified: .now),
        Note(name: "Work Progress", content: "testing testing testing", color: "orange", isPinned: false, lastModified: .now),
        Note(name: "testing", content: "[ ] Something\n[ ] Another thing\n[ ] Last thing\n[ ] Done\n[ ] testing \n[ ] test", color: "red", isPinned: false, lastModified: .now),
    ]

    for note in sampleNotes {
        context.insert(note)
    }

    return ContentView()
        .modelContainer(container)
}
