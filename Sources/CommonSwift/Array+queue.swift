//
//  File.swift
//  
//
//  Created by psksvp on 2/10/2023.
//

import Foundation

public extension Array
{
  mutating func enqueue(_ e: Element)
  {
    self.append(e)
  }
  
  @discardableResult
  mutating func dequeue() -> Element?
  {
    guard !self.isEmpty else {return nil}
    return self.removeFirst()
  }
  
  var front: Element?
  {
    self.first
  }
  
  var back: Element?
  {
    self.last
  }
}
