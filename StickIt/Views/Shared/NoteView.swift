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
    
    @State private var scrollOffset: CGFloat = 0
    
    @State var text = ""
    @State private var selection: TextSelection? = nil
    
    @FocusState private var hasFocus
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    init(noteItem: Note? = nil) {
        self.noteItem = noteItem
        let viewModel = NoteViewModel()
        if let noteItem = noteItem {
            viewModel.setNote(noteItem)
        }
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack (alignment: .topTrailing) {
                ScrollView {
                    VStack(spacing: 5) {
                        titleSection
                        
                        Group {
                            if viewModel.isEditing {
                                textEditingView   
                            } else {
                                markdownPresentation
                            }
                        }
                        
                        .frame(minHeight: geo.size.height * 0.9, maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .onTapGesture {
                            withAnimation {
                                viewModel.isEditing.toggle()
                            }
                        }
                    }
                    
                    .frame(minHeight: geo.size.height * 0.9, alignment: .top)
                    .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .named("scroll")).minY)
                            }
                        )
                }
                
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
                
                .onTapGesture {
                    dismissKeyboard()
                    viewModel.updateLastModified()
                    viewModel.saveNote(context)
                }
            }
            
            .sensoryFeedback(.impact, trigger: viewModel.isEditing)
            .navigationBarBackButtonHidden(true)
            .background(Color(name: viewModel.noteColor).opacity(0.6))
            .animation(.easeIn, value: viewModel.isEditing)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                    }
                    
                    .tint(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
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
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isEditing {
                        editingView
                    }
                }

                keyboardToolbar
            }
        }
        
        .onDisappear() {
            viewModel.saveNote(context)
        }
    }
    
    private var titleSection: some View {
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
        
        .padding([.horizontal])
    }
    
    private var editingView: some View {
        Button {
             viewModel.saveNote(context)
             UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
         } label: {
             Text("Done")
                 .foregroundColor(.white)
                 .fontWeight(.bold)
         }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var textEditingView: some View {
        ScrollViewReader { proxy in
            TextEditor(text: $viewModel.contentField, selection: $selection)
                .focused($hasFocus)
                .id("textEditor")
                .tint(.white)
                .font(.body)
                .textEditorStyle(.plain)
                .foregroundStyle(.white)
                .submitLabel(.return)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
                )
                .padding()
                
                .onSubmit {
                    viewModel.updateContent()
                }
                
                .onChange(of: viewModel.contentField.last) {
                    proxy.scrollTo("textEditor", anchor: .bottom)
                }
        }
    }
    
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Text("Work in progress...")
        }
    }
    
    private var markdownPresentation: some View {
        Markdown(markdownText: $viewModel.contentField, viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .id(viewModel.contentField)
            .padding()
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color(name: viewModel.noteColor).opacity(0.8)))
            )
            .padding()
    }
}

// Credit: https://medium.com/@felipaugsts/detect-scroll-position-swiftui-86ff2b8fda82
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

#Preview {
    NavigationStack {
        NoteView(noteItem: .placeholder)
    }
}
