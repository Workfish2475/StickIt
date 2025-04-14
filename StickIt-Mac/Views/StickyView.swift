//
//  StickyView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/14/25.
//

import SwiftUI
import SwiftData

struct StickyView: View {
    
    var noteID: UUID
    
    @State var noteItem: Note? = nil
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("\(noteItem != nil ? noteItem!.name : "Untitled Note")")
                .font(.title.bold())
                .padding(.top, 0)
            Text("Last modified \(viewModel.getTime())")
                .font(.subheadline)
            
            TextEditor(text: $viewModel.contentField)
                .padding()
                .font(.body)
                .tint(.white)
                .textEditorStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color(name: viewModel.noteColor).opacity(0.8))
                )
            
            Spacer()
        }
        
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(name: viewModel.noteColor).opacity(0.6)
        )
        
        .task {
            getNote()
            
            if let noteItem = noteItem {
                viewModel.setNote(noteItem)
            }
        }
        
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first(where: { $0.title == "Note View" }) {
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.hasShadow = true
                    window.standardWindowButton(.closeButton)?.isHidden = false
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true
                    window.level = .floating
                }
            }
        }
    }
    
    func getNote() -> Void {
        var descriptor = FetchDescriptor<Note>()
        
        descriptor.predicate = #Predicate {
            $0.id == noteID
        }
        
        do {
            noteItem =  try context.fetch(descriptor).first
        } catch {
            fatalError("Failed to fetch note: \(error)")
        }
    }
}

#Preview ("StickyView") {
    StickyView(noteID: .init())
        .frame(minWidth: 250, idealWidth: 300, minHeight: 200, idealHeight: 300)
}
