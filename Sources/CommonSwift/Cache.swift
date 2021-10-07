//
//  File.swift
//  
//
//  Created by psksvp on 7/10/21.
//

import Foundation


class Cache<K : Hashable, V>
{
  private var storage = [K : V]()
  private let generator: (K)->V
  
  init(_ f: @escaping (K)->V)
  {
    self.generator = f
  }
  
  subscript(_ key: K) -> V
  {
    return get(key)
  }
  
  func get(_ key: K) -> V
  {
    if let val = self.storage[key]
    {
      return val
    }
    else
    {
      let n = self.generator(key)
      self.storage[key] = n
      return n
    }
  }
  
  func invalidate(_ key: K)
  {
    guard let _ = self.storage[key] else {return}
    
    self.storage.removeValue(forKey: key)
  }
  
  func invalidateAll()
  {
    self.storage.removeAll(keepingCapacity: false)
  }
}
