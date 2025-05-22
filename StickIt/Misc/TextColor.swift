//
//  TextColor.swift
//  StickIt
//
//  Created by Alexander Rivera on 5/21/25.
//

import SwiftUI

enum TextColor: String, CaseIterable {
    case black
    case white
    case system
    
    var id: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        case .system:
            return .primary
        }
    }
}

struct TextColorPicker: View {
    
    @AppStorage("textColor") private var textColor = TextColor.black
    
    var body: some View {
        List {
            ForEach(TextColor.allCases, id: \.self){ color in
                HStack {
                    Text("\(color.rawValue.capitalized)")
                    
                    Spacer()
                    
                    if color == textColor {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)
                    }
                }
                
                .contentShape(Rectangle())
                .onTapGesture {
                    textColor = color
                }
            }
        }
        
        .navigationTitle("Text Color")
    }
}


#Preview ("TextColorPicker") {
    NavigationStack {
        TextColorPicker()
    }
}
