//
//  main.swift
//  loxi
//
//  Created by Emily Fox on 6/16/24.
//

import Foundation

// Little expression tree printing test
let testExpression = Expr.binary(
    left: .unary(
        operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
        right: .literal(.number(123))),
    operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
    right: .grouping(.literal(.number(45.67))))

print("test expression: \(testExpression)")

var hadError = false

switch CommandLine.arguments.count {
case 1:
    try runPrompt()
case 2:
    try runFile(path: CommandLine.arguments[1])
default:
    print("Usage: loxi [script]")
    exit(64)
}

@MainActor func runFile(path: String) throws {
    try run(source: String(contentsOfFile: path, encoding: .utf8))

    // Indicate an error in the exit code
    if hadError {
        exit(65)
    }
}

@MainActor func runPrompt() throws {
    while true {
        print("> ")
        let line = readLine()
        if let line {
            try run(source: line)
            hadError = false
        } else {
            break
        }
    }
}

@MainActor func run(source: String) throws {
    var scanner = Scanner(source: source)
    let tokens = try scanner.scanTokens()

    var parser = Parser(tokens: tokens)
    let expression = parser.parse()

    // Stop if there was a syntax error.
    if hadError {
        return
    }

    print(expression!)
}

@MainActor
func error(line: Int, message: String) throws {
    try report(line: line, where: "", message: message)
}

@MainActor
func error(token: Token, message: String) throws {
    let whereString =
        if token.type == .eof {
            " at end"
        } else {
            " at '\(token.lexeme)'"
        }
    try report(line: token.line, where: whereString, message: message)
}

@MainActor
func report(line: Int, where whereString: String, message: String) throws {
    hadError = true
    try FileHandle.standardError.write(
        contentsOf: "[line \(line)] Error\(whereString): \(message)".data(
            using: .utf8)!)
}
