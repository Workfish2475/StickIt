//
//  NotesView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/12/25.
//

import SwiftUI

struct NotesView: View {
    
    var noteItem: Note? = nil
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var context
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    @Namespace private var animation
    
    init(noteItem: Note? = nil) {
        self.noteItem = noteItem
        let viewModel = NoteViewModel()
        
        if let noteItem = noteItem {
            viewModel.setNote(noteItem)
        }
        
        _viewModel = State(initialValue: viewModel)
    }
    
    private var noteColor: Color {
        Color(name: viewModel.noteColor)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack (spacing: 0) {
                HStack {
                    TextField ("New Note", text: $viewModel.titleField)
                        .font(.title.bold())
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .onSubmit {
                            viewModel.updateTitle()
                        }
                }
                
                .padding([.top, .horizontal])
                
                Text("Last Modified \(viewModel.getDate()) at \(viewModel.getTime())")
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                if viewModel.isEditing {
                    textEditingView
                        .frame(maxWidth: .infinity)
                    
                } else {
                    markdownView
                        .onTapGesture {
                            withAnimation {
                                viewModel.isEditing.toggle()
                            }
                        }
                }

                Spacer()
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        .background(noteColor.opacity(0.6))
        .toolbar {
            ToolbarItem (placement: .navigation) {
                editingTools
            }
            
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                previewTools
            }
        }
    }
    
    private var previewTools: some  View {
        HStack {
            Picker("", selection: $viewModel.noteColor) {
                ForEach(Color.namedColors, id: \.name) { namedColor in
                    Text(namedColor.name.capitalized)
                        .tag(namedColor.name)
                }
            }
            
            Button {
                viewModel.updatePinned()
                openWindow(value: viewModel.noteItem!)
            } label: {
                Label(viewModel.isPinned ? "Unpin" : "Pin", systemImage: "pin.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(viewModel.isPinned ? .red : .gray)
            }
            
            .disabled(viewModel.noteItem == nil)
            
            Divider()
            
            Button {
                viewModel.deleteNote(context)
            } label: {
                Label("Trash", systemImage: "trash.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
            
            .disabled(viewModel.noteItem == nil)
            
            Button {
                viewModel.saveNote(context)
            } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
        }
    }
    
    private var editingTools: some View {
        HStack {
            Button {
                
            } label: {
                Label("Heading", systemImage: "h.square.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
            
            Button {
                
            } label: {
                Label("Code Block", systemImage: "hammer.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
            
            Button {
                
            } label: {
                Label("Link", systemImage: "link")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
            
            Button {
                
            } label: {
                Label("Checkbox", systemImage: "checkmark.square.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
        }
        
        .disabled(!viewModel.isEditing)
    }
    
    var getTimeString: String {
        let lastModified = viewModel.lastModified
        
        if (Calendar.current.isDateInToday(lastModified)) {
            return "\(viewModel.lastModified.formatted(.dateTime.hour().minute()))"
        } else {
            return "\(viewModel.lastModified.formatted(.dateTime.day().month().year()))"
        }
    }
    
    var textEditingView: some View {
        TextEditor(text: $viewModel.contentField)
            .padding()
            .font(.body)
            .textEditorStyle(.plain)
            .submitLabel(.done)
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .scrollIndicators(.never)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
            .onSubmit {
                viewModel.updateContent()
            }
    }
    
    var markdownView: some View {
        Markdown(markdownText: $viewModel.contentField, viewModel: viewModel)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding()
            .multilineTextAlignment(.leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
            .foregroundStyle(.white)
    }
    
    //Open a new window if not open, or close if already open.
    private func manageWindow() -> Void {
        
    }
}

#Preview {
    NotesView(noteItem: .placeholder)
        .frame(minWidth: 400, idealWidth: 800, minHeight: 400, idealHeight: 800)
}
