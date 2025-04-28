//
//  Markdown.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/17/25.
//

import SwiftUI

//TODO: Work on regex rule for detecting links in markdown format
struct Markdown: View {
    
    @Binding var markdownText: String
    @State var viewModel: NoteViewModel?
    
    var limit: Bool? = false
    
    @State private var markdownLines: [String] = []
      
    var body: some View {
        VStack (alignment: .leading, spacing: 4) {
            
            let linesToShow = limit == true ? Array(markdownLines.prefix(3)) : markdownLines
            
            ForEach(linesToShow.indices, id: \.self) { index in
                let line = markdownLines[index]
                
                if (line.hasPrefix("#")) {
                    headerView(line)
                } else if (line.hasPrefix("[x]") || line.hasPrefix("[ ]")) {
                    checkboxView(line, index)
                } else if (line.hasPrefix("```")) {
                    codeBlockView(line)
                } else if (line.hasPrefix("[google]")) {
                    linkView(line)
                } else {
                    Text(line)
                        .font(.body)
                }
            }
            
            Spacer()
        }
        
        .onAppear() {
            markdownLines = markdownText.components(separatedBy: .newlines)
        }
    }
    
    // FIXME: Still some trouble with detecting links that don't include ```https://```
    private func linkView(_ line: String) -> some View {
        if let firstIdx = line.firstIndex(of: "("), let lastIdx = line.firstIndex(of: ")") {
            var modifiedLine = line
            modifiedLine = modifiedLine.replacingOccurrences(of: "(https://[.a-zA-Z]*)", with: "", options: .regularExpression)
            modifiedLine = modifiedLine.replacingOccurrences(of: "[\\[\\]()]+", with: "", options: .regularExpression)
            
            return AnyView (
                Link(destination: URL(string: String(line[firstIdx...lastIdx].dropFirst().dropLast()))!) {
                    Label(modifiedLine.capitalized, systemImage: "safari")
                        .padding(10)
                        .underline()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.2))
                        )
                        .padding(.vertical, 10)
                        .fontWeight(.bold)
                }
            )
        }
        
        return AnyView(Text(line))
    }

    
    private func checkboxView(_ line: String, _ index: Int) -> some View {
        if let openBracket = line.firstIndex(of: "["), let closeBracket = line.firstIndex(of: "]") {
            let item = line[line.index(after: openBracket)]
            let textStartIndex = line.index(after: closeBracket)
            let itemText = String(line[textStartIndex...]).trimmingCharacters(in: .whitespaces)
            
            return AnyView(
                HStack {
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
        
        viewModel.updateLastModified()
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

#Preview ("Markdown") {
    Markdown(markdownText: .constant("\(Note.self.placeholder2.content)"))
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
}
