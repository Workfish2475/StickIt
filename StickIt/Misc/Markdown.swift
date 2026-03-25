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

struct MarkdownNode: Identifiable, Hashable {
    let id = UUID()
    var type: LineType
    var attributedContent: AttributedString
    var rawContent: String
    
    mutating func toggleCheckbox() {
        if case let .checkbox(checked, label) = type {
            type = .checkbox(checked: !checked, label: label)
        }
    }
}

struct Parser {
    func parse(_ input: String) -> [MarkdownNode] {
            let lines = input.components(separatedBy: .newlines)
            var nodes: [MarkdownNode] = []
            
            var isInsideCodeBlock = false
            var codeAccumulator: [String] = []

            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Check if a code block
                if trimmed.hasPrefix("```") {
                    
                    let cleanedUpStr = trimmed.replacingOccurrences(of: "`", with: "")
                    
                    if isInsideCodeBlock {

                        let codeContent = codeAccumulator.joined(separator: "\n")
                        
                        nodes.append(
                            MarkdownNode(
                                type: .codeBlock,
                                attributedContent: AttributedString(codeContent),
                                rawContent: "```\n\(codeContent)\n```"
                            )
                        )
                        
                        codeAccumulator.removeAll()
                        isInsideCodeBlock = false
                    } else {
                        isInsideCodeBlock = true
                    }
                    
                    continue
                }

                if isInsideCodeBlock {
                    codeAccumulator.append(line)
                } else {
                    nodes.append(parseRegularLine(line))
                }
            }
            
            if !codeAccumulator.isEmpty {
                let codeContent = codeAccumulator.joined(separator: "\n")
                nodes.append(MarkdownNode(type: .codeBlock, attributedContent: AttributedString(codeContent), rawContent: "```\n\(codeContent)\n```"))
            }

            return nodes
        }

        private func parseRegularLine(_ line: String) -> MarkdownNode {
            var type: LineType = .paragraph
            var cleanText = line
            
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                type = .header(level)
                cleanText = String(line.dropFirst(level).trimmingCharacters(in: .whitespaces))
            } else if line.hasPrefix("[ ]") || line.hasPrefix("[x]") {
                let isChecked = line.hasPrefix("[x]")
                let label = String(line.dropFirst(3).trimmingCharacters(in: .whitespaces))
                type = .checkbox(checked: isChecked, label: label)
                cleanText = label
            }

            let attributed: AttributedString
            do {
                attributed = try AttributedString(markdown: cleanText, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            } catch {
                attributed = AttributedString(cleanText)
            }
            
            return MarkdownNode(type: type, attributedContent: attributed, rawContent: line)
        }

    func translateToText(_ nodes: [MarkdownNode]) -> String {
        nodes.map { node in
            if case let .checkbox(checked, label) = node.type {
                return "[\(checked ? "x" : " ")] \(label)"
            }
            return node.rawContent
        }.joined(separator: "\n")
    }
}

struct MarkdownRenderer: View {
    @Binding var input: String
    var alignment: HorizontalAlignment = .leading
    let parser = Parser()
    var viewModel: NoteViewModel?
    
    @State private var content: [MarkdownNode]
    @Environment(\.modelContext) private var context

    init(input: Binding<String>, alignment: HorizontalAlignment = .leading, viewModel: NoteViewModel? = nil) {
        self._input = input
        self.alignment = alignment
        self.viewModel = viewModel
        self._content = State(initialValue: Parser().parse(input.wrappedValue))
    }

    var body: some View {
        VStack(alignment: alignment, spacing: 10) {
            ForEach(content) { node in
                switch node.type {
                case .checkbox(let checked, let label):
                    checkboxItem(node, checked, label)
                case .header(let level):
                    Text(node.attributedContent)
                        .font(headerFont(for: level))
                case .codeBlock:
                    codeItem(node)
                default:
                    Text(node.attributedContent)
                        .tint(.accentColor)
                }
            }
        }
        
        .onChange(of: input) { _, newValue in
            content = parser.parse(newValue)
        }
    }
    
    private func codeItem(_ node: MarkdownNode) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(node.attributedContent)
                .font(.system(size: 14, design: .monospaced))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func checkboxItem(_ node: MarkdownNode, _ checked: Bool, _ label: String) -> some View {
        Button {
            if let index = content.firstIndex(where: { $0.id == node.id }) {
                withAnimation(.snappy) {
                    content[index].toggleCheckbox()
                    input = parser.translateToText(content)
                    viewModel?.saveNote(context)
                }
            }
        } label: {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: checked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(checked ? Color.accentColor : .secondary)
                
                Text(node.attributedContent)
                    .strikethrough(checked)
                    .foregroundStyle(checked ? .secondary : .primary)
            }
        }
        .buttonStyle(.plain)
    }
    
    func headerFont(for level: Int) -> Font {
        switch level {
            case 1: return .largeTitle.bold()
            case 2: return .title.bold()
            case 3: return .title2.bold()
            default: return .headline
        }
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
