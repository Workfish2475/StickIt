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
                    HStack(spacing: 0) {
                        textEditingView()
                            .frame(maxWidth: .infinity)
                        
                        editingTools()
                            .frame(width: 60)
                            .frame(minWidth: 30)
                    }
                } else {
                    HStack (spacing: 0) {
                        markdownView()
                            .onTapGesture {
                                withAnimation {
                                    viewModel.isEditing.toggle()
                                }
                            }
                        
                        previewTools()
                            .frame(width: 60)
                            .frame(minWidth: 30)
                    }
                }

                Spacer()
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        .background(noteColor.opacity(0.6))
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Spacer()
                
                if (viewModel.isEditing) {
                    Text("Done")
                        .fontWeight(.bold)
                        .padding()
                        .background(noteColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            withAnimation {
                                viewModel.isEditing.toggle()
                            }
                        }
                }
            }
        }
    }
    
    func previewTools() -> some View {
        VStack (spacing: 10) {
            Button {
                viewModel.updatePinned()
                openWindow(value: viewModel.noteItem!)
            } label: {
                Image(systemName: "pin.fill")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(viewModel.noteItem == nil ? 0.5 : 0.8))
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            .disabled(viewModel.noteItem == nil)
            
            Divider()
            
            Picker("", selection: $viewModel.noteColor) {
                ForEach(Color.namedColors, id: \.name) { namedColor in
                    Text(namedColor.name.capitalized)
                        .tag(namedColor.name)
                }
            }
            
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 30, height: 30)
            .contentShape(Circle())
            .overlay {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            .background {
                Circle()
                    .fill(Color.white.opacity(0.2))
            }
          
            Divider()
            
            Button {
                viewModel.deleteNote(context)
            } label: {
                Image(systemName: "trash.fill")
                    .font(.headline)
                    .foregroundStyle(Color.red)
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            .disabled(viewModel.noteItem == nil)
            
            Divider()
            
            Button {
                viewModel.saveNote(context)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(Color.green)
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        
        .matchedGeometryEffect(id: "toolbar", in: animation)
        
        .tint(.white)
        .buttonStyle(.plain)
        .padding()
        
        .background (
            noteColor.opacity(0.8)
        )
        
        .clipShape(.rect(
            topLeadingRadius: 10,
            bottomLeadingRadius: 10,
            bottomTrailingRadius: 0,
            topTrailingRadius: 0
        ))
    }
    
    func getTimeString() -> String {
        let lastModified = viewModel.lastModified
        
        if (Calendar.current.isDateInToday(lastModified)) {
            return "\(viewModel.lastModified.formatted(.dateTime.hour().minute()))"
        } else {
            return "\(viewModel.lastModified.formatted(.dateTime.day().month().year()))"
        }
    }
    
    func editingTools() -> some View {
        VStack {
            Group {
                Image(systemName: "h.square.fill")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                Divider()
                
                Image(systemName: "h.square.fill")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                Divider()
                
                Image(systemName: "h.square.fill")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                Divider()
                
                Image(systemName: "h.square.fill")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        
        .matchedGeometryEffect(id: "toolbar", in: animation)
        .padding()
        
        .background (
            noteColor.opacity(0.8)
        )
        
        .clipShape(.rect(
            topLeadingRadius: 10,
            bottomLeadingRadius: 10,
            bottomTrailingRadius: 0,
            topTrailingRadius: 0
        ))
    }
    
    func labelItem(_ title: String,_ image: String) -> some View {
        VStack {
            Image(systemName: "\(image)")
                .imageScale(.large)
            Text("\(title)")
                .font(.subheadline)
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
