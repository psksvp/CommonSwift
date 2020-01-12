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
    private let action: (() -> Void)?
    
    var machine: Machine? = nil
    
    var idName: String
    {
      get {return name}
    }
    
    init(name n: String,  withAction a: (() -> Void)? = nil)
    {
      name = n
      action = a
    }
    
    func runAction() -> Void
    {
      if let a = action
      {
        a()
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
    currentState.runAction()
  }
  
  func reset()
  {
    currentState = startState
    currentState.runAction()
  }
  
  func route(withInput e: E, fromState: State, toState: State)
  {
		fromState.machine = self
    switch(route[fromState])
    {
      case .some(_) : route[fromState]![e] = toState
      case .none    : route[fromState] = [e : toState]
    }
  }
  
  func run(withInput e: E)
  {
    guard let r = route[currentState] else
    {
      Log.info("\(currentState.idName) is a dead end.")
      return
    }
    
    guard let n = r[e] else
    {
      Log.info("\(currentState.idName) does not response to input \(e)")
      return
    }
    
    n.runAction()
    currentState = n
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


// class TestMachine: Machine<String>
// {
//    let idle = State(name: "idle")
//    {
//      print("idling")
//    }
//
//    let watch = State(name: "watch")
//    {
//      print("watching")
//    }
//
//    let found = State(name: "found")
//    {
//      print("I found it")
//    }
//
//    init()
//    {
//      super.init(startState: idle)
//      route(withInput: "#", fromState: idle, toState: watch)
//      route(withInput: "\n", fromState: watch, toState: found)
//    }
// }



// class Calculator: Machine
// {
// 	enum Operator
// 	{
// 		case Plus
// 		case Minus
// 		case Mul
// 		case Div
// 	}
//
// 	private var registerA = 0.0
// 	private var currentOp:Operator? = nil
// 	private var displayBuffer:String = ""
//
// }



















