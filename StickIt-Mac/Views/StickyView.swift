//
//  StickyView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/14/25.
//

import SwiftUI
import SwiftData

struct StickyView: View {
    
    var noteItem: Note
    
    @State private var viewModel: NoteViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scene
    
    @Query private var note: [Note]
    
    init(noteItem: Note) {
        self.noteItem = noteItem
        
        _note = Query(filter: #Predicate<Note> { $0.id == noteItem.id}, animation: .default )
        
        let viewModel = NoteViewModel()
        viewModel.setNote(noteItem)
        _viewModel = State(initialValue: viewModel)
    }
    
    private var noteColor: Color {
        return Color(name: viewModel.noteColor)
    }
    
    var currentNoteItem: Note? {
        note.first
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack (spacing: 5) {
                HStack {
                    titleView
                
                    if ( viewModel.isEditing ) {
                        editingTools
                    }
                    
                    windowTools
                }

                .padding(.trailing)
                
                ScrollView (showsIndicators: false) {
                    contentArea()
                }
                
                .roundedBackground(color: noteColor)
                .onTapGesture {
                    withAnimation {
                        viewModel.isEditing.toggle()
                    }
                }
            }
            
            .foregroundStyle(.white)
            .background(
                noteColor.opacity(0.8)
            )
        }
        
        .onAppear {
//            NotificationCenter.default.addObserver(
//                forName: NSApplication.didBecomeActiveNotification,
//                object: nil,
//                queue: .main
//            ) { _ in
//                if let currentNote = currentNoteItem {
//                    viewModel.setNote(currentNote)
//                }
//            }
//            customizeWindow()
        }
        
        .onDisappear() {
            //NotificationCenter.default.removeObserver(self)
        }
    }
    
    @ViewBuilder
    func contentArea() -> some View {
        if viewModel.isEditing {
            editingView
        } else {
            markdownView
                .onDisappear() {
                    viewModel.syncChanges(context)
                }
        }
    }
    
    private var editingTools: some View {
        HStack (spacing: 10) {
            Button {
                viewModel.updatePinned()
                dismiss()
            } label: {
                Image(systemName: "h.circle.fill")
            }
            
            Divider()
                .frame(height: 10)
                .overlay(.white)
            
            Button {
                viewModel.saveNote(context)
                withAnimation {
                    viewModel.isEditing.toggle()
                }
            } label: {
                Image(systemName: "checkmark.app.fill")
            }
            
            Divider()
                .frame(height: 10)
                .overlay(.white)
            
            Button {

            } label: {
                Image(systemName: "link.circle.fill")
            }
            
        }
        
        .buttonStyle(.plain)
        .padding(5)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    private var windowTools: some View {
        HStack (spacing: 10) {
            Button {
                viewModel.updatePinned()
                dismiss()
            } label: {
                Image(systemName: "pin.fill")
            }
            
            
            Divider()
                .frame(height: 10)
                .overlay(.white)
            
            Button (role: .destructive) {
                
            } label: {
                Image(systemName: "trash.circle.fill")
            }
            
            Divider()
                .frame(height: 10)
                .overlay(.white)

            Button {
                //viewModel.saveNote(context)
                viewModel.isEditing.toggle()
            } label: {
                Image(systemName: viewModel.isEditing ? "pencil.circle.fill" : "magnifyingglass.circle.fill")
            }
        }
        
        .buttonStyle(.plain)
        .padding(5)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    private var titleView: some View {
        VStack (alignment: .leading, spacing: 2) {
            TextField("", text: $viewModel.titleField)
                .textFieldStyle(.plain)
                .font(.title2.bold())
                .onSubmit {
                    viewModel.updateLastModified()
                    //viewModel.syncChanges(context)
                }
            
            Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        .padding([.horizontal])
    }

    private var editingView: some View {
        TextEditor(text: $viewModel.contentField)
            .font(.title3)
            .textEditorStyle(.plain)
            .scrollIndicators(.never)
    }
    
    private var markdownView: some View {
        MarkdownRenderer(input: $viewModel.contentField)
    }
}

#Preview ("StickyView") {
    StickyView(noteItem: .placeholder2)
        .frame(minWidth: 250, idealWidth: 300, minHeight: 200, idealHeight: 300)
}

#Preview ("StickyView Populated") {
    StickyView(noteItem: .placeholder)
        .frame(minWidth: 250, idealWidth: 300, minHeight: 225, idealHeight: 225)
}
