//
//  Markdown.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/17/25.
//

import SwiftUI

//TODO: Work on regex rule for detecting links in markdown format
struct Markdown: View {
    
    @State var markdownText: String
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
        
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        
        .onAppear() {
            markdownLines = markdownText.components(separatedBy: .newlines)
        }
    }
    
    private func linkView(_ line: String) -> some View {
        let firstIndex = line.firstIndex(of: "(")!
        let lastIndex = line.firstIndex(of: ")")!
        
        var link = line[firstIndex...lastIndex].dropFirst().dropLast()
        var modifiedLine = line
        modifiedLine = modifiedLine.replacingOccurrences(of: "(https://[.a-zA-Z]*)", with: "", options: .regularExpression)
        modifiedLine = modifiedLine.replacingOccurrences(of: "[\\[\\]()]+", with: "", options: .regularExpression)
        
        return Label(modifiedLine.capitalized, systemImage: "safari")
            .underline()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.black.opacity(0.4))
            )
            .padding(.vertical)
            .fontWeight(.bold)
            .onTapGesture {
                
            }
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
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.black.opacity(0.4))
            )
    }
}
