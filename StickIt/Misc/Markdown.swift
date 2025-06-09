//
//  Markdown.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/17/25.
//

import SwiftUI

struct Markdown: View {
    
    @Binding var markdownText: String
    @State var viewModel: NoteViewModel?
    
    var limit: Bool? = false
    
    @State private var markdownLines: [String] = []
    
    var body: some View {
        VStack (alignment: .leading, spacing: 4) {
            
            let linesToShow = limit == true ? Array(markdownLines.prefix(3)) : markdownLines
            
            ForEach(linesToShow.indices, id: \.self) { index in
                let line = parseLine(markdownLines[index])
                
                switch line {
                    case .header(_):
                        headerView(markdownLines[index])
                    case .checkbox:
                        checkboxView(markdownLines[index], index)
                    case .link:
                        linkView(markdownLines[index])
                    case .codeBlock:
                        codeBlockView(markdownLines[index])
                    case .paragraph:
                        Text(markdownLines[index])
                        .font(.body)
                    default:
                        Text(markdownLines[index])
                            .font(.body)
                }
            }
            
            Spacer()
        }
        
        //Move this to an init
        .onAppear() {
            markdownLines = markdownText.components(separatedBy: .newlines)
        }
    }
    
    private func parseLine(_ line: String) -> LineType {
        do {
            let headerPattern = try Regex("^(#+)\\s+")
            let checkboxPattern = try Regex("^\\[( |x)\\]")
            let codeBlockPattern = try Regex("^```[a-zA-Z]*")
            let linkPattern = try Regex("\\[.*?\\]\\(.*?\\)")

            if let match = line.firstMatch(of: headerPattern) {
                let level = match.output.count
                return .header(level)
            }

            if line.firstMatch(of: checkboxPattern) != nil {
                return .checkbox(checked: false, label: "")
            }

            if line.firstMatch(of: codeBlockPattern) != nil {
                return .codeBlock
            }

            if line.firstMatch(of: linkPattern) != nil {
                return .link(text: "", url: "")
            }

        } catch {
            print("Regex error: \(error.localizedDescription)")
        }

        return .paragraph
    }

