//
//  TextColor.swift
//  StickIt
//
//  Created by Alexander Rivera on 5/21/25.
//

import SwiftUI

struct TextColorPicker: View {
    
    @State private var selection: String = "red"
    
    var body: some View {
        List {
            Picker("", selection: $selection) {
                Text("Something")
            }
        }
        
        .navigationTitle("Text Color")
    }
}
