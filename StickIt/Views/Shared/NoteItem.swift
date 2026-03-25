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
    @AppStorage("textColor") private var textColor: TextColor = .black

    var body: some View {
        smallTitle
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
                
            } preview: {
                VStack (alignment: .leading) {
                    Text(noteItem.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(getTimeString(noteItem))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .opacity(0)
                    
                    ScrollView (.vertical, showsIndicators: false) {
                        MarkdownRenderer(input: .constant(noteItem.content), alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                }
                    
                .padding()
                .frame(minWidth: 350)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(name: noteItem.color))
                .foregroundStyle(.white)
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
    
    
    private var smallTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(noteItem.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Spacer()

                if noteItem.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text(getTimeString(noteItem))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
        
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(name: noteItem.color))
        )
        
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        
        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
        .foregroundStyle(.white)
    }
}


