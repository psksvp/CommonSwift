//
//  File.swift
//  
//
//  Created by psksvp on 7/10/21.
//

import Foundation

public extension Array where Element: Equatable
{
  mutating func uniqueAppend(_ e: Element, withLimit l: Int? = nil)
  {
    guard false == self.contains(e) else {return}
    
    if let limit = l,
       self.count >= limit
    {
      self.removeFirst()
    }
  
    self.append(e)
  }
  
  mutating func append(_ e: Element, withLimit limit: Int)
  {
    if self.count >= limit
    {
      self.removeFirst()
    }
  
    self.append(e)
  }
}
