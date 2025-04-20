//
//  NotesView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/12/25.
//

import SwiftUI

//TODO: Maybe implement something with a focusstate and then trigger save on focus state change
struct NotesView: View {
    
    var noteItem: Note? = nil
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var context
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                TextField ("New Note", text: $viewModel.titleField)
                    .font(.title.bold())
                    .textFieldStyle(.plain)
                    .onSubmit {
                        viewModel.updateTitle()
                    }
            }
            
            .padding([.top, .horizontal])
            
            Text("Last modified: \(viewModel.getDate()) at \(viewModel.getTime())")
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            TextEditor(text: $viewModel.contentField)
                .padding()
                .font(.body)
                .textEditorStyle(.plain)
                .submitLabel(.done) 
                .multilineTextAlignment(.leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
                )
                .padding()
                .onSubmit {
                    viewModel.updateContent()
                }
            
            Spacer()
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(name: viewModel.noteColor).opacity(0.6))
        .toolbar {
            ToolbarItem {
                Button {
                    viewModel.updatePinned()
                    openWindow(value: viewModel.noteItem!)
                } label: {
                    Label("Pin", systemImage: "pin.fill")
                        .foregroundStyle(viewModel.isPinned ? .red : .gray)
                        .labelStyle(.titleAndIcon)
                }
                
                
                .disabled(viewModel.noteItem == nil)
            }
            
            ToolbarItem {
                Picker("", selection: $viewModel.noteColor) {
                    ForEach(Color.namedColors, id: \.name) { namedColor in
                        Text(namedColor.name.capitalized)
                            .tag(namedColor.name)
                    }
                }
                .pickerStyle(.menu)
                .labelStyle(.iconOnly)
            }
            
            ToolbarItem {
                Button {
                    viewModel.deleteNote(context)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(viewModel.noteItem == nil ? .gray : Color.red)
                }
                
                .disabled(viewModel.noteItem == nil)
            }
            
            ToolbarItem {
                Button {
                    viewModel.saveNote(context)
                } label: {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(Color.green)
                }
            }
        }
        
        .task {
            if let noteItem = noteItem {
                viewModel.setNote(noteItem)
            }
        }
    }
    
    func getTimeString() -> String {
        let lastModified = viewModel.lastModified
        
        if (Calendar.current.isDateInToday(lastModified)) {
            return "\(viewModel.lastModified.formatted(.dateTime.hour().minute()))"
        } else {
            return "\(viewModel.lastModified.formatted(.dateTime.day().month().year()))"
        }
    }
}

#Preview {
    NotesView(noteItem: .placeholder)
        .frame(minWidth: 400, idealWidth: 800, minHeight: 400, idealHeight: 800)
}
