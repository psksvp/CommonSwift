//
//  Array+Stack.swift
//  
//
//  Created by psksvp on 10/6/20.
//

import Foundation

public extension Array
{
  mutating func push(_ e: Element)
  {
    self.append(e)
  }
  
  mutating func pop() -> Element?
  {
    return self.removeLast()
  }
  
  var top: Element? {return self.last}
}
