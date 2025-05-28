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
                return .checkbox
            }

            if line.firstMatch(of: codeBlockPattern) != nil {
                return .codeBlock
            }

            if line.firstMatch(of: linkPattern) != nil {
                return .link
            }

        } catch {
            print("Regex error: \(error.localizedDescription)")
        }

        return .paragraph
    }

    
    // TODO: Need to be able to just take input and infer destination. google.com, www.youtube.com, etc.
    private func linkView(_ line: String) -> some View {
        
        if let firstIdx = line.firstIndex(of: "("), let lastIdx = line.firstIndex(of: ")") {
            if let titleFirstIdx = line.firstIndex(of: "["), let titleLastIdx = line.firstIndex(of: "]") {
                let title = String(line[titleFirstIdx...titleLastIdx].capitalized).dropFirst().dropLast()
                
                var link = String(line[firstIdx...lastIdx]).dropFirst().dropLast()
                
                if !link.hasPrefix("https://") && !link.hasPrefix("http://") {
                    link = "https://" + link
                }
                
                return AnyView (
                    Link(destination: URL(string: String(link))!) {
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

enum LineType {
    case header(Int)
    case paragraph
    case codeBlock
    case listItem
    case blockQuote
    case link
    case checkbox
    case unknown
}

#Preview ("Markdown") {
    Markdown(markdownText: .constant("\(Note.self.placeholder2.content)"))
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
}
