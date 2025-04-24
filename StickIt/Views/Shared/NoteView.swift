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
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 5) {
                    VStack {
                        TextField("New Note", text: $viewModel.titleField)
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .onSubmit {
                                viewModel.updateTitle()
                            }
                        Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    .padding([.top, .horizontal])
                    
                    Group {
                        if viewModel.isEditing {
                            textEditingView()
                                .frame(minHeight: geo.size.height * 0.6, maxHeight: .infinity, alignment: .top)
                        } else {
                            markdownPresentation()
                                .frame(minHeight: geo.size.height * 0.6, maxHeight: .infinity, alignment: .top)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.isEditing.toggle()
                                    }
                                }
                        }
                    }
                }
                
                .frame(minHeight: geo.size.height, alignment: .top)
            }
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
            ToolbarItem (placement: .keyboard) {
                Button {
                    viewModel.isShowingHeader.toggle()
                } label: {
                    Image(systemName: "h.square.fill")
                        .fontWeight(.bold)
                }
                
                .popover(isPresented: $viewModel.isShowingHeader) {
                    HStack {
                        ForEach(1..<5) { num in
                            Button {
                                let addition = String(repeating: "#", count: num)
                                viewModel.contentField += "\n\(addition) "
                                viewModel.isShowingHeader.toggle()
                            } label: {
                                Image(systemName: "\(num).square.fill")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    
                    .padding()
                    .presentationCompactAdaptation(.popover)
                }
            }
            
            ToolbarItem (placement: .keyboard) {
                Button {
                    viewModel.contentField += "\n[ ]( )"
                } label: {
                    Image(systemName: "link.circle.fill")
                        .fontWeight(.bold)
                }
            }
            
            ToolbarItem (placement: .keyboard) {
                Button {
                    viewModel.contentField += "\n```\n\n```"
                } label: {
                    Image(systemName: "hammer.circle.fill")
                        .fontWeight(.bold)
                }
            }
            
            ToolbarItem (placement: .keyboard) {
                Button {
                    viewModel.contentField += "\n[ ] "
                } label: {
                    Image(systemName: "checkmark.square.fill")
                        .fontWeight(.bold)
                }
            }
            
            ToolbarItem {
                Menu {
                    Button {
                        viewModel.updatePinned()
                    } label: {
                        Label(viewModel.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                    }
                    
                    Picker("Color", selection: $viewModel.noteColor) {
                        ForEach(Color.namedColors, id: \.name) { namedColor in
                            Text(namedColor.name.capitalized)
                                .tag(namedColor.name)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Divider()
                    
                    Button (role: .destructive) {
                        viewModel.deleteNote(context)
                        
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    .disabled(viewModel.noteItem == nil)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
            if (viewModel.isEditing) {
                ToolbarItem (placement: .topBarTrailing)  {
                    Button {
                        viewModel.saveNote(context)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        withAnimation {
                            viewModel.isEditing.toggle()
                        }
                    } label: {
                        Text("Done")
                    }
                    
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        
        .task {
            if let note = noteItem {
                viewModel.setNote(note)
            }
        }
        
        .onDisappear() {
            viewModel.saveNote(context)
        }
    }
    
    func textEditingView() -> some View {
        TextEditor(text: $viewModel.contentField)
            .padding()
            .tint(.white)
            .font(.body)
            .textEditorStyle(.plain)
            .foregroundStyle(.white)
            .submitLabel(.return)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
            .onSubmit {
                viewModel.updateContent()
            }
    }
    
    func markdownPresentation() -> some View {
        Markdown(markdownText: viewModel.contentField)
            .id(viewModel.contentField)
            .padding()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
    }
}

#Preview {
    NoteView(noteItem: .placeholder)
}
