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
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        EmptyView()
            .onAppear() {
                openNotes()
            }
    }
    
    private func openNotes() -> Void {
        for note in notes {
            openWindow(value: note)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

