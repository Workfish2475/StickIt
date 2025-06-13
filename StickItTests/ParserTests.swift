//
//  ParserTests.swift
//  StickIt
//
//  Created by Alexander Rivera on 6/9/25.
//

import XCTest
@testable import StickIt

final class ParserTests: XCTestCase {
    var parser: Parser!

    override func setUp() {
        super.setUp()
        parser = Parser()
    }

    func testHeaderParsing() {
        let result = parser.parse("# Header 1")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .header(1))
        XCTAssertEqual(result[0].content, "# Header 1")
    }

    func testCheckboxUncheckedParsing() {
        let result = parser.parse("[ ] Task not done")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .checkbox(checked: false, label: "Task not done"))
    }

    func testCheckboxCheckedParsing() {
        let result = parser.parse("[x] Task completed")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .checkbox(checked: true, label: "Task completed"))
    }

    func testCodeBlockParsing_MultiLine() {
        let input = """
        ```
        let x = 1
        let y = 2
        ```
        """
        let result = parser.parse(input)
        print(result)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .codeBlock)
        XCTAssertTrue(result[0].content.contains("let x = 1"))
        XCTAssertTrue(result[0].content.contains("let y = 2"))
    }

    func testCodeBlockParsing_SingleLine() {
        let input = "```let x = 1```"
        let result = parser.parse(input)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .codeBlock)
        XCTAssertTrue(result[0].content.contains("let x = 1"))
    }

    func testLinkParsing() {
        let input = "[Google](https://google.com)"
        let result = parser.parse(input)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .link(text: "Google", url: "https://google.com"))
        XCTAssertEqual(result[0].content, input)
    }

    func testParagraphParsing() {
        let input = "Just a plain paragraph."
        let result = parser.parse(input)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .paragraph)
        XCTAssertEqual(result[0].content, input)
    }

    func testMultipleLines() {
        let input = """
        # Header
        [ ] Unchecked
        [x] Checked
        [GitHub](https://github.com)
        ```
        code
        block
        ```
        Regular text
        """
        let result = parser.parse(input)
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0].type, .header(1))
        XCTAssertEqual(result[1].type, .checkbox(checked: false, label: "Unchecked"))
        XCTAssertEqual(result[2].type, .checkbox(checked: true, label: "Checked"))
        XCTAssertEqual(result[3].type, .link(text: "GitHub", url: "https://github.com"))
        XCTAssertEqual(result[4].type, .codeBlock)
        XCTAssertEqual(result[5].type, .paragraph)
    }
}
