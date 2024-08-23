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

//
//  Bits.swift
//  SwiftScratch
//
//  Created by psksvp on 19/9/19.
//  Copyright © 2019 com.psksvp. All rights reserved.
//

import Foundation

public func ascii<T: UnsignedInteger>(_ n: T) -> String
{
  return n >= 32 && n <= 126 ? String(Character(UnicodeScalar(Int(n))!)) : "."
}

public func hex<T: FixedWidthInteger>(_ n: T) -> String
{
  let leadingZeros = (n.bitWidth / 8) * 2
  return String(format:"0x%0\(leadingZeros)X", n as! CVarArg)
}

public func hex<T: FixedWidthInteger>(_ n: [T]) -> [String]
{
  n.map {hex($0)}
}

public func binary<T: FixedWidthInteger>(_ n: T) -> String
{
  let bin = String(n, radix:2)
  let padding = n.bitWidth - bin.count
  if padding > 0
  {
    return "\(String(repeating: "0", count: padding))\(bin)"
  }
  else
  {
    return bin
  }
}

public extension Int32
{
  init(_ d: UInt8, _ c: UInt8, _ b: UInt8, _ a: UInt8)
  {
    self.init( Int32(d) << 24 | Int32(c) << 16 | Int32(b) << 8 | Int32(a))
  }

  var bytes: [UInt8]
  {
    [UInt8((self >> 24) & 0xFF),
     UInt8((self >> 16) & 0xFF),
     UInt8((self >> 8) & 0xFF),
     UInt8(self & 0xFF)]
  }
}
 

public extension UInt16
{
  init(_ hi: UInt8, _ lo: UInt8)
  {
    self.init( (UInt16(hi) << 8) | UInt16(lo) )
  }
  
  func clearHiBits() -> UInt16
  {
    return self & 0x00ff
  }
  
  func clearLoBits() -> UInt16
  {
    return self & 0xff00
  }
  
  var bytes: (hi:UInt8, lo:UInt8)
  {
    return (UInt8(self >> 8), UInt8(self.clearHiBits()))
  }
  
  var byteArray: [UInt8]
  {
    let (hi, lo) = self.bytes
    return [hi, lo]
  }
}

//
//  BitVector.swift
//
//
//  Created by psksvp on 28/10/20.
//


public class BitVector<T: FixedWidthInteger> : CustomStringConvertible
{
  private var rawValue: T
  
  public var value: T {rawValue}
  
  public init(_ r: T)
  {
    rawValue = r
  }
  
  public func clear()
  {
    rawValue = 0
  }
  
  public func set(_ r: T)
  {
    rawValue = r
  }
  
  public subscript(_ i: T) -> T
  {
    get
    {
      assert(Int(i) < rawValue.bitWidth)
      let bit: T = 1 << i
      return bit & rawValue
    }
    set(newValue)
    {
      assert(Int(i) < rawValue.bitWidth)
      let bit: T = 1 << i
      rawValue = newValue != 0 ? rawValue | bit : rawValue & (bit ^ 0xff)
    }
  }
  
  public var description: String
  {
    let bin = String(rawValue, radix:2)
    let padding = rawValue.bitWidth - bin.count
    if padding > 0
    {
      return "\(String(repeating: "0", count: padding))\(bin)"
    }
    else
    {
      return bin
    }
  }
}




