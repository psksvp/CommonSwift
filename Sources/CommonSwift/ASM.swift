//
//  ASM.swift
//  
//
//  Created by psksvp on 27/5/20.
//

import Foundation

//
//open class ASM
//{
//  class FixedState
//  {
//    var fixedPoint: Bool { false }
//  }
//  
//  public class State<L: Hashable, V> : FixedState
//  {
//    private var memory:[L : V] = [:]
//    private var stack:[V] = []
//    
//    public let name: String
//    override public var fixedPoint: Bool {false} // dummy for now
//    
//    init(_ n: String)
//    {
//      name = n
//      
//    }
//    
//    public subscript(location: L) -> V?
//    {
//      get
//      {
//        memory[location]
//      }
//      
//      set
//      {
//        memory[location] = newValue
//      }
//    }
//  }
//  
//  class NullaryState<V> : State<Int, V>
//  {
//    override init(_ n: String)
//    {
//      super.init(n)
//    }
//    
//    override subscript(n: Int = 0) -> V?
//    {
//      get
//      {
//        return super[0]
//      }
//      
//      set
//      {
//        super[0] = newValue
//      }
//    }
//  }
//  
//
//  private var states:[String : FixedState] = [:]
//  public var fixedPointReached : Bool
//  {
//    let f = states.values.map { $0.fixedPoint }
//    return f.reduce(false)
//           {
//             a, b in
//             return a && b
//           }
//    
//  }
//  
//  public var running: Bool
//  
//  public init()
//  {
//  }
//}
