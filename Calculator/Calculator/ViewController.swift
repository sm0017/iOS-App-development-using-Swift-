//
//  ViewController.swift
//  Calculator
//  Smita Sukhadeve
//  COS 470 : Project 2: Complex Calculator

/*
Implemented:
1. Functionalities in the Basic Calculator with MVC
2 & 3 : uses the enum as primary data structure, non-private Api and model is in sync with the view
4. displayValue as double? and setting the displayValue to 'nil' clears the claculator display
5. implemented functinality to push variables by implementing func pushOperand( String) and Dictionary variableValues
6. evaluate() returns value of M i.e variable when it finds the entry for M in the variable dictionary otherwise returns displayValue = nil and clears the calculator display
7.var description : String and suports a, b, c, d, e, f,g
8. UILable 'history' with '=' on the end of it
9. two new buttons M (get variable)and →M(set variable).
10. 'C' functionality
11. Pressing 'C' button clears the M variable
12. Autolayout

Taken care of the Feedback from the project 1:
1. 'history' lable pushes keyborad down : corrected
2. Numbers have ) prefix : Corrected
3.Pi : e.g. pi 3 * : Corrected
4. +/- does not work consistiently (extra credit) : corrected

Extra Tasks:
1. Parentheses Removal
2. Undo '↩︎' button functinality:
*/

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var history: UILabel!  // Shows the description of the CalculatorBrain/OpStack
    @IBOutlet weak var display: UILabel! // Calculator Display
    var userIsTypingNumber = false
    var brain = CalculatorBrain()
    
    // Appends the digits entered by the user to get the numeric input to perform the required operation and
    // Also toggle the 'undo' button to 'backspace' when user is entering the number
    @IBAction func appendDigits(sender: UIButton){
        
        let digit = sender.currentTitle!
        if userIsTypingNumber {
            backspace.setTitle("⌫", forState: .Normal)
            display.text = display.text! + digit
        }else {
            display.text = digit
            userIsTypingNumber = true
        }
    }
    
    // handles the functionalities of '.','C' and '+/-' buttons
    //calls the function 'additionalCalFunction' to perform necessary steps
    @IBAction func decimalClearSign(sender: UIButton ){
        
        let input = sender.currentTitle!
        if input == "." || input == "+/-" {
            userIsTypingNumber = true
        }
        else {
            userIsTypingNumber = false
            history.text = " "
        }
        
        if let calDisplay = display.text {
            display.text = brain.additionalCalFunction(input, display: calDisplay)
        } else {
            display.text = nil
        }
    }
    
    /*Performs the backspace and undo operations. When a user press 'backspace' button, it calls brain.backSpaceUndo() and return the remaining String and undotext. 
    When the display.text goes completely blank, the 'undo' button appears which inturn returns the 'undotext' when user clicks it.
    The 'undo' button toggles to 'backspace' when user start entering a number again
    */
    var undo: String = " "
    @IBOutlet weak var backspace: UIButton!
    @IBAction func backspaceUndo(sender: UIButton){
        
        let input = sender.currentTitle!
        if input == "⌫" {
            if let calDisplay = display.text {
                let (displayText, undoText) = brain.backSpaceUndo(input, display: calDisplay)
                display.text = displayText; undo = undoText
                if displayText == "0" {
                    backspace.setTitle("↩︎", forState: .Normal)
                    userIsTypingNumber = false
                }
            }
        }else if input == "↩︎" {
            display.text = undo
            sender.setTitle("⌫", forState: .Normal); undo = " "
            userIsTypingNumber = true
        }
    }
    
    //takes the user input and push it on the stack to perform the operation
    // Shows the evaluated result and description of brain
    @IBAction func enter(){
        
        userIsTypingNumber = false
        let (result, brainContent) = brain.pushOperand(displayValue!)
        if let op = result {
            displayValue = op
        }
        if let desc = brainContent {
            history.text = desc
        }
    }
    
    
    // set/get Variable : Return the Double? value of display.text and set the Double? to String?
    var displayValue: Double? {
        
        get{
            if let userIn = display.text    {
                return NSNumberFormatter().numberFromString(userIn)?.doubleValue
            }else { return nil
            }
        }
        set{
            if let output = newValue {
                display.text = "\(output)"
            }
            else {
                display.text = " "
            }
            userIsTypingNumber = false
        }
    }
    
    // Evalutes the operation entered by the user to get the result and return the brain decsription
    @IBAction func perfromOperation(sender: UIButton){
        
        if userIsTypingNumber {
            enter()
        }
        userIsTypingNumber = false
        if let operation = sender.currentTitle {
            let ( result, des) = brain.performOperation(operation)
            
            if let output = result {
                displayValue = output
            }else {
                displayValue = nil
            }
            if let brainDesc = des {
                history.text = brainDesc
            }
        }
    }
    
    /* Implements the Memory variable functionality
    When a user clicks '→M', set the value of M = displayValue and evaluates the opstack
    When a user click 'M' , display a set value otherwise displays blank
    */
    @IBAction func memoryVariable(sender: UIButton) {
        
        let mCharacter = sender.currentTitle!
        if mCharacter == "→M"{
            brain.varibleValues["M"] = displayValue
            if let result = brain.evaluate() {
                displayValue = result
            }
            userIsTypingNumber = false
        }else {
            
            if userIsTypingNumber {
                enter()
            }
            let (result, brainContent) = brain.pushOperand(mCharacter)
            if let op = result {
                displayValue = op
            }else {
                displayValue = nil
            }
            if let desc = brainContent {
                history.text = desc
            }
        }
    }
}





