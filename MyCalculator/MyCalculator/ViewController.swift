//
//  ViewController.swift
//  MyCalculator
//
//  Created by Zheng Jia on 3/30/15.
//  Copyright (c) 2015 Santa Clara University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    var isDecimal: Bool = false
    
    var brain = CalculatorBrain() // model
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit != "." || !isDecimal {
                display.text = display.text! + digit
                if (digit == ".") {
                    isDecimal = true;
                }
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func removeDigit() {
        if userIsInTheMiddleOfTypingANumber {
            displayValue = 0
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                history.text = brain.newOperation()
                println("history is \(history.text)")
            } else {
                displayValue = 0
            }
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func clear() {
        brain.clearAll()
        displayValue = 0
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        isDecimal = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    var displayValue: Double {
        get {
           return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

