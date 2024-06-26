//
//  Scanner.swift
//  loxi
//
//  Created by Emily Fox on 6/17/24.
//

import Foundation

enum TokenType {
    // Single-character tokens
    case LeftParen
    case RightParen
    case LeftBrace
    case RightBrace
    case Comma
    case Dot
    case Minus
    case Plus
    case Semicolon
    case Slash
    case Star
    
    // One or two character tokens
    case Bang
    case BangEqual
    case Equal
    case EqualEqual
    case Greater
    case GreaterEqual
    case Less
    case LessEqual
    
    // Literals
    case Identifier
    case String
    case Number
    
    // Keywords
    case And
    case Class
    case Else
    case False
    case Fun
    case For
    case If
    case Nil
    case Or
    case Print
    case Return
    case Super
    case This
    case True
    case Var
    case While
    
    case EOF
}

enum Literal {
    case Identifier(String)
    case String(String)
    case Number(Double)
}

struct Token {
    let type: TokenType
    let lexeme: Substring
    let literal: Literal?
    let line: Int
}

struct Scanner {
    let source: String
    
    private(set) var tokens: Array<Token> = []
    
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
        while (!atEnd) {
            // We are at the beginning of the next lexeme
            start = current
            try scanToken()
        }
        
        tokens.append(Token(type: .EOF, lexeme: source[current..<current], literal: nil, line: line))
    }
    
    var atEnd: Bool {
        get {
            current == source.endIndex
        }
    }
    
    private mutating func scanToken() throws {
        let character: Character = advance()
        switch character {
        case "(": addToken(.LeftParen)
        case ")": addToken(.RightParen)
        case "{": addToken(.LeftBrace)
        case "}": addToken(.RightBrace)
        case ",": addToken(.Comma)
        case ".": addToken(.Dot)
        case "-": addToken(.Minus)
        case "+": addToken(.Plus)
        case ";": addToken(.Semicolon)
        case "*": addToken(.Star)
        case "!":
            let type: TokenType = if matchCurrent("=") {
                .BangEqual
            } else {
                .Bang
            }
            addToken(type)
        case "=":
            let type: TokenType = if matchCurrent("=") {
                .EqualEqual
            } else {
                .Equal
            }
            addToken(type)
        case "<":
            let type: TokenType = if matchCurrent("=") {
                .LessEqual
            } else {
                .Less
            }
            addToken(type)
        case ">":
            let type: TokenType = if matchCurrent("=") {
                .GreaterEqual
            } else {
                .Greater
            }
            addToken(type)
        case "/":
            if matchCurrent("/") {
                // A comment goes until the end of the line
                while peek() != "\n" && !atEnd {
                    _ = advance()
                }
            } else {
                addToken(.Slash)
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
        if current == source.endIndex || source.index(after: current) == source.endIndex {
            nil
        } else {
            source[source.index(after: current)]
        }
    }
    
    private mutating func addToken(_ type: TokenType, literal: Literal? = nil) {
        tokens.append(Token(type: type, lexeme: source[start..<current], literal: literal, line: line))
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
        
        let stringLiteral = String(source[source.index(after: start)..<source.index(before: current)])
        addToken(.String, literal: .String(stringLiteral))
    }
    
    private mutating func scanNumber() {
        while let character = peek(), isDigit(character) {
            _ = advance()
        }
        
        // Look for a fractional part
        if let character = peek(), character == ".", let nextCharacter = peekNext(), isDigit(nextCharacter) {
            // Consume the "."
            _ = advance()
            
            while let character = peek(), isDigit(character) {
                _ = advance()
            }
        }
        
        let numberLiteral = Double(source[start..<current])!
        addToken(.Number, literal: .Number(numberLiteral))
    }
    
    private mutating func scanIdentifier() {
        while let character = peek(), isAlphaNumeric(character) {
            _ = advance()
        }
        
        let tokenType: TokenType = switch source[start..<current] {
        case "and": .And
        case "class": .Class
        case "else": .Else
        case "false": .False
        case "for": .For
        case "fun": .Fun
        case "if": .If
        case "nil": .Nil
        case "or": .Or
        case "print": .Print
        case "return": .Return
        case "super": .Super
        case "this": .This
        case "true": .True
        case "var": .Var
        case "while": .While
        default: .Identifier
        }
        addToken(tokenType)
    }
    
    private func isDigit(_ character: Character) -> Bool {
        character >= "0" && character <= "9"
    }
    
    private func isAlpha(_ character: Character) -> Bool {
        (character >= "a" && character <= "z") ||
        (character >= "A" && character <= "Z") ||
        (character == "_")
    }
    
    private func isAlphaNumeric(_ character: Character) -> Bool {
        isAlpha(character) || isDigit(character)
    }
}
