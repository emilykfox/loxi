//
//  main.swift
//  loxi
//
//  Created by Emily Fox on 6/16/24.
//

import Foundation

var hadError = false

switch CommandLine.arguments.count {
case 0:
    try runPrompt()
case 1:
    try runFile(path: CommandLine.arguments[0])
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
//    var scanner = LoxScanner()
//    tokens = scanner.scanTokens()
//    
//    // For now, just print the tokens
//    for token in tokens {
//        print(token)
//    }
}

func error(line: Int, message: String) throws {
    try report(line: line, where: "", message: message)
}

func report(line: Int, where whereString: String, message: String) throws {
    try FileHandle.standardError.write(contentsOf: "[line \(line)] Error\(whereString): \(message)".data(using: .utf8)!)
}
