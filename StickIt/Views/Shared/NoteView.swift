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
    @State var selection = NSRange(location: 0, length: 0)
    
    @FocusState private var hasFocus
    
    @State private var viewModel: NoteViewModel = NoteViewModel()
    
    private var backgroundMaterial: some View {
        Group {
            if scrollOffset < -10 {
                Color.clear.background(.ultraThinMaterial)
            } else {
                Color.clear
            }
        }
    }
    
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
                    
                    .padding([.horizontal])
                    
                    Group {
                        if viewModel.isEditing {
                            textEditingView()
                                .frame(minHeight: geo.size.height * 0.8, maxHeight: .infinity, alignment: .top)
                        } else {
                            markdownPresentation()
                                .frame(minHeight: geo.size.height * 0.8, maxHeight: .infinity, alignment: .top)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.isEditing.toggle()
                                    }
                                    
                                    hasFocus.toggle()
                                }
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
            
            .ignoresSafeArea(.keyboard)
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
            
            .safeAreaInset(edge: .top) {
                titleBar()
            }
            
            .sensoryFeedback(.impact, trigger: viewModel.isEditing)
            
            .toolbarVisibility(.hidden, for: .navigationBar)
            .background(Color(name: viewModel.noteColor).opacity(0.6))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                        EmptyView()
                    }
                
                keyboardToolbar
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
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func textEditingView() -> some View {
        TextEditor(text: $viewModel.contentField)
            .focused($hasFocus)
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
    
    private func titleBar() -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "x.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.large)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            if viewModel.isEditing {
                Button {
                    viewModel.saveNote(context)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    withAnimation(.bouncy) {
                        viewModel.isEditing.toggle()
                    }
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(name: viewModel.noteColor))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                .transition(.move(edge: .trailing).combined(with: .opacity))
                
            } else {
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
                }
            }
        }
        
        .tint(Color(name: viewModel.noteColor))
        .padding()
        .animation(.bouncy, value: viewModel.isEditing)
        .background(backgroundMaterial)
    }
    
    private var keyboardToolbar: some ToolbarContent {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Button {
                        viewModel.isShowingHeader.toggle()
                    } label: {
                        Image(systemName: "h.square.fill")
                            .fontWeight(.bold)
                            .frame(width: 50, height: 35)
                            .foregroundStyle(.white)
                            .background(Capsule().fill(Color(name: viewModel.noteColor)))
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
                    
                    Button { viewModel.contentField += "\n[ ]( )" } label: {
                        Image(systemName: "link")
                            .fontWeight(.bold)
                            .frame(width: 50, height: 35)
                            .foregroundStyle(.white)
                            .background(Capsule().fill(Color(name: viewModel.noteColor)))
                    }

                    Button { viewModel.contentField += "\n```\n\n```" } label: {
                        Image(systemName: "hammer.fill").fontWeight(.bold)
                            .fontWeight(.bold)
                            .frame(width: 50, height: 35)
                            .foregroundStyle(.white)
                            .background(Capsule().fill(Color(name: viewModel.noteColor)))
                    }

                    Button { viewModel.contentField += "\n[ ] " } label: {
                        Image(systemName: "checkmark.square.fill")
                            .fontWeight(.bold)
                            .frame(width: 50, height: 35)
                            .foregroundStyle(.white)
                            .background(Capsule().fill(Color(name: viewModel.noteColor)))
                    }
                    
                    Spacer()
                    
                    Button { dismissKeyboard() } label: {
                        Image(systemName: "arrow.down")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.gray)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    
    func markdownPresentation() -> some View {
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
