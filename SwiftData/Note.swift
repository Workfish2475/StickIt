//
//  Note.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftData
import SwiftUI

@Model
class Note: Codable {
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
    
    // MARK: - Codable conformance
    
    enum CodingKeys: String, CodingKey {
        case id, name, content, color, isPinned, lastModified
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        color = try container.decode(String.self, forKey: .color)
        isPinned = try container.decode(Bool.self, forKey: .isPinned)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(content, forKey: .content)
        try container.encode(color, forKey: .color)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(lastModified, forKey: .lastModified)
    }
    
    static let placeholder: Note = Note(
        name: "Shopping List",
        content: "#### Things to do \n[ ] something \n[ ] something \n###Code \n```private func something() {}```\n[google](https://www.google.com)\n# Something",
        color: "orange",
        isPinned: false,
        lastModified: Date.distantPast
    )
}


