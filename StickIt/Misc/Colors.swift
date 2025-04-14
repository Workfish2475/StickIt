//
//  Colors.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftUI

extension Color {
    
    static let colorList: [Color] = [
        .red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .brown, .cyan, .mint, .teal
    ]
    
    static let namedColors: [(name: String, color: Color)] = [
        ("red", .red), ("orange", .orange), ("yellow", .yellow),
        ("green", .green), ("blue", .blue), ("indigo", .indigo),
        ("purple", .purple), ("pink", .pink), ("brown", .brown),
        ("cyan", .cyan), ("mint", .mint), ("teal", .teal)
    ]
    
    init(hex: String) {
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        guard hexString.count == 6, let hexValue = Int(hexString, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        let red = Double((hexValue >> 16) & 0xFF) / 255.0
        let green = Double((hexValue >> 8) & 0xFF) / 255.0
        let blue = Double(hexValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    init(name: String){
        let colorName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ".", with: "")
                .lowercased()
        
        switch colorName {
            case "red":
                self = .red
            case "orange":
                self = .orange
            case "yellow":
                self = .yellow
            case "green":
                self = .green
            case "blue":
                self = .blue
            case "indigo":
                self = .indigo
            case "purple":
                self = .purple
            case "pink":
                self = .pink
            case "brown":
                self = .brown
            case "cyan":
                self = .cyan
            case "mint":
                self = .mint
            case "teal":
                self = .teal
            default:
                self = .accentColor
        }
    }

    func getColorHex() -> String {
        if let components = self.cgColor?.components {
            
            let red = Int((components[0] * 255).rounded())
            let green = Int((components[1] * 255).rounded())
            let blue = Int((components[2] * 255).rounded())
            
            return String(format: "#%02X%02X%02X", red, green, blue)
        } else {
            return ""
        }
    }
}
