//
//  Note.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftData
import SwiftUI

@Model
class Note {
    var id: UUID = UUID()
    var name: String = "None"
    var content: String = ""
    var color: String = "#007AFF"
    var isPinned: Bool = false
    var lastModified: Date = Date.now
    
    init(
        name: String,
        content: String,
        color: String,
        isPinned: Bool,
        lastModified: Date
    ) {
        self.id = UUID()
        self.name = name
        self.content = content
        self.color = color
        self.isPinned = isPinned
        self.lastModified = lastModified
    }
}
