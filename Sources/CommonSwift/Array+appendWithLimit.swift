//
//  File.swift
//  
//
//  Created by psksvp on 7/10/21.
//

import Foundation

extension Array where Element: Equatable
{
  mutating func append(_ e: Element, withLimit limit: Int)
  {
    guard false == self.contains(e) else {return}
    
    if self.count >= limit
    {
      self.removeFirst()
    }
  
    self.append(e)
  }
}
