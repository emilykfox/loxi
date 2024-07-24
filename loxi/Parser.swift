//
//  Parser.swift
//  loxi
//
//  Created by Emily Fox on 7/23/24.
//

import Foundation

struct ParseError: Error {}

@MainActor
struct Parser {
    let tokens: [Token]

    private var current: [Token].Index

    init(tokens: [Token]) {
        self.tokens = tokens
        self.current = tokens.startIndex
    }

    mutating func parse() -> Expr? {
        do {
            return try expression()
        } catch {
            return nil
        }
    }

    private mutating func expression() throws -> Expr {
        return try equality()
    }

    private mutating func equality() throws -> Expr {
        var expr = try comparison()

        while matchTokenTypes(.bangEqual, .equalEqual) {
            let op = prevToken()
            let right = try comparison()
            expr = Expr.binary(left: expr, operator: op, right: right)
        }

        return expr
    }

    private mutating func comparison() throws -> Expr {
        var expr = try term()

        while matchTokenTypes(.greater, .greaterEqual, .less, .lessEqual) {
            let op = prevToken()
            let right = try term()
            expr = Expr.binary(left: expr, operator: op, right: right)
        }

        return expr
    }

    private mutating func term() throws -> Expr {
        var expr = try factor()

        while matchTokenTypes(.minus, .plus) {
            let op = prevToken()
            let right = try factor()
            expr = Expr.binary(left: expr, operator: op, right: right)
        }

        return expr
    }

    private mutating func factor() throws -> Expr {
        var expr = try unary()

        while matchTokenTypes(.slash, .star) {
            let op = prevToken()
            let right = try unary()
            expr = Expr.binary(left: expr, operator: op, right: right)
        }

        return expr
    }

    private mutating func unary() throws -> Expr {
        while matchTokenTypes(.bang, .minus) {
            let op = prevToken()
            let right = try unary()
            return Expr.unary(operator: op, right: right)
        }

        return try primary()
    }

    private mutating func primary() throws -> Expr {
        if matchTokenTypes(.false) {
            return Expr.literal(.identifier("false"))
        }
        if matchTokenTypes(.true) {
            return Expr.literal(.identifier("true"))
        }
        if matchTokenTypes(.nil) {
            return Expr.literal(.identifier("nil"))
        }

        if matchTokenTypes(.number, .string) {
            return Expr.literal(prevToken().literal!)
        }

        if matchTokenTypes(.leftParen) {
            let expr = try expression()
            try _ = consumeToken(
                expectedType: .rightParen,
                errorMessage: "Expect ')' after expression.")
            return Expr.grouping(expr)
        }

        throw try makeError(token: peek(), message: "Expect expression.")
    }

    private mutating func matchTokenTypes(_ types: TokenType...) -> Bool {
        return types.contains(where: {
            if checkTokenType($0) {
                _ = advance()
                return true
            } else {
                return false
            }
        })
    }

    private func checkTokenType(_ type: TokenType) -> Bool {
        if atEnd {
            return false
        }

        return peek().type == type
    }

    private mutating func advance() -> Token {
        let token = tokens[current]
        tokens.formIndex(after: &current)
        return token
    }

    private var atEnd: Bool {
        current == tokens.endIndex
    }

    private func peek() -> Token {
        precondition(!atEnd)

        return tokens[current]
    }

    private func prevToken() -> Token {
        return tokens[tokens.index(before: current)]
    }

    private mutating func consumeToken(
        expectedType: TokenType, errorMessage: String
    ) throws -> Token {
        precondition(!atEnd)

        if checkTokenType(expectedType) {
            return advance()
        }

        throw try makeError(token: peek(), message: errorMessage)
    }

    private func makeError(token: Token, message: String) throws -> ParseError {
        try error(token: token, message: message)
        return ParseError()
    }

    private mutating func synchronize() {
        _ = advance()

        while !atEnd {
            if prevToken().type == .semicolon {
                return
            }

            switch peek().type {
            case .class, .fun, .var, .for, .if, .while, .print, .return:
                return
            default: ()
            }

            _ = advance()
        }
    }
}
