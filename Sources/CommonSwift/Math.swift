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

public class Math
{
  private init() {}
  // fancy word type constrain.
	//////////////
  public class NumericScaler<T: FloatingPoint & Comparable>
  {
    private var fromRange: ClosedRange<T>
    private var toRange: ClosedRange<T> 
    private var fromRangeLength: T
    private var toRangeLength: T
    
    public init(fromRange: ClosedRange<T>, toRange: ClosedRange<T>)
    {
      self.fromRange = fromRange
      self.toRange = toRange
      fromRangeLength = fromRange.upperBound - fromRange.lowerBound
      toRangeLength = toRange.upperBound - toRange.lowerBound
    }
    
    public subscript(value: T) -> T
    {
      if(value < fromRange.lowerBound)
      {
        return toRange.lowerBound
      }
      else if(value > fromRange.upperBound)
      {
        return toRange.upperBound
      }
      else
      {
        return (value - fromRange.lowerBound) * toRangeLength / fromRangeLength + toRange.lowerBound
      }
    }
  }// class NumericScaler
  
  ///////
  public class PID
  {
    public var setPoint: Double
    public var kP: Double
    public var kI: Double
    public var kD: Double
    public var integral: Double
    public var derivative: Double
    public var outputLimit: ClosedRange<Double>
    
    public init(setPoint:Double,
                kP: Double,
                kI: Double,
                kD: Double,
                outputLimit: ClosedRange<Double>,
                integral: Double = 0.0,
                derivative: Double = 0.0)
    {
      self.setPoint = setPoint
      self.kP = kP
      self.kI = kI
      self.kD = kD
      self.outputLimit = outputLimit
      self.integral = integral
      self.derivative = derivative
    }
    
    public func step(input: Double)-> Double
    {
      let error = self.setPoint - input
      let p = self.kP * error
      let d = self.kD * (error - self.derivative)
      let nextIntegral = (self.integral + error).clamped(to: outputLimit)
      let nextDerivative = error
      let i = nextIntegral * self.kI
      self.integral = nextIntegral
      self.derivative = nextDerivative
      return p + i + d
    }
  }
  
  public class PIDArray
  {
    public let pids:[PID]
    
    public init(_ p:[PID])
    {
      self.pids = p
    }
    
    public func step(inputs: [Double]) -> [Double]
    {
      guard inputs.count == pids.count else
      {
        Log.error("inputs.count != pids.count")
        return Array<Double>.init(repeating: 0, count: inputs.count)
      }
      
      var output = Array<Double>.init(repeating: 0.0, count: inputs.count)
      
      let syncQ = DispatchQueue(label: "syncQueue")
      DispatchQueue.concurrentPerform(iterations: inputs.count)
      {
        idx in

        let result = self.pids[idx].step(input: inputs[idx])
        syncQ.sync // access to output array must be sync
        {
          output[idx] = result
        }
      }
      return output
      //return pids.enumerated().map {$1.step(input: inputs[$0])}
    }
    
    public func updateSetPoint(newSetPoints: [Double])
    {
      guard newSetPoints.count == pids.count else
      {
        Log.error("newSetPoints.count != pids.count")
        return
      }
      
      DispatchQueue.concurrentPerform(iterations: newSetPoints.count)
      {
        idx in
        self.pids[idx].setPoint = newSetPoints[idx]
      }
      
      //newSetPoints.enumerated().forEach{pids[$0].setPoint = $1}
    }
  }
  
  ////////////
  public class Vector<T:CustomStringConvertible> :CustomStringConvertible
  {
    private var matrix:Matrix<T>
    private let indices:[Int]
    private let initValue: T
    
    public var count: Int
    {
      indices.count
    }
    
    public init(_ d: Array<T>)
    {
      self.matrix = Matrix<T>(rows: 1, cols: d.count, d)!
      self.indices = [Int](0 ..< d.count)
      self.initValue = d[0]
    }
    
    public init(_ count: Int, initValue v: T)
    {
      self.matrix = Matrix<T>(1, count, initValue: v)
      self.indices = [Int](0 ..< count)
      self.initValue = v
    }
    
    public init(_ m: Matrix<T>, _ indices: [Int])
    {
      self.matrix = m
      self.indices = indices
      self.initValue = m.initValue
    }
    
    public subscript(index: Int) -> T
    {
      get
      {
        if (0 ..< self.indices.count).contains(index)
        {
          return self.matrix[self.indices[index]]
        }
        else
        {
          Log.fatal("index \(index) is out of range")
          return self.initValue
        }
        
      }
      
      set(newValue)
      {
        if (0 ..< self.indices.count).contains(index)
        {
          self.matrix[self.indices[index]] = newValue
        }
        else
        {
          Log.fatal("index \(index) is out of range")
        }
      }
    }
    
    public var description: String
    {
      let a = self.indices.map{ self.matrix[$0].description }
      return a.joined(separator: ", ")
    }
  }

  public class Matrix<T:CustomStringConvertible> :CustomStringConvertible
  {
    private var data:[T]
    public let rows: Int
    public let cols: Int
    public let initValue: T
    
    public init?(rows: Int, cols: Int, _ d: Array<T>)
    {
      guard rows * cols == d.count
      else
      {
        Log.error("rows * cols != init array count")
        return nil
      }
      
      self.data = d
      self.cols = cols
      self.rows = rows
      self.initValue = d[0]
    }
    
    public init(_ rows: Int, _ cols: Int, initValue v: T)
    {
      self.data = Array(repeating: v, count: rows * cols)
      self.rows = rows
      self.cols = cols
      self.initValue = v
    }
    
    public subscript(_ i: Int) -> T
    {
      get
      {
        guard (0 ..< self.rows * self.cols).contains(i)
        else
        {
          Log.fatal("index is out of range")
          return self.initValue
        }
        
        return self.data[i]
      }
      
      set(newValue)
      {
        guard (0 ..< self.rows * self.cols).contains(i)
        else
        {
          Log.fatal("index is out of range")
          return
        }
        
        self.data[i] = newValue
      }
    }
    
    public subscript(_ r: Int, _ c: Int) -> T
    {
      get
      {
        guard r < self.rows && c < self.cols
        else
        {
          Log.fatal("row or col index is out of range")
          return self.initValue
        }
        
        return self.data[self.cols * r + c]
      }
      
      set(newValue)
      {
        guard r < self.rows && c < self.cols
        else
        {
          Log.fatal("row or col index is out of range")
          return
        }
        
        self.data[self.cols * r + c] = newValue
      }
    }
    
    public func indicesOf(row: Int) -> [Int]
    {
      (0 ..< self.cols).map {self.cols * row + $0}
    }
    
    public func indicesOf(column: Int) -> [Int]
    {
      (0 ..< self.rows).map {self.cols * $0 + column}
    }
    
    public func vector(row: Int) -> Vector<T>
    {
      Vector(self, indicesOf(row: row))
    }
    
    public func vector(column: Int) -> Vector<T>
    {
      Vector(self, indicesOf(column: column))
    }
    
    public var description: String
    {
      let a = (0 ..< self.rows).map {self.vector(row: $0).description}
      return a.joined(separator: "\n")
    }
  }
}



