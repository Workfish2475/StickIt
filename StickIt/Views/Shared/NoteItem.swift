//
//  NoteItem.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/20/25.
//

import SwiftUI

struct NoteItem: View {
    
    let noteItem: Note
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(noteItem.name)")
                .font(.title3.bold())
            Text("\(getTimeString(noteItem))")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(name: noteItem.color))
                
                Markdown(markdownText: noteItem.content, limit: true)
                    .scaleEffect(0.75)
                    .multilineTextAlignment(.leading)
                    .frame(maxHeight: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(true)
            }
        }
        
        .padding()
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(name: noteItem.color).opacity(0.9).gradient)
        )
    }
    
    func getTimeString(_ noteItem: Note) -> String {
        let lastModified = noteItem.lastModified
        
        if Calendar.current.isDateInToday(lastModified) {
            return "\(lastModified.formatted(.dateTime.hour().minute()))"
        } else {
            return "\(lastModified.formatted(.dateTime.month().day().year()))"
        }
    }
}
