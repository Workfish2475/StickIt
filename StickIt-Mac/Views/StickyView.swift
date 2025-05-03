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
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        GeometryReader { geo in
            VStack (alignment: .leading) {
                HStack (alignment: .top) {
                    VStack (alignment: .leading, spacing: 2) {
                        TextField("", text: $viewModel.titleField)
                            .textFieldStyle(.plain)
                            .font(.title3.bold())
                        
                        Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.updatePinned()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.square.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    .buttonStyle(.plain)
                }
                
                ZStack (alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill((Color(name: viewModel.noteColor).opacity(0.6)))
                    
                    if (viewModel.isEditing) {
                        editingView()
                    } else {
                        presentationView()
                            .onTapGesture {
                                withAnimation {
                                    viewModel.isEditing.toggle()
                                }
                            }
                    }
                }
                
                Spacer()
            }
            
            .padding([.bottom, .horizontal])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(name: viewModel.noteColor).opacity(0.8).gradient)
        }
        
        .task {
            viewModel.setNote(noteItem)
        }
        
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first(where: { $0.title == noteItem.name }) {
                    window.isOpaque = false
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
    
    func editingView() -> some View {
        TextEditor(text: $viewModel.contentField)
            .padding()
            .font(.body)
            .textEditorStyle(.plain)
    }
    
    func presentationView() -> some View {
        Markdown(markdownText: $viewModel.contentField, viewModel: viewModel)
            .padding()
            .id(viewModel.contentField)
    }
}

#Preview ("StickyView") {
    StickyView(noteItem: .placeholder2)
        .frame(minWidth: 250, idealWidth: 300, minHeight: 200, idealHeight: 300)
}

#Preview ("StickyView Populated") {
    StickyView(noteItem: .placeholder)
        .frame(minWidth: 250, idealWidth: 300, minHeight: 200, idealHeight: 300)
}
