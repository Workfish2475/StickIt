//
//  NoteView.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//
import SwiftUI

struct NoteView: View {
    
    var noteItem: Note? = nil
    
    @Environment(\.colorScheme) private var scheme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    var body: some View {
        ScrollView {
            VStack (spacing: 5) {
                HStack {
                    TextField("New Note", text: $viewModel.titleField)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .onSubmit {
                            viewModel.updateTitle()
                        }
                    Image(systemName: "pin.fill")
                        .foregroundStyle(viewModel.isPinned ? .red : .gray)
                        .disabled(viewModel.noteItem == nil)
                        .onTapGesture {
                            viewModel.updatePinned()
                        }
                }
                
                .padding([.top, .horizontal])
                
                Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                    .font(.footnote.bold())
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            textEditingView()
            controlPanel()
        }
        
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            viewModel.updateLastModified()
            viewModel.saveNote(context)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(name: viewModel.noteColor).opacity(0.6))
        .toolbarBackground(Color(name: viewModel.noteColor).opacity(0.6), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("", selection: $viewModel.noteColor) {
                        ForEach(Color.namedColors, id: \.name) { namedColor in
                            Text(namedColor.name.capitalized)
                                .tag(namedColor.name)
                        }
                    }
                } label: {
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 3)
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color(name: viewModel.noteColor))
                }
            }
        }
        
        .task {
            if let note = noteItem {
                viewModel.setNote(note)
            }
        }
        
        //TODO: Works for now, but we should move away from it to something more elegant.
        .onDisappear() {
            viewModel.saveNote(context)
        }
    }
    
    func controlPanel() -> some View {
        HStack {
            Button (role: .destructive) {
                viewModel.deleteNote(context)
                dismiss()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            .disabled(viewModel.noteItem == nil)
            
            Spacer()
            
            Button {
                viewModel.saveNote(context)
                dismiss()
            } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
            }
            .tint(.green)
        }
        
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .font(.headline)
    }
    
    func textEditingView() -> some View {
        TextEditor(text: $viewModel.contentField)
            .padding()
            .textEditorStyle(.plain)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(minHeight: 550)
            .submitLabel(.done)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
            .onSubmit {
                viewModel.updateContent()
            }
    }
}

#Preview {
    NoteView()
}
