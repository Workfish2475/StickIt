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
    
    @FocusState private var hasFocus
    
    @State private var scrollOffset: CGFloat = 0
    @State private var selection: TextSelection? = nil
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    init(noteItem: Note? = nil) {
        self.noteItem = noteItem
        let viewModel = NoteViewModel()
        if let noteItem = noteItem {
            viewModel.setNote(noteItem)
        }
        _viewModel = State(initialValue: viewModel)
    }
    
    private var viewColor: Color {
        return Color(name: viewModel.noteColor)
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                titleSection
                
                Group {
                    if viewModel.isEditing {
                        textEditingViewPrototype
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
            
            .sensoryFeedback(.impact, trigger: viewModel.isEditing)
            .navigationBarBackButtonHidden(true)
            .background(viewColor.opacity(0.6))
            .animation(.easeIn, value: viewModel.isEditing)
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbarBackground(
                scrollOffset < 50 ? .visible : .hidden,
                for: .navigationBar
            )
            
            .toolbarBackground(
                viewColor.opacity(0.6),
                for: .navigationBar
            )
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                    }
                    
                    .tint(.primary)
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
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isEditing {
                        editingView
                    }
                }

                ToolbarItemGroup(placement: .keyboard) {
                    keyboardToolbar
                }
                
                ToolbarItem (placement: .keyboard) {
                    Button {
                        dismissKeyboard()
                        viewModel.isEditing.toggle()
                    } label: {
                        Image(systemName: "arrow.down")
                            .fontWeight(.bold)
                    }
                    
                    .tint(viewColor)
                }
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
                .foregroundStyle(.primary)
                .onSubmit {
                    viewModel.updateTitle()
                }
            Text("Last modified \(viewModel.getDate()) at \(viewModel.getTime())")
                .font(.caption.bold())
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
                 .foregroundColor(.primary)
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
                        .fill(Color(viewColor.opacity(0.8)))
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
    
    //FIXME: Some issue going on with dismissing the keyboard will cause it to comeback then dismiss
    var textEditingViewPrototype: some View {
        ScrollViewReader { proxy in
            UIKitTextView(
                "",
                text: $viewModel.contentField,
                selectedRange: $selectedRange,
                keyboardToolbar: keyboardToolbar.eraseToAnyView()
            )
            
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(viewColor.opacity(0.8)))
            )
            .padding()
            .onChange(of: viewModel.contentField) {
                proxy.scrollTo("textEditor", anchor: .bottom)
            }
        }
    }

    
    private var keyboardToolbar: some View {
        HStack (spacing: 10) {
            Button {
                
            } label: {
                Image(systemName: "textformat")
                    .fontWeight(.bold)
            }
            
            Button {
                let cursorLocation = selectedRange.location
                
                if let stringIndex = viewModel.contentField.index(
                    viewModel.contentField.startIndex,
                    offsetBy: cursorLocation,
                    limitedBy: viewModel.contentField.endIndex)
                {
                    let insertion = "\n[ ] "
                    viewModel.contentField.insert(contentsOf: insertion, at: stringIndex)
                    
                    let newCursorLocation = cursorLocation + insertion.count
                    selectedRange = NSRange(location: newCursorLocation, length: 0)
                }
            } label: {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
            }
            
            Button {
                
            } label: {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .fontWeight(.bold)
            }
            
            Button {
                
            } label: {
                Image(systemName: "link")
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button {
                dismissKeyboard()
                viewModel.isEditing.toggle()
            } label: {
                Image(systemName: "arrow.down")
                    .fontWeight(.bold)
            }
        }
        
        .tint(viewColor)
        .padding(.horizontal)
    }
    
    private var markdownPresentation: some View {
        Markdown(markdownText: $viewModel.contentField, viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .id(viewModel.contentField)
            .padding()
            .foregroundStyle(.primary)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(viewColor.opacity(0.8)))
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
