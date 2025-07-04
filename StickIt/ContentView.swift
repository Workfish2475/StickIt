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
    @AppStorage("appVersion") private var storedVersion: String = ""
    
    // MARK: - gets current device type (phone or pad)
    var currentDevice: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    var body: some View {
    NavigationStack {
        deviceView()
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
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
        
        .onAppear {
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
            if storedVersion != currentVersion {
                storedVersion = currentVersion
                showingNew = true
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
        Note(name: "Grocery List", content: "- Milk\n- Eggs\n- Bread\n- Spinach", color: "red", isPinned: false, lastModified: .now),
        Note(name: "Workout Plan", content: "🏋️ Monday: Chest\n🏃 Tuesday: Cardio\n🧘 Wednesday: Yoga", color: "orange", isPinned: true, lastModified: .now),
        Note(name: "Project Ideas", content: "- Habit Tracker app\n- SwiftUI Game\n- Markdown Notes", color: "green", isPinned: false, lastModified: .now),
        Note(name: "Reading List", content: "- Atomic Habits\n- Clean Architecture\n- The Pragmatic Programmer", color: "blue", isPinned: false, lastModified: .now),
        Note(name: "Work Tasks", content: "[ ] Fix bug #342\n[ ] Email John\n[ ] Review PRs", color: "gray", isPinned: true, lastModified: .now),
        Note(name: "Vacation Plans", content: "✈️ Book flights to Tokyo\n🏨 Reserve hotel\n🗺️ Make itinerary", color: "yellow", isPinned: false, lastModified: .now),
        Note(name: "Meeting Notes", content: "Discussed Q3 goals\nAssigned tasks to team\nFollow up on budget", color: "purple", isPinned: false, lastModified: .now),
        Note(name: "Daily Journal", content: "Felt productive today.\nFocused well during deep work sessions.", color: "pink", isPinned: false, lastModified: .now),
    ]

    for note in sampleNotes {
        context.insert(note)
    }

    return ContentView()
        .modelContainer(container)
}
