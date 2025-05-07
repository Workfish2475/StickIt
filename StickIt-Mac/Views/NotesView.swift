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
                    textEditingView()
                        .frame(maxWidth: .infinity)
                } else {
                    markdownView()
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
                editingTools()
            }
            
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                previewTools()
            }
        }
    }
    
    func previewTools() -> some View {
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
                Image(systemName: "pin.fill")
                    .font(.headline)
            }
            
            .disabled(viewModel.noteItem == nil)
            
            Button {
                viewModel.deleteNote(context)
            } label: {
                Image(systemName: "trash.fill")
                    .font(.headline)
            }
            
            .disabled(viewModel.noteItem == nil)
            
            Button {
                viewModel.saveNote(context)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
            }
        }
    }
    
    func editingTools() -> some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "h.square.fill")
                    .font(.headline)
            }
            
            Button {
                
            } label: {
                Image(systemName: "hammer.fill")
                    .font(.headline)
            }
            
            Button {
                
            } label: {
                Image(systemName: "link")
                    .font(.headline)
            }
            
            Button {
                
            } label: {
                Image(systemName: "checkmark.square.fill")
                    .font(.headline)
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
    
    func textEditingView() -> some View {
        TextEditor(text: $viewModel.contentField)
            .padding()
            .font(.body)
            .textEditorStyle(.plain)
            .submitLabel(.done)
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .scrollIndicators(.hidden)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
            .onSubmit {
                viewModel.updateContent()
            }
    }
    
    func markdownView() -> some View {
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
}

#Preview {
    NotesView(noteItem: .placeholder)
        .frame(minWidth: 400, idealWidth: 800, minHeight: 400, idealHeight: 800)
}

#Preview {
    NotesView(noteItem: .placeholder).editingTools()
}
