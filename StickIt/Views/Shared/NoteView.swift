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
    @FocusState private var changingTitle
    
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showingHeaderView: Bool = false
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    @AppStorage("textColor") private var textColor: TextColor = .black
    
    init(noteItem: Note? = nil) {
        self.noteItem = noteItem
        let viewModel = NoteViewModel()
        if let noteItem = noteItem {
            viewModel.setNote(noteItem)
        } else {
            viewModel.noteColor = Color.namedColors[Int.random(in: 0..<Color.namedColors.count)].color.description
        }
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                titleSection
                
                Group {
                    if viewModel.isEditing {
                        textEditingView
                    } else {
                        markdownView
                    }
                }
                
                .frame(minHeight: geo.size.height * 0.9, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onTapGesture {
                    withAnimation {
                        viewModel.isEditing.toggle()
                        selectedRange = NSRange(location: viewModel.contentField.count, length: 0)
                        hasFocus = true
                    }
                }
                
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
                viewModel.updateLastModified()
                viewModel.saveNote(context)
            }
            
            .sensoryFeedback(.impact, trigger: viewModel.isEditing)
            .navigationBarBackButtonHidden(true)
            .background(viewModel.viewColor.opacity(0.6))
            .animation(.easeIn, value: viewModel.isEditing)
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbarBackground(
                scrollOffset < 50 ? .visible : .hidden,
                for: .navigationBar
            )
            
            .toolbarBackground(
                viewModel.viewColor.opacity(0.6),
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
                    
                    .tint(textColor.color)
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
                            .foregroundColor(textColor.color)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isEditing || changingTitle {
                        editingView
                    }
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
                .foregroundStyle(textColor.color)
                .focused($changingTitle)
                .onSubmit {
                    viewModel.updateTitle()
                }
            
            Text("Last Modified \(viewModel.getDate()) at \(viewModel.getTime())")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        .padding([.horizontal])
    }
    
    private var editingView: some View {
        Button {
            viewModel.isEditing = false
            changingTitle = false
            viewModel.saveNote(context)
         } label: {
             Text("Done")
                 .foregroundStyle(textColor.color)
                 .fontWeight(.bold)
         }
    }
    
    var textEditingView: some View {
        ScrollViewReader { proxy in
            UIKitTextView(
                "",
                text: $viewModel.contentField,
                selectedRange: $selectedRange,
                keyboardToolbar: keyboardToolbar.eraseToAnyView(),
                color: viewModel.viewColor
            )
            
            .focused($hasFocus)
            .roundedBackground(color: viewModel.viewColor, opacity: 0.8)
            .onChange(of: viewModel.contentField) {
                proxy.scrollTo("textEditor", anchor: .bottom)
            }
        }
    }
    
    private var keyboardToolbar: some View {
        HStack (spacing: 10) {
            Menu {
                ForEach(1...6, id: \.self){ idx in
                    Button {
                        let item = Array(repeating: "#", count: idx).joined() + " "
                        addContent(item)
                        showingHeaderView.toggle()
                    } label: {
                        Text("Heading \(idx)")
                            .font(headerFont(for: idx))
                    }
                }
            } label: {
                Image(systemName: "textformat")
                    .fontWeight(.bold)
            }
            
            Button {
                addContent("[ ] ")
            } label: {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
            }
            
            Button {
                addContent("```\t```")
            } label: {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .fontWeight(.bold)
            }
            
            Button {
                addContent("[]()")
            } label: {
                Image(systemName: "link")
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button {
                viewModel.isEditing.toggle()
            } label: {
                Image(systemName: "arrow.down")
                    .fontWeight(.bold)
            }
        }
        
        .tint(scheme == .dark ? .white : .black)
        .padding(.horizontal)
    }
    
    private var markdownView: some View {
        MarkdownRenderer(input: $viewModel.contentField, alignment: .leading, backgroundColor: viewModel.viewColor, viewModel: viewModel)
            .roundedBackground(color: viewModel.viewColor)
    }
    
    private func headerFont(for level: Int) -> Font {
        switch level {
            case 1:
                return .largeTitle.bold()
            case 2:
                return .title.bold()
            case 3:
                return .title2.bold()
            case 4:
                return .title3
            case 5:
                return .headline
            case 6:
                return .subheadline
            default:
                return .body
        }
    }
    
    private func addContent(_ content: String) {
        let cursorLocation = selectedRange.location
        if let stringIndex = viewModel.contentField.index(
            viewModel.contentField.startIndex,
            offsetBy: cursorLocation,
            limitedBy: viewModel.contentField.endIndex
        ) {
            viewModel.contentField.insert(contentsOf: content, at: stringIndex)
            let newCursorLocation = cursorLocation + content.count
            selectedRange = NSRange(location: newCursorLocation, length: 0)
        }
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

#Preview ("Empty View") {
    NavigationStack {
        NoteView.init(noteItem: nil)
    }
}
