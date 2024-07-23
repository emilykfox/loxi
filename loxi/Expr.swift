//
//  Expr.swift
//  loxi
//
//  Created by Emily Fox on 6/19/24.
//

import Foundation

enum Expr {
    indirect case binary(left: Expr, operator: Token, right: Expr)
    indirect case grouping(Expr)
    case literal(Literal?)
    indirect case unary(operator: Token, right: Expr)
}

extension Expr: CustomStringConvertible {
    var description: String {
        switch self {
        case let .binary(left, op, right):
            parenthesize(name: op.lexeme, exprs: left, right)
        case let .grouping(expr):
            parenthesize(name: "group", exprs: expr)
        case let .literal(literal):
            if let literal {
                String(describing: literal)
            } else {
                "nil"
            }
        case let .unary(op, right):
            parenthesize(name: op.lexeme, exprs: right)
        }
    }
    
    func parenthesize(name: Substring, exprs: Expr...) -> String {
        var string = "("
        string.append(contentsOf: name)
        for expr in exprs {
            string.append(" ")
            string.append(String(describing: expr))
        }
        string.append(")")
        
        return string
    }
}
