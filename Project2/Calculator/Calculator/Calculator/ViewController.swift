//
//  ViewController.swift
//  Calculator
//  Created by Smita Sukhadeve
//  COS 470 : Project 1: Basic Calculator

/*
supports:
1. Basic functionality demonstarated in lecture 1
2. Tried Autolayout
3. User can enter the legal floating point number
4. sin, cos and π functionality
5. added UILAble showHistory for the digits/operation entered by the user.
6. Support 'C' clear button functioanlity

Extra Tasks:
1. Backspace functinality
2. equal sign : Does not support
3. '+/-' functinality
4. Optional Double for displayValue
5. Support AutoLayout and output is not as expected.
*/

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    // It appends the digit entered by the user to form valid operand
    var userIsTypingNumber = false
    @IBAction func appendDigits(sender: UIButton){
        
        let digit = sender.currentTitle!
        if userIsTypingNumber {
            display.text = display.text! + digit
        }else {
            display.text = digit
            userIsTypingNumber = true
        }
    }
    
    // This method checks the special digits such as decimal point (.) , π,, +/- and display the result
    // if the entered digit is '+/-' character it strips or add '-' character from display text
    // π : it enters standard value for the π if user enters the 'pi'
    // '.' : only enters when the display doesn't contain any floating point and also takes care of the condition when user enters '.' as input
    
    @IBAction func checkDigit(sender: UIButton ){
        
        let input = sender.currentTitle!
        let x =  M_PI
        switch input {
        case "+/-" :
            if display.text!.hasPrefix("-") {
                display.text!.removeAtIndex(input.startIndex)
            }
            else{
                display.text!.insert("-", atIndex: display.text!.startIndex)
            }
        case "π":
            if !display.text!.isEmpty || display.text! != "0" {
                showHistory.text = showHistory.text! + display.text! + "⏎"
                pressEnterButton()
                display.text =  "\(x)"
            }else {
                display.text = "\(x)"
            }
        case ".":
            if display.text!.rangeOfString(".")==nil && display.text != "0" {
                display.text = display.text! + "."
            }else if display.text!.rangeOfString(".")==nil && display.text=="0"
            { display.text = "0."
            }
        default: break
            
        }
    }
    
    //takes the user input  and push it on the stack to perform the operation
    var operandStack = Array<Double?>()
    @IBAction func pressEnterButton(){
        userIsTypingNumber = false
        if displayValue != nil {
            operandStack.append(displayValue)
        }
    }
    
    // function( set/get) convert the double? to String? to display result of operation or errorMsg and
    //get : convert the String? to Double which require to perform operation

    let errorMsg = "invalid input"
    var displayValue: Double? {
        get{
            if display.text != nil    {
                return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            }else {
                return nil }
        }
        set{
            if newValue != nil {
                display.text = "\(newValue!)" }
            else {
                display.text = "\(errorMsg)"
            }
            print("\(newValue)")
            userIsTypingNumber = false
        }
    }
    
    // This function evalutes the operation entered by the user to get the result and the push the estimated result to the stack
    @IBAction func IndentifyOperation(sender: UIButton){
        let operation = sender.currentTitle!
        
        if userIsTypingNumber {
            pressEnterButton()
        }
        switch operation {
        case "X": performOperation {$0 * $1}
        case "÷": performOperation  {$1 / $0}
        case "＋": performOperation {$0 + $1}
        case "−": performOperation {$1 - $0}
        case "√": performOperation {sqrt($0)}
        case "sin": performOperation{sin($0)}
        case "cos": performOperation{cos($0)}
        default:break
        }
    }
    
    // to perform the binary operation and push the valid result on to the stack
    func performOperation(operation: (Double, Double) -> Double?){
       if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast()!, operandStack.removeLast()!)
            pressEnterButton()
        } else  {
            displayValue = nil
        }
    }
    
    // This function takes the two 'Double' digits to perform the urnary operation and push the result on the stack
    @nonobjc
    func performOperation(operation: (Double) -> Double?){
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast()!)
            pressEnterButton()
        } else {
            displayValue = nil
        }
    }
    
    // This function gets invoked when user press the 'C'  button and clear the operandStack and History of the performed operation
    @IBAction func clearOperandStanck() {
        operandStack.removeAll(); showHistory.text = " " ; display.text = "0"
    }
    
    // This function delete the digits end index of the display text.
    @IBAction func backSpace() {
        display.text!.removeAtIndex(display.text!.endIndex.predecessor())
        if display.text!.isEmpty {
            display.text = "0"
        }
    }
    
    // UIlable to show the history of recent operation and operands to display it to the users
    @IBOutlet weak var showHistory: UILabel!
    @IBAction func displayHistory(sender: UIButton) {
        if showHistory.text! == "0" {
            showHistory.text = display.text! + sender.currentTitle!
        }else {
            if display.text! != errorMsg {
                showHistory.text = showHistory.text! + display.text! + sender.currentTitle! }
        }
    }
}