    private func linkView(_ line: String) -> some View {
        if let firstIdx = line.firstIndex(of: "("),
           let lastIdx = line.firstIndex(of: ")"),
           let titleFirstIdx = line.firstIndex(of: "["),
           let titleLastIdx = line.firstIndex(of: "]") {

            let title = String(line[titleFirstIdx...titleLastIdx]).dropFirst().dropLast()
            var link = String(line[firstIdx...lastIdx]).dropFirst().dropLast()

            if !link.hasPrefix("https://") && !link.hasPrefix("http://") {
                link = "https://" + link
            }

            if let url = URL(string: String(link)) {
                return AnyView(
                    Link(destination: url) {
                        Label(title, systemImage: "safari")
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.2))
                            )
                            .fontWeight(.bold)
                    }
                )
            }
        }

        return AnyView(Text(line))
    }
    
    private func checkboxView(_ line: String, _ index: Int) -> some View {
        if let openBracket = line.firstIndex(of: "["), let closeBracket = line.firstIndex(of: "]") {
            let item = line[line.index(after: openBracket)]
            let textStartIndex = line.index(after: closeBracket)
            let itemText = String(line[textStartIndex...]).trimmingCharacters(in: .whitespaces)
            
            return AnyView(
                HStack (alignment: .top) {
                    Image(systemName: item == "x" ? "checkmark.square.fill" : "square")
                        .onTapGesture {
                            var newLine = line
                            newLine.replaceSubrange(openBracket...closeBracket, with: item == "x" ? "[ ]" : "[x]")
                            updateLine(newLine, index)
                        }
                    
                    Text("\(itemText)")
                        .fontWeight(.medium)
                        .foregroundStyle(item == "x" ? .secondary : .primary)
                        .strikethrough(item == "x")
                }
            )
        }
        
        return AnyView(EmptyView())
    }
    
    private func updateLine(_ str: String, _ index: Int) {
        withAnimation {
            markdownLines[index] = str
        }
        
        markdownText = markdownLines.joined(separator: "\n")
        guard let viewModel else {
            return
        }
        
        viewModel.updateContent()
    }
    
    private func headerView(_ line: String) -> some View {
        let headerLevel = line.prefix(while: {$0 == "#"}).count
        let headerText = line.dropFirst(headerLevel).trimmingCharacters(in: .whitespaces)
        
        let font: Font = {
            switch headerLevel {
                case 1:
                    return .largeTitle.bold()
                case 2:
                    return .title.bold()
                case 3:
                    return .title2.bold()
                case 4:
                    return .title3.bold()
                default:
                    return .headline.bold()
            }
        }()
        
        return Text(headerText)
            .font(font)
            .padding(.top, 5)
    }
    
    private func codeBlockView(_ line: String) -> some View {
        var textContent = line
        textContent.removeAll(where: {$0 == "`"})
        
        return Text(textContent)
            .font(.system(size: 15, weight: .semibold, design: .monospaced))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.black.opacity(0.2))
            )
    }
}

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
    
    /// TODO: Could probably implement a better regex rule for detecting multiple lines of code.
    let codeBlockPattern = try! Regex("^```[a-zA-Z]*")
    let linkPattern = try! Regex("\\[.*?\\]\\(.*?\\)")
    
    let checkboxPatternProto = try! Regex<(Substring, Substring, Substring)>(#"\[( |x)\]\s*(.*)"#)
    let linkPatternProto = try! Regex<(Substring, Substring, Substring)>(#"\[(.*?)\]\((.*?)\)"#)
    let linkDisplay = try! Regex("\\[.*?\\]")
    let linkURL = try! Regex("\\(.*?\\)")
    
    /// parses the input string into an array of MarkdownNodes depending on what rules are satisfied.
    ///
    /// - Parameter input: A string containing markdown formatted text to be processed
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
                    result.append(MarkdownNode(type: .codeBlock, content: strContent))
                    strContent.removeAll()
                    currentLineType = .unknown
                    
                } else {
                    strContent.append(line + "\n")
                }
                
            } else {
                
                if line.hasPrefix("```") {
                    /// Single line code block that we insert and move on from without setting currentLineType to .codeBlock
                    if line.hasSuffix("```") {
                        result.append(MarkdownNode(type: .codeBlock, content: line))
                    } else {
                        currentLineType = .codeBlock
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
                    result.append(MarkdownNode(type: .paragraph, content: line))
                }
            }
        }
        
        if currentLineType == .codeBlock && !strContent.isEmpty {
            result.append(MarkdownNode(type: .codeBlock, content: strContent))
        }
        
        return result
    }
}

struct MarkdownRenderer: View {
    
    var input: String = ""
    var parser: Parser = Parser()
    @State private var content: [MarkdownNode]
    
    init(input: String) {
        self.input = input
        _content = State(initialValue: parser.parse(input))
    }
    
    var body: some View {
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
                        }
                    }
                default:
                    Text(line.content)
            }
        }
    }
    
    func checkboxItem(_ node: MarkdownNode, _ checked: Bool,_ label: String, toggle: @escaping () -> Void) -> some View {
        Button (action: toggle) {
            Label(label, systemImage: checked ? "checkmark.square.fill" : "square")
        }
        
        .strikethrough(checked)
        .foregroundStyle(checked ? .secondary : .primary)
    }
    
    @ViewBuilder
    func linkItem(_ node: MarkdownNode, _ displayText: String, _ url: String) -> some View {
        if let validURL = URL(string: url) {
            Link(destination: validURL) {
                Label(displayText, systemImage: "safari")
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.regularMaterial)
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
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .padding()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func headerItem(_ node: MarkdownNode, _ level: Int) -> some View {
        Text(node.content.dropFirst(level))
            .font(headerFont(for: level))
    }
    
    private func headerFont(for level: Int) -> Font {
        switch level {
        case 1: return .largeTitle.bold()
        case 2: return .title.bold()
        case 3: return .title2.bold()
        case 4: return .title3
        case 5: return .headline
        case 6: return .subheadline
        default: return .body
        }
    }
}

#Preview ("Markdown") {
    Markdown(markdownText: .constant("\(Note.self.placeholder.content)"))
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
}

#Preview ("Markdown Renderer") {
    NavigationStack {
        ScrollView {
            MarkdownRenderer(input: Note.placeholder.content)
        }
        
        .frame(width: 150, height: 150)
        .navigationTitle("Markdown Renderer")
    }
}
