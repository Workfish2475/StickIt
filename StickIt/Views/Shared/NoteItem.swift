//
//  NoteItem.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/20/25.
//

import SwiftUI

struct NoteItem: View {
    let noteItem: Note
    
    @Environment(\.modelContext) private var context

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 8) {
                Text(noteItem.name)
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(getTimeString(noteItem))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(name: noteItem.color))

                    ScrollView {
                        Markdown(markdownText: .constant(noteItem.content))
                            .id(noteItem.content)
                            .multilineTextAlignment(.leading)
                            .disabled(true)
                            .scaleEffect(0.8, anchor: .topLeading)
                            .font(.system(size: 14))
                            .padding()
                    }
                    
                    .scrollIndicators(.hidden)
                    
                }
                
                .frame(height: geo.size.height * 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            .padding()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(name: noteItem.color).opacity(0.8))
            )
        }
        
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contextMenu {
            Button {
                noteItem.isPinned.toggle()
            } label: {
                Label("Pin", systemImage: "pin.fill")
            }
            
            Divider()
            
            Button (role: .destructive) {
                context.delete(noteItem)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }

    func getTimeString(_ noteItem: Note) -> String {
        let lastModified = noteItem.lastModified

        if Calendar.current.isDateInToday(lastModified) {
            return lastModified.formatted(.dateTime.hour().minute())
        } else {
            return lastModified.formatted(.dateTime.month().day().year())
        }
    }
}


