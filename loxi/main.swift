//
//  main.swift
//  loxi
//
//  Created by Emily Fox on 6/16/24.
//

import Foundation

switch CommandLine.arguments.count {
case 0:
    try runPrompt()
case 1:
    try runFile(path: CommandLine.arguments[0])
default:
    print("Usage: loxi [script]")
    exit(64)
}

func runFile(path: String) throws {
    try run(source: String(contentsOfFile: path, encoding: .utf8))
}

func runPrompt() throws {
    while true {
        print("> ")
        let line = readLine()
        if let line {
            try run(source: line)
        } else {
            break
        }
    }
}

func run(source: String) throws {
    
}
