//
//  ASM.swift
//  
//
//  Created by psksvp on 27/5/20.
//

import Foundation


open class ASM
{
  open class State
  {
    public let name: String
    var fixed: Bool { false }
    
    init(_ n: String)
    {
      name = n
    }
  }
  open class AddressableState<L: Hashable, V> : State
  {
    private var memory:[L : V] = [:]
    
    
    public override init(_ n: String)
    {
      super.init(n)
    }
    
    open subscript(location: L) -> V
    {
      get
      {
        memory[location]!
      }
      
      set
      {
        memory[location] = newValue
      }
    }
  }
  
  open class NonAddressableState<V> : State
  {
    private var value: V
    
    public init(_ n: String, _ v : V)
    {
      value = v
      super.init(n)
    }
    
    open subscript(i: Int = 0) -> V
    {
      get
      {
        return value
      }
      set
      {
        value = newValue
      }
    }
  }

  /////////////////////////////////////////////////////////////
  public var running: Bool = false
  private let stateList:Array<State>
  
  public init(_ sl: Array<State>)
  {
    stateList = sl
  }
  open func run()
  {
    running = true
    defer
    {
      running = false
    }
    
    while(step())
    {
      
    }
  }
  
  open func step() -> Bool
  {
    return false
  }
  
  
  /////
  public class func state<V>(_ n: String, _ v: V) -> NonAddressableState<V>
  {
    return NonAddressableState<V>(n, v)
  }
  
  public class func state<L, V>(_ n: String, _ val: (L, V)) -> AddressableState<L, V>
  {
    let s = AddressableState<L, V>(n)
    let (l, v) = val
    s[l] = v
    return s
  }
}



