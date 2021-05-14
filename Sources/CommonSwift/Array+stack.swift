//
//  Array+Stack.swift
//  
//
//  Created by psksvp on 10/6/20.
//

import Foundation

extension Array
{
  public mutating func push(_ e: Element)
  {
    self.append(e)
  }
  
  public mutating func pop() -> Element?
  {
    return self.removeLast()
  }
  
  var top: Element? {return self.last}
}
