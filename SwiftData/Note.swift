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
        name: "Demo Note",
        content: """
            ## 📝 Things to Do
            [ ] Finish writing the proposal  
            [x] Buy groceries  
            [ ] Schedule meeting with team
            
            ## 🔗 Useful Link
            [Google](https://www.google.com)

            ## 💻 Code Snippet
            ```private func greet(name: String) {
                Console.log("Hello World!);
            }```

            ```private func greet(name: String) {
                Console.log("Hello World!);
            }```
            ## 🧠 Notes
            Remember to keep notes clear and organized. Use Markdown to highlight code, tasks, and references effectively.
            """,
        color: "indigo",
        isPinned: false,
        lastModified: Date.distantPast
    )
    
    static let placeholder2: Note = Note(
        name: "Daily Note",
        content: "[Yahoo](https://www.google.com)\n[Yahoo](https://www.google.com)\n[Yahoo](https://www.google.com)",
        color: "brown",
        isPinned: false,
        lastModified: Date.distantPast
    )
}


