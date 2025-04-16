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
        VStack (alignment: .leading) {
            Text("\(viewModel.titleField)")
                .font(.title.bold())
                
                .tint(.white)
                .foregroundStyle(.white)
            
            Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            TextEditor(text: $viewModel.contentField)
                .padding()
                .font(.body)
                .tint(.white)
                .foregroundStyle(.white)
                .textEditorStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color(name: viewModel.noteColor).opacity(0.8))
                )
            
            Spacer()
        }
        
        .padding([.bottom, .horizontal])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(name: viewModel.noteColor).opacity(0.6)
        )
        
        .task {
            viewModel.setNote(noteItem)
        }
        
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first(where: { $0.title == noteItem.name }) {
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.titleVisibility = .hidden
                    window.standardWindowButton(.closeButton)?.isHidden = false
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true
                    window.level = .normal
                }
            }
        }
    }
}

#Preview ("StickyView") {
    StickyView(noteItem: .placeholder)
        .frame(minWidth: 250, idealWidth: 300, minHeight: 200, idealHeight: 300)
}
