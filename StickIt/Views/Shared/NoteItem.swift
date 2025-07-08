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
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(name: noteItem.color))
                            )
                    }
                }
                    
                .padding()
                .frame(minWidth: 350)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(name: noteItem.color).opacity(0.6))
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
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    Text(noteItem.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(getTimeString(noteItem))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                ScrollView (.vertical, showsIndicators: false) {
                    MarkdownRenderer(input: .constant(noteItem.content), alignment: .leading)
                }
                
                .frame(height: geo.size.height * 0.35)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .disabled(true)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(name: noteItem.color).opacity(0.8))
                )
                
            }
            
            .foregroundStyle(textColor.color)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(name: noteItem.color).opacity(0.6))
            )
        }
    }
}


