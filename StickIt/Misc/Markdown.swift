//
//  Markdown.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/17/25.
//

import SwiftUI

enum LineType: Equatable, Hashable {
    case header(Int)
    case paragraph
    case codeBlock
    case listItem
    case blockQuote
    case link(text: String, url: String)
    case checkbox(checked: Bool, label: String)
    case unknown
}

struct MarkdownNode: Hashable {
    var type: LineType
    var content: String
    
    mutating func toggleCheckbox() {
        if case let .checkbox(checked, label) = type {
            type = .checkbox(checked: !checked, label: label)
        }
    }
}

struct Parser {
    
    let headerPattern = try! Regex("^(#+)\\s+")
    let checkboxPattern = try! Regex("^\\[( |x)\\]")
    let checkboxPatternProto = try! Regex<(Substring, Substring, Substring)>(#"\[( |x)\]\s*(.*)"#)
    let linkPatternProto = try! Regex<(Substring, Substring, Substring)>(#"\[(.*?)\]\((.*?)\)"#)
    let linkDisplay = try! Regex("\\[.*?\\]")
    let linkURL = try! Regex("\\(.*?\\)")
    
    /// parses the input string into an array of MarkdownNodes depending on what rules are satisfied.
    ///
    /// - Parameter input: A string containing markdown formatted text to be processed
    /// - Returns: returns an array of MarkdownNode
    ///
    func parse(_ input: String) -> [MarkdownNode] {
        var result: [MarkdownNode] = []
        let lines = input.components(separatedBy: .newlines)
        var strContent: String = ""
        var currentLineType: LineType = .unknown
        
        for line in lines {
            
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if currentLineType == .codeBlock {
                /// Check if we're at the end of the code block and reset strContent and currentLineType or append if not.
                if trimmed.contains("```") {
                    strContent.append(line)
                    result.append(MarkdownNode(type: .codeBlock, content: strContent))
                    strContent.removeAll()
                    currentLineType = .unknown
                } else {
                    strContent.append(line + "\n")
                }
                
            } else {
                
                if line.contains("```") {
                    
                    currentLineType = .codeBlock
                    strContent.append(line + "\n")
                    
                    if line.hasPrefix("```") {
                        continue
                    }
                    
                    if line.hasSuffix("```") {
                        result.append(MarkdownNode(type: .codeBlock, content: strContent))
                    }
                    
                    /// Single line code block that we insert and move on from without setting currentLineType to .codeBlock
                    if line.hasSuffix("```") {
                        result.append(MarkdownNode(type: .codeBlock, content: line))
                    } else {
                        strContent.append(line + "\n")
                    }
                    
                } else if line.firstMatch(of: headerPattern) != nil {
                    let headerLevel = line.prefix(while: {$0 == "#"}).count
                    result.append(MarkdownNode(type: .header(headerLevel), content: line))
                } else if let match = line.firstMatch(of: checkboxPatternProto) {
                    let (_, state, label) = match.output
                    let isChecked = state == "x"
                    result.append(MarkdownNode(type: .checkbox(checked: isChecked, label: String(label)), content: line))
                } else if let match = line.firstMatch(of: linkPatternProto) {
                    let (_, displayText, urlText) = match.output
                    result.append(MarkdownNode(type: .link(text: String(displayText), url: String(urlText)), content: line))
                } else {
                    if currentLineType == .codeBlock {
                        strContent.append(line + "\n")
                    } else {
                        result.append(MarkdownNode(type: .paragraph, content: line))
                    }
                }
            }
        }
        
        
        if currentLineType == .codeBlock && !strContent.isEmpty {
            result.append(MarkdownNode(type: .codeBlock, content: strContent))
        }
        
        return result
    }
    
    /// Takes collection of nodes and returns a string representation
    ///
    /// - Parameter  nodes: An array of MarkdownNodes
    ///
    func translateToText(_ nodes: [MarkdownNode]) -> String {
        return nodes.map { node in
            switch node.type {
                case .checkbox(let checked, let label):
                    return "[\(checked ? "x" : " ")] \(label)"
                default:
                    return node.content
            }
        }.joined(separator: "\n")
    }
}

struct MarkdownRenderer: View {
    
    @Binding var input: String
    
    var alignment: HorizontalAlignment
    let parser: Parser
    var compactMode: Bool
    var viewModel: NoteViewModel?
    
    @State private var content: [MarkdownNode]
    
    @Environment(\.modelContext) private var context
    
    init(input: Binding<String>, alignment: HorizontalAlignment = .leading, backgroundColor: Color = .white, compactMode: Bool = false, viewModel: NoteViewModel? = nil) {
        self.parser = Parser()
        self.alignment = alignment
        self.compactMode = compactMode
        self.viewModel = viewModel
        
        _input = input
        _content = State(initialValue: parser.parse(input.wrappedValue))
    }
    
    var body: some View {
        VStack (alignment: alignment) {
            ForEach($content, id: \.self) { $line in
                switch line.type {
                    case .header(let level):
                        headerItem(line, level)
                    case .codeBlock:
                        codeItem(line)
                    case .link(let text, let url):
                        linkItem(line, text, url)
                    case .checkbox(let checked, let label):
                        checkboxItem(line, checked, label) {
                            withAnimation {
                                line.toggleCheckbox()
                                input = parser.translateToText(content)
                                viewModel?.saveNote(context)
                            }
                        }
                    default:
                        Text(line.content)
                }
            }
        }
    }
    
    func checkboxItem(_ node: MarkdownNode, _ checked: Bool,_ label: String, toggle: @escaping () -> Void) -> some View {
        Button(action: toggle) {
            HStack (alignment: .top) {
                Image(systemName: checked ? "checkmark.square.fill" : "square")

                Text(label)
                    .strikethrough(checked)
            }
            
            .fontWeight(.medium)
        }
        
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func linkItem(_ node: MarkdownNode, _ displayText: String, _ url: String) -> some View {
        if let validURL = URL(string: url) {
            Link(destination: validURL) {
                Label(displayText, systemImage: "safari")
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                    )
                    .fontWeight(.bold)
            }
        } else {
            Text(displayText)
        }
    }
    
    func codeItem(_ node: MarkdownNode) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(node.content.dropFirst(3).dropLast(3))
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func headerItem(_ node: MarkdownNode, _ level: Int) -> some View {
        Text(node.content.dropFirst(level))
            .font(headerFont(for: level))
            .padding(.bottom, 5)
    }
    
    func headerFont(for level: Int) -> Font {
        if compactMode {
            return .title3.bold()
        }
        
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
    
    static func readOnly(_ input: String) -> MarkdownRenderer {
        return .init(input: .constant(input), alignment: .leading)
    }
}

struct RoundedBackground: ViewModifier {
    
    var color: Color
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(opacity))
            )
            .padding()
    }
}

extension View {
    func roundedBackground(color: Color = .white, opacity: Double = 0.8) -> some View {
        modifier(RoundedBackground(color: color, opacity: opacity))
    }
}

#Preview ("Markdown Renderer") {
    NavigationStack {
        ScrollView {
            MarkdownRenderer(input: .constant(Note.placeholder.content), alignment: .leading)
                .padding()
        }
        .navigationTitle("Markdown Renderer")
    }
}
