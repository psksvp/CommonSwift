/*
*  The BSD 3-Clause License
*  Copyright (c) 2018. by Pongsak Suvanpong (psksvp@gmail.com)
*  All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without modification,
*  are permitted provided that the following conditions are met:
*
*  1. Redistributions of source code must retain the above copyright notice,
*  this list of conditions and the following disclaimer.
*
*  2. Redistributions in binary form must reproduce the above copyright notice,
*  this list of conditions and the following disclaimer in the documentation
*  and/or other materials provided with the distribution.
*
*  3. Neither the name of the copyright holder nor the names of its contributors may
*  be used to endorse or promote products derived from this software without
*  specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
*  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
*  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
*  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
*  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
*  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
*  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* This information is provided for personal educational purposes only.
*
* The author does not guarantee the accuracy of this information.
*
* By using the provided information, libraries or software, you solely take the risks of damaging your hardwares.
*/

import Foundation

public class Machine<E: Hashable>
{
  public class State: Equatable, Hashable
  {
    private let name: String
    private let action: ((Machine, E?) -> Void)?
    
    var idName: String
    {
      get {return name}
    }
    
    init(name n: String,  withAction a: ((Machine, E?) -> Void)? = nil)
    {
      name = n
      action = a
    }
    
    func runAction(inMachine m: Machine, withInput e: E? = nil) -> Void
    {
      if let a = action
      {
        a(m, e)
      }
    }
    
    public class final func == (lhs: State, rhs: State) -> Bool
    {
      lhs.idName == rhs.idName
    }
    
    public func hash(into hasher: inout Hasher)
    {
      hasher.combine(name)
    }
  }
  
  
  private let startState: State
  private var currentState: State
  private var route = [State : [E : State]]()
	
	var current:State
	{
		get {return currentState}
	}
	
	var start:State
	{
		get {return startState}
	}
  
  init(startState s: State)
  {
    startState = s
    currentState = startState
    currentState.runAction(inMachine: self)
  }
  
  func route(withInput e: E, fromState: State, toState: State)  -> Void
  {
    switch(route[fromState])
    {
      case .some(_) : route[fromState]![e] = toState
      case .none    : route[fromState] = [e : toState]
    }
  }
	
  func routes(withInputs e: [E], fromState f: State, toState t: State)  -> Void
  {
    for i in e
		{
			route(withInput: i, fromState: f, toState: t)
		}
  }
  
  func step(withInput e: E)  -> Void
  {
    guard let r = route[currentState] else
    {
      Log.warn("\(currentState.idName) is a dead end.")
      return
    }
    
    guard let n = r[e] else
    {
      Log.warn("\(currentState.idName) does not response to input \(e)")
      return
    }
    
		currentState = n
    n.runAction(inMachine: self, withInput: e)
  }
	
	func pass() -> Void
	{
    guard let r = route[currentState] else
    {
      Log.warn("\(currentState.idName) is a dead end.")
      return
    }
		
		let n = r.values.first!
		currentState = n
    n.runAction(inMachine: self)
	}
  
  func printInfo() -> Void
  {
    print("start state: \(startState.idName)")
    print("current state: \(currentState.idName)")
    for (k, v) in route
    {
      print("route from state : \(k.idName)")
      for (i, s) in v
      {
        print("  with input : \(i) next state : \(s.idName)")
      }
      print("----------")
    }
  }
}



class Calculator: Machine<String>
{	
	let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
	let operators = ["+", "-", "*", "/"]	
	
	var registerA = ""
	var registerB = ""
	var registerO = ""
	
	func display() -> Void
	{
		print("------------")
    print("A: \(registerA)")
		print("B: \(registerB)")
		print("O: \(registerO)")
		print("current: \(self.current.idName)")
	}
	
	func clear() -> Void
	{
		registerA = ""
		registerB = ""
	}
	
	let A = State(name: "A")
	{
		m, i in
		let cal = m as! Calculator
		if let input = i
		{
			if ".0123456789".contains(input)
		  {
		  	cal.registerA += input
		  }
			
			if "+-*/".contains(input)
		  {
		  	cal.registerO = input
		  }
		}
	}
	
	let B = State(name: "B")
	{
		m, i in
		let cal = m as! Calculator
		if let input = i
		{
			if "0123456789.".contains(input)
		  {
		  	cal.registerB += input
		  }
			
			if "+-*/".contains(input)
		  {
		  	cal.registerO = input
		  }

		}
	}
	
	let CLEAR = State(name: "CLEAR")
	{
		m, i in
		let cal = m as! Calculator
		cal.clear()
		m.pass()
	}
	
	let EXE = State(name: "EXE")
	{
		m, i in
		let c = m as! Calculator
		let a = Double(c.registerA)!
		let b = Double(c.registerB)!
		var r:Double = 0.0
		switch(c.registerO)
		{
			case "+" : r = a + b
			case "-" : r = a - b
			case "*" : r = a * b
			case "/" : r = a / b // fucking div by zero
			default  : r = 0.0
		}
		c.registerA = "\(r)"
		c.registerB = ""
		c.registerO = ""
	}
	
	init()
	{
		super.init(startState: A)
		routes(withInputs: numbers, fromState: A, toState: A)
		routes(withInputs: operators, fromState: A, toState: B)
		routes(withInputs: numbers, fromState: B, toState: B)
		routes(withInputs: ["C", "c"], fromState: A, toState: CLEAR)
		routes(withInputs: ["C", "c"], fromState: B, toState: CLEAR)
		route(withInput: "=", fromState: B, toState: EXE)
		routes(withInputs: operators, fromState: EXE, toState: B)
		routes(withInputs: ["C", "c"], fromState: EXE, toState: CLEAR)
		route(withInput: "", fromState: CLEAR, toState: A)
	}
}


func runCalculator()
{
   let c = Calculator()
	 c.display()
	 for s in "10+21=*2="
	 {
	 	 c.step(withInput: String(s))
		 c.display()
	 }
}

//runCalculator()