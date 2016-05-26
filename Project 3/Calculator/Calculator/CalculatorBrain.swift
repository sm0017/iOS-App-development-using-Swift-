//
//  CalculatorBrain.swift
//  Calculator
//  Smita Sukhadeve
//  COS 470 : Project 2: Complex Calculator
//  Copyright © 2016 USM. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // 'Op' acts as a primary data structure for the CalculatorBrain.
    // Possible values of enum are : Operand, variable, binary/Unary opeartion, constant
    // Var description : returns description of enum value
    // var precedence : returns the precedence : for binary (+/-) operation, precedence is 1 and (X/÷) have precedence 2: default: Int.max
    private enum Op: CustomStringConvertible {
        
        case Operand(Double)
        case Variable(String)
        case BinaryOperation(String, (Double, Double) ->Double)
        case UnaryOperation(String, Double -> Double)
        case Constant(String)
        var description: String {
            get {
                
                switch  self{
                case .Operand(let operand) :
                    return "\(operand)"
                case .UnaryOperation (let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol,  _):
                    return symbol
                case .Variable(let variable):
                    return variable
                case .Constant(let const):
                    return const
                }
            }
        }
        
        var precedence: Int {
            get {
                var p : Int
                switch  self{
                case .BinaryOperation(let symbol,  _):
                    if symbol == "X"||symbol == "÷" {
                        p = 2
                    }
                    else { p = 1
                    }
                default: p = Int.max
                }
                return p
            }
        }
    }
    
   
    private  var opStack = [Op]()   // Stack of the performed operations/operands
    private  var knownOps = [String:Op]()  // [operationSymbol:function]
    private  let constantValues:[String:Double] = ["π": M_PI] // [constant:ValueOfConstant]
    var varibleValues = [String:Double]()
    
    // Initialiser
    
    init () {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("X", *))
        learnOp(Op.BinaryOperation("÷"){$1 / $0})
        learnOp(Op.BinaryOperation("＋" , + ))
        learnOp(Op.BinaryOperation("−"){$1 - $0})
        learnOp(Op.UnaryOperation (("√"), sqrt))
        learnOp(Op.UnaryOperation(("sin"),sin))
        learnOp(Op.UnaryOperation(("cos"),cos))
        learnOp(Op.Constant(("π")))
    }
    
    // It evaluates the stack and return the result after user enters the operator/operand
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    // This is the helper recursive function which get called from the evaluate() to evaluate the opStack result
    // It takes the opStack as parameter and  return the last element in case of '.Operand'
    // For Binary and Unary function it recursively calls itself to return the result of the operation
    // For the Constant and  Variable cases, it looks for the variable/constant values in the Dictionary and returns the result
    private func evaluate(ops:[Op])-> (result:Double?, remainingOps:[Op]){
        
        if !ops.isEmpty {
            var remainingOps = ops
            let opStackElement = remainingOps.removeLast()
            switch opStackElement {
                
            case .Operand(let operand) :
                return (operand, remainingOps)
                
            case .Variable(let variable):
                var variableValue: Double?
                if  let  value = varibleValues[variable] {
                    variableValue = value
                }else {
                    variableValue = nil
                }
                return (variableValue, remainingOps)
                
            case .BinaryOperation(_, let operation):
                let operand1Evaluation  = evaluate(remainingOps)
                if let operand1 = operand1Evaluation.result {
                    let operand2Evaluation  = evaluate(operand1Evaluation.remainingOps)
                    if let operand2 = operand2Evaluation.result {
                        return(operation(operand1, operand2 ), operand2Evaluation.remainingOps)
                    }
                }
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation  = evaluate(remainingOps)
                if let operand1 = operandEvaluation.result {
                    return(operation(operand1), operandEvaluation.remainingOps)
                }
                
            case .Constant(let symbol):
                var constant: Double?
                if  let  value = constantValues[symbol] {
                    constant = value
                }
                return (constant, remainingOps)}
        }
        return (nil, ops)
    }
    
    //It push the operand onto the stack and returns the description of the brain
    func pushOperand(operand:Double)->(Double?, String?){
        opStack.append(Op.Operand(operand))
        return (evaluate(),description)
    }
    
   //It push the variable onto the stack and returns the description of the brain
    func pushOperand(operand: String)-> (Double?, String?){
        opStack.append(Op.Variable(operand))
        return (evaluate(),description)
    }
    
    // It takes the operator as a parameter, push it onto the stack and evaluate the stack, also returns the brain description
    func performOperation(symbol:String)->(Double?, String?){
        if  let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return (evaluate(),description)
    }
    
    
    // This is the recursive function which get called from the var description to describe the opStack/brain content
    // It takes the opStack as parameter and  return the last element as the string value 'operand' in case of the .Operand
    // For Binary and Unary functions: it recursively calls itself to describe the content of brain. For example: if enconuters '+' operator
    // call itself twice to decribe the '+' operations.
    // For the Constant and  Variable cases, it looks for the variable/constant values in the Dictionary and returns the result
    // for Binary and Unary operators, for optimizing the paretheses , it uses the precedence variable.
    // When the precedence of the top element/operator of stack is greater than the elements after it, add extra paranthesis while describing the brain content
    // example: when [3, 5, 4, + X ] => top operator 'x' has higher precedence than '+' hence we add parathesis while describing the plus operation 3 X (5+4)
    // In case of unary operation, always include the bracket around the operand : [3,√] => √(3)
    // If the operand is missing add '?'
  
    private func description(ops:[Op])-> (result:String?, remainingOps:[Op], precedence: Int){
        if !ops.isEmpty {
            var remainingOps = ops
            let  op = remainingOps.removeLast()
            
            switch op {
                
            case .Operand(let operand) :
                return (String(format: "%g", operand), remainingOps, op.precedence)
                
            case .Variable(let variable):
                return (variable, remainingOps, op.precedence)
                
            case .BinaryOperation(let operation, _):
                let operand1Evaluation  = description(remainingOps)
                if var operand1 = operand1Evaluation.result {
                    if op.precedence > operand1Evaluation.precedence {
                        operand1 = "(\(operand1))"
                    }
                    let operand2Evaluation  = description(operand1Evaluation.remainingOps)
                    if var operand2 = operand2Evaluation.result {
                        if op.precedence  > operand2Evaluation.precedence {
                            operand2 = "(\(operand2))"
                        }
                        return ("\(operand2) \(operation) \(operand1)", operand2Evaluation.remainingOps, op.precedence)
                        
                    }else { return ("? \(operation) \(operand1)", operand2Evaluation.remainingOps, op.precedence)
                    }
                }
                
            case .UnaryOperation(let operation, _):
                let operand1Evaluation  = description(remainingOps)
                if var operand1 = operand1Evaluation.result {
                    if op.precedence > operand1Evaluation.precedence {
                        operand1 = "(\(operand1))"
                    }
                    if operand1.rangeOfString("(") != nil {
                        return ("\(operation) \(operand1) ", operand1Evaluation.remainingOps, op.precedence)
                    }else {
                        return ("\(operation) (\(operand1))", operand1Evaluation.remainingOps, op.precedence)
                    }
                }else {
                    return ("\(operation) (?) ", operand1Evaluation.remainingOps, op.precedence)
                }
                
            case .Constant(let constant):
                return(constant, remainingOps, op.precedence)
            }
        }
        return (nil, ops, Int.max)
    }
    
    
    // description variable returns the description of the opStack/CalculatorBrain. It calls the recustive function description(ops)
    // If the stack has multiple expressions add "," to separate them. While returning the result we add "=" sign to show displayValue is the result of the evaluation of an
    // expression with '=' sign
    var description: String{
        
        get {
            
            var ops = opStack, result: String = " "
            while ops.count > 0 {
                let (descriptionResult, remainingOps, _) = description(ops)
                ops = remainingOps
                if  let brainContent = descriptionResult {
                    if result == " " {
                        result = brainContent
                    }else {
                        result = brainContent + "," + result
                    }
                }
                
            }
            return result + " = "
        }
    }
    
    
    // Performs the additional steps for clear, +/- and decimal functionalities of the Calculator
    // When user click '+/-' , if the display.text has prefix '-' , remove othewise add the '-' and vice versa
    //For the clear button , we remove all the element from opStack, and variablevalues and history lable
    // for decimal point, if display.text does not contain decimal point, then only we add dot.
   
    func additionalCalFunction(symbol:String, display:String) -> String{
        var displayDigits = display
        switch symbol {
            
        case "+/-" :
            if displayDigits.hasPrefix("-") {
                displayDigits.removeAtIndex(displayDigits.startIndex)
            }else{
                displayDigits.insert( "-", atIndex: displayDigits.startIndex )
            }
            
        case ".":
            if displayDigits.rangeOfString(".") == nil {
                displayDigits =  displayDigits + "."
            }
            
        case "C" :
            opStack.removeAll(); displayDigits = "0"
            varibleValues.removeAll()
            
        default: break
            
        }
        return displayDigits
        
    }
    
    // Performs steps requires for the backspace/undo operations.
    // if the enter symbol is 'backspace', allow user to delete one character at a time . If display goes completely blank we set it to '0' and enable the 'undo' button
    var undoText = " "
    func backSpaceUndo(symbol:String, display:String) -> (String, String) {
        var displayDigits = display, resultUndo = " "
        if symbol == "⌫" {
            if  displayDigits.characters.count > 1 {
                if undoText == " " {
                    undoText = String( displayDigits.characters.last!)
                }else {
                    undoText = String( displayDigits.characters.last!) + undoText
                }
                displayDigits = String(displayDigits.characters.dropLast())
            }else {
                undoText = String( displayDigits.characters.last!) + undoText
                displayDigits = String(displayDigits.characters.dropLast())
                displayDigits = "0"; resultUndo = undoText ; undoText = " "
            }
        }
        return ( displayDigits, resultUndo)
    }
    
    
    //defaults.synchronize()
    // NSObjectDefaults automatically synchronize for us.
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }set (xValue){
            
            if let symbols = xValue as? Array <String> {
                var newStack = [Op] ()
                for symbol in symbols {
                    if let op = knownOps[symbol]{
                        newStack.append(op)
                    }else if let operand  = Double(symbol){
                        newStack.append (.Operand(operand))
                    }else {
                        newStack.append(.Variable(symbol))
                    }
                }
                  opStack = newStack
                }
            }
        }
    }
    
