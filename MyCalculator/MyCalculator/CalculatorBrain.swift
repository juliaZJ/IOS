//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by Zheng Jia on 4/10/15.
//  Copyright (c) 2015 Santa Clara University. All rights reserved.
//

import Foundation
import Darwin

class CalculatorBrain {
    private enum Op: Printable { // Printable is protocal
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case ConstantOperation(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .ConstantOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private var updatedOp = ""
    
    init() {
        func learnOps(op: Op) {
            knownOps[op.description] = op
        }
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["-"] = Op.BinaryOperation("-") { $1 - $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["tan"] = Op.UnaryOperation("tan", tan)
        knownOps["π"] = Op.ConstantOperation("π", M_PI)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops // copy it, not real
            let op = remainingOps.removeLast() // minimal copy
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    updatedOp = "\(symbol)" + "(" + "\(operand)" + ")"
                    println("\(symbol) + \(operand)")
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evalution = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evalution.result {
                        updatedOp = "\(operand1)" + "\(symbol)" + "\(operand2)"
                        return (operation(operand1, operand2), op2Evalution.remainingOps)
                    }
                }
            case .ConstantOperation(_, let operation):
                return (operation, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func clearAll() {
        while (!opStack.isEmpty) {
            opStack.removeLast()
        }
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func newOperation() -> String {
        let resultOp: String = updatedOp
        updatedOp = ""
        return resultOp
    }
}