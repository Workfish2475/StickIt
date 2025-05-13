//
//  StickyView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/14/25.
//

import SwiftUI
import SwiftData

//TODO: Needs to also write to the note on change
struct StickyView: View {
    
    var noteItem: Note
    
    @State private var viewModel: NoteViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // MARK: - Trying to get it to fetch on focus of window
    @Environment(\.scenePhase) private var schene
    
    init(noteItem: Note) {
        self.noteItem = noteItem
        let viewModel = NoteViewModel()
        viewModel.setNote(noteItem)
        _viewModel = State(initialValue: viewModel)
    }
    
    private var noteColor: Color {
        return Color(name: viewModel.noteColor)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack (spacing: 5) {
                HStack {
                    titleView
                    windowTools
                }
                
                ScrollView (showsIndicators: false) {
                    contentArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.isEditing.toggle()
                            }
                        }
                }
                
                .padding()
                .background(noteColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            }
            
            .foregroundStyle(.white)
            .background(
                noteColor.opacity(0.8)
            )
        }
        
        .onChange(of: context) {
            try? context.save()
        }

        
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first(where: { $0.title == noteItem.name }) {
                    window.isOpaque = true
                    window.titleVisibility = .hidden
                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true
                    window.level = .normal
                }
            }
        }
    }
    
    private var windowTools: some View {
        HStack (spacing: 10) {
            Button {
                viewModel.updatePinned()
                dismiss()
            } label: {
                Image(systemName: "pin.fill")
                    .padding(5)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 10)
                .overlay(.white)
            
            Button {
                viewModel.saveNote(context)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .padding(5)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        
        .buttonStyle(.borderless)
        .padding([.horizontal])
    }
    
    private var titleView: some View {
        VStack (alignment: .leading, spacing: 2) {
            TextField("", text: $viewModel.titleField)
                .textFieldStyle(.plain)
                .font(.title3.bold())
            
            Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        .padding([.horizontal])
    }
    
    @ViewBuilder
    func contentArea() -> some View {
        if viewModel.isEditing {
            editingView
        } else {
            markdownView
        }
    }
    
    private var editingView: some View {
        TextEditor(text: $viewModel.contentField)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textEditorStyle(.plain)
            .scrollIndicators(.never)
    }
    
    private var markdownView: some View {
        Markdown(markdownText: $viewModel.contentField, viewModel: viewModel)
            .frame(maxWidth: .infinity, alignment: .leading)
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
