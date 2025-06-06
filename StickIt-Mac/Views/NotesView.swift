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
    @Environment(\.dismissWindow) private var closeWindow
    @Environment(\.modelContext) private var context
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    @State private var updatingTitle: Bool = false
    
    @Namespace private var animation
    
    init(noteItem: Note? = nil) {
        self.noteItem = noteItem
        let viewModel = NoteViewModel()
        
        if let noteItem = noteItem {
            viewModel.setNote(noteItem)
        } else {
            viewModel.titleField = "Untitled Note"
        }
        
        _viewModel = State(initialValue: viewModel)
    }
    
    private var noteColor: Color {
        Color(name: viewModel.noteColor)
    }
    
    var body: some View {
        ScrollView (.vertical) {
            VStack (spacing: 0) {
                Spacer()
                    .frame(height: 120)
                
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
            
            .containerRelativeFrame(.vertical)
        }
        
        .ignoresSafeArea(edges: .top)
        
        .safeAreaInset(edge: .top) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Title", text: $viewModel.titleField)
                            .font(.title3.bold())
                            .textFieldStyle(.plain)
                        Text("Last Modified \(getTimeString)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    previewTools
                        .buttonStyle(.borderless)
                }
                
                Divider()
                
                editingTools
                    .buttonStyle(.bordered)
            }
            
            .padding()
            .background(.regularMaterial)
            .ignoresSafeArea(edges: .top)
        }
        
        .background(noteColor.opacity(0.5))
        
        .sheet(isPresented: $updatingTitle) {
            TextField(viewModel.titleField, text: $viewModel.titleField)
                .textFieldStyle(.plain)
        }
    }
    
    private var previewTools: some View {
        HStack (alignment: .center) {
            Picker("", selection: $viewModel.noteColor) {
                ForEach(Color.namedColors, id: \.name) { namedColor in
                    Text(namedColor.name.capitalized)
                        .tag(namedColor.name)
                }
            }
            
            Button {
                manageWindow()
            } label: {
                Label(viewModel.isPinned ? "Unpin" : "Pin", systemImage: "pin.fill")
            }
            
            .disabled(viewModel.noteItem == nil)
            .help("Pin/Unpin")
            
            Divider()
                .frame(height: 10)
            
            Button (role: .destructive) {
                viewModel.deleteNote(context)
            } label: {
                Label("Trash", systemImage: "trash")
                    .fontWeight(.bold)
            }
            
            .disabled(viewModel.noteItem == nil)
            .help("Delete Note")
            
            if viewModel.isEditing {
                Button {
                    withAnimation {
                        viewModel.saveNote(context)
                    }
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .fontWeight(.bold)
                }
                
                .help("Save note changes")
            }
        }
    }
    
    private var editingTools: some View {
        HStack {
            Button {
                addContent("#")
            } label: {
                Label("Heading", systemImage: "textformat")
            }
            
            .help("Heading")
            
            Button {
                addContent("```\t```")
            } label: {
                Label("Code Block", systemImage: "hammer")
            }
            
            .help("Code Block")
            
            Button {
                addContent("[]()")
            } label: {
                Label("Link", systemImage: "link")
            }
            
            .help("Link")
            
            Button {
                addContent("[ ]")
            } label: {
                Label("Checkbox", systemImage: "checkmark.square")
            }
            
            .help("Checkbox")
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
    
    // MARK: - Open a new window if not open, or close if already open.
    private func manageWindow() -> Void {
        viewModel.updatePinned()
        
        guard let noteItem = viewModel.noteItem else {
            return
        }
        
        if viewModel.isPinned {
            openWindow(value: noteItem)
        } else {
            closeWindow(value: noteItem)
        }
    }
    
    private func addContent(_ content: String) -> Void {
        viewModel.contentField.append(contentsOf: content)
    }
}

struct TitleEditView: View {
    
    @Binding var noteTitle: String
    
    var body: some View {
        TextField(noteTitle, text: $noteTitle)
            .textFieldStyle(.plain)
    }
}

#Preview {
    NotesView(noteItem: .placeholder)
        .frame(minWidth: 450, idealWidth: 800, minHeight: 400, idealHeight: 800)
        .padding(.top)
}
