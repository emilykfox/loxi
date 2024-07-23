//
//  Scanner.swift
//  loxi
//
//  Created by Emily Fox on 6/17/24.
//

import Foundation

struct Scanner {
    let source: String

    private(set) var tokens: [Token] = []

    // start and current will probably change types to directly index into source
    // (can I do that?)
    private var start: String.Index
    private var current: String.Index
    private var line = 0

    init(source: String) {
        self.source = source

        start = source.startIndex
        current = source.startIndex
    }

    mutating func scanTokens() throws {
        while !atEnd {
            // We are at the beginning of the next lexeme
            start = current
            try scanToken()
        }

        tokens.append(
            Token(
                type: .eof, lexeme: source[current..<current], literal: nil,
                line: line))
    }

    var atEnd: Bool {
        current == source.endIndex
    }

    private mutating func scanToken() throws {
        let character: Character = advance()
        switch character {
        case "(": addToken(.leftParen)
        case ")": addToken(.rightParen)
        case "{": addToken(.leftBrace)
        case "}": addToken(.rightBrace)
        case ",": addToken(.comma)
        case ".": addToken(.dot)
        case "-": addToken(.minus)
        case "+": addToken(.plus)
        case ";": addToken(.semicolon)
        case "*": addToken(.star)
        case "!":
            let type: TokenType =
                if matchCurrent("=") {
                    .bangEqual
                } else {
                    .bang
                }
            addToken(type)
        case "=":
            let type: TokenType =
                if matchCurrent("=") {
                    .equalEqual
                } else {
                    .equal
                }
            addToken(type)
        case "<":
            let type: TokenType =
                if matchCurrent("=") {
                    .lessEqual
                } else {
                    .less
                }
            addToken(type)
        case ">":
            let type: TokenType =
                if matchCurrent("=") {
                    .greaterEqual
                } else {
                    .greater
                }
            addToken(type)
        case "/":
            if matchCurrent("/") {
                // A comment goes until the end of the line
                while peek() != "\n" && !atEnd {
                    _ = advance()
                }
            } else {
                addToken(.slash)
            }
        case " ", "\r", "\t":
            // Ignore whitespace
            ()
        case "\n":
            line += 1
        case "\"": try scanString()
        case let character where isDigit(character): scanNumber()
        case let character where isAlpha(character): scanIdentifier()
        default: try error(line: line, message: "Unexpected character.")
        }

    }

    private mutating func advance() -> Character {
        let character = source[current]
        source.formIndex(after: &current)
        return character
    }

    private mutating func matchCurrent(_ expected: Character) -> Bool {
        if atEnd || source[current] != expected {
            return false
        }

        source.formIndex(after: &current)
        return true
    }

    private func peek() -> Character? {
        if atEnd {
            nil
        } else {
            source[current]
        }
    }

    private func peekNext() -> Character? {
        if current == source.endIndex
            || source.index(after: current) == source.endIndex
        {
            nil
        } else {
            source[source.index(after: current)]
        }
    }

    private mutating func addToken(_ type: TokenType, literal: Literal? = nil) {
        tokens.append(
            Token(
                type: type, lexeme: source[start..<current], literal: literal,
                line: line))
    }

    private mutating func scanString() throws {
        while peek() != "\"" && !atEnd {
            if peek() == "\n" {
                line = line + 1
            }
            _ = advance()
        }

        if atEnd {
            try error(line: line, message: "Unterminated string.")
            return
        }

        // The closing "
        _ = advance()

        let stringLiteral = String(
            source[source.index(after: start)..<source.index(before: current)])
        addToken(.string, literal: .string(stringLiteral))
    }

    private mutating func scanNumber() {
        while let character = peek(), isDigit(character) {
            _ = advance()
        }

        // Look for a fractional part
        if let character = peek(), character == ".",
            let nextCharacter = peekNext(), isDigit(nextCharacter)
        {
            // Consume the "."
            _ = advance()

            while let character = peek(), isDigit(character) {
                _ = advance()
            }
        }

        let numberLiteral = Double(source[start..<current])!
        addToken(.number, literal: .number(numberLiteral))
    }

    private mutating func scanIdentifier() {
        while let character = peek(), isAlphaNumeric(character) {
            _ = advance()
        }

        let tokenType: TokenType =
            switch source[start..<current] {
            case "and": .and
            case "class": .class
            case "else": .else
            case "false": .false
            case "for": .for
            case "fun": .fun
            case "if": .if
            case "nil": .nil
            case "or": .or
            case "print": .print
            case "return": .return
            case "super": .super
            case "this": .this
            case "true": .true
            case "var": .var
            case "while": .while
            default: .identifier
            }
        addToken(tokenType)
    }

    private func isDigit(_ character: Character) -> Bool {
        character >= "0" && character <= "9"
    }

    private func isAlpha(_ character: Character) -> Bool {
        (character >= "a" && character <= "z")
            || (character >= "A" && character <= "Z") || (character == "_")
    }

    private func isAlphaNumeric(_ character: Character) -> Bool {
        isAlpha(character) || isDigit(character)
    }
}
