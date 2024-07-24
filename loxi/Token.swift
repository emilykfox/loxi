//
//  Token.swift
//  loxi
//
//  Created by Emily Fox on 6/20/24.
//

import Foundation

enum TokenType {
    // Single-character tokens
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
    case comma
    case dot
    case minus
    case plus
    case semicolon
    case slash
    case star

    // One or two character tokens
    case bang
    case bangEqual
    case equal
    case equalEqual
    case greater
    case greaterEqual
    case less
    case lessEqual

    // Literals
    case identifier
    case string
    case number

    // Keywords
    // (should false, nil, and true actually be special tokens?)
    case and
    case `class`
    case `else`
    case `false`
    case fun
    case `for`
    case `if`
    case `nil`
    case or
    case print
    case `return`
    case `super`
    case this
    case `true`
    case `var`
    case `while`

    case eof
}

enum Literal {
    case identifier(String)
    case string(String)
    case number(Double)
}

extension Literal: CustomStringConvertible {
    var description: String {
        switch self {
        case let .identifier(identifier): identifier
        case let .number(number): Swift.String(number)
        case let .string(string): string
        }
    }
}

struct Token {
    let type: TokenType
    let lexeme: Substring
    let literal: Literal?
    let line: Int
}
