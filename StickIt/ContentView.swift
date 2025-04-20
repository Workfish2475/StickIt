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
    
    // MARK: - gets current device type (phone or pad)
    var currentDevice: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    var body: some View {
    NavigationStack {
        deviceView()
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
    
    @ViewBuilder
    func deviceView() -> some View {
        if currentDevice == .phone {
            iPhoneView()
        } else {
            iPadView()
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
