//
//  StickItApp.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/12/25.
//

import SwiftUI
import SwiftData

@main
struct StickItApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Note.self)
        }
    }
}
