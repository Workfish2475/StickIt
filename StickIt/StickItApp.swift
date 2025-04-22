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
    
//    @Environment(\.scenePhase) private var phase
//    @StateObject private var store = StoreKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Note.self)
//                .task(id: phase) {
//                    if phase == .active {
//                        await store.fetchProducts()
//                    }
//                }
        }
    }
}
