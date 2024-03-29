///*
//*  The BSD 3-Clause License
//*  Copyright (c) 2018. by Pongsak Suvanpong (psksvp@gmail.com)
//*  All rights reserved.
//*
//*  Redistribution and use in source and binary forms, with or without modification,
//*  are permitted provided that the following conditions are met:
//*
//*  1. Redistributions of source code must retain the above copyright notice,
//*  this list of conditions and the following disclaimer.
//*
//*  2. Redistributions in binary form must reproduce the above copyright notice,
//*  this list of conditions and the following disclaimer in the documentation
//*  and/or other materials provided with the distribution.
//*
//*  3. Neither the name of the copyright holder nor the names of its contributors may
//*  be used to endorse or promote products derived from this software without
//*  specific prior written permission.
//*
//*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//*  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//*  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//*  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//*  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//*  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//*  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//*
//* This information is provided for personal educational purposes only.
//*
//* The author does not guarantee the accuracy of this information.
//*
//* By using the provided information, libraries or software, you solely take the risks of damaging your hardwares.
//*/
// 
//import Foundation
//
//#if !os(iOS)
//
//#if os(OSX)
//import Darwin.C
//import CoreFoundation
//import IOKit
//import IOKit.serial
//import IOKit.usb
//#elseif os(Linux)
//import Glibc
//#endif
// 
//public class SerialPort
//{
//  public enum Baud
//  {
//    case b1200
//    case b2400
//    case b4800
//    case b9600
//    case b19200
//    case b115200
//    
//    var value: speed_t
//    {
//      get
//      {
//        switch self
//        {
//          case .b1200   : return tcflag_t(B1200)
//          case .b2400   : return tcflag_t(B2400)
//          case .b4800   : return tcflag_t(B4800)
//          case .b9600   : return tcflag_t(B9600)
//          case .b19200  : return tcflag_t(B19200)
//          case .b115200 : return tcflag_t(B115200)
//        }
//      }
//    }
//  }
//  
//  public enum BitSize: tcflag_t
//  {
//    case five
//    case six
//    case seven
//    case eight
//    
//    var value: tcflag_t
//    {
//      get
//      {
//        switch self
//        {
//          case .five  : return tcflag_t(CS5)
//          case .six   : return tcflag_t(CS6)
//          case .seven : return tcflag_t(CS7)
//          case .eight : return tcflag_t(CS8)
//        }
//      }
//    }
//  }
//  
//  public enum Parity: tcflag_t
//  {
//    case none
//    case even
//    case odd
//    
//    var value: tcflag_t
//    {
//      get
//      {
//        switch self
//        {
//          case .none : return tcflag_t(0)
//          case .even : return tcflag_t(PARENB)
//          case .odd  : return tcflag_t(PARENB | PARODD)
//        }
//      }
//    }
//  }
//  
//  public enum Error
//  {
//    case openPortFail
//    case notSerialPort
//  }
//  
//  private let fileID:Int32
//  
//  public var ready: Bool {self.fileID >= 0}
//  
//  public init(path: String, baud: Baud = .b4800,
//                            bitSize: BitSize = .eight,
//                            parity: Parity = .none)
//  {
//    Log.info("about to open \(path) for serial read & write")
//#if os(macOS)
//    self.fileID = open(path, O_RDWR | O_NOCTTY | O_EXLOCK)
//#elseif os(Linux)
//    self.fileID = open(path, O_RDWR | O_NOCTTY)
//#endif
//    if(-1 == self.fileID)
//    {
//      Log.error("\(self) fail to open serial port at \(path)")
//    }
//    else
//    {
//      Log.info("Serial port \(path) opened")
//      var config = termios()
//      tcgetattr(fileID, &config)
//      cfsetspeed(&config, baud.value)
//      config.c_cflag |= parity.value
//      config.c_cflag &= ~tcflag_t(CSTOPB) // no stop bit
//      
//      config.c_cflag &= ~tcflag_t(CSIZE)
//      config.c_cflag |= bitSize.value
//      //update the setting
//      tcsetattr(fileID, TCSANOW, &config)
//    }
//  }
//  
//  deinit
//  {
//    if -1 != fileID
//    {
//      close(fileID)
//    }
//  }
//  
//  public func read() -> UInt8?
//  {
//    guard -1 != fileID else {return nil }
//    
//    var buf: UInt8 = 0
//    
//#if os(Linux)
//    let bytesRead = SwiftGlibc.read(fileID, &buf, 1)
//#elseif os(macOS)
//    let bytesRead = Darwin.read(fileID, &buf, 1)
//#endif
//    
//    if bytesRead > 0
//    {
//      return buf
//    }
//    else
//    {
//      return nil
//    }
//  }
//  
//  /**
//  
//   */
//  public func read(size: Int) -> [UInt8]?
//  {
//    if(-1 != fileID)
//    {
//      var rawBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
//      defer { rawBuffer.deallocate() }
//#if os(Linux)      
//      let bytesRead = SwiftGlibc.read(fileID, rawBuffer, size)
//#elseif os(macOS)
//      let bytesRead = Darwin.read(fileID, rawBuffer, size)
//#endif      
//      if(bytesRead > 0)
//      {
//        return Array(UnsafeBufferPointer(start: rawBuffer, count: bytesRead))
//      }
//    }
//    
//    return nil
//  }
//  
//  /**
//  
//   */
//  public func write(data: [UInt8]) -> Int
//  {
//    if(-1 == fileID)
//    {
//      return 0
//    }
//    else
//    {
//      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
//      var d = data // the feak below wants a fucking var.
//      buffer.initialize(from: &d, count: data.count)
//      defer { buffer.deallocate() }
//#if os(Linux)
//      let bytesWritten = SwiftGlibc.write(fileID, buffer, data.count)
//#elseif os(macOS)
//      let bytesWritten = Darwin.write(fileID, buffer, data.count)
//#endif
//      return bytesWritten
//    }
//  }
//}
//
//
////////////////////////////////////////////////////////////////////
//extension SerialPort
//{
//  public func writeLine(_ s:String, maxTry: Int = 10000)
//  {
//    let a: [UInt8] = Array((s.last == "\n" ? s : "\(s)\n").utf8)
//    var len = self.write(data: a)
//    guard len > 0 else
//    {
//      Log.error("SerialPort.writeLine fail..")
//      return
//    }
//    var n = 0
//    while len < a.count && n < maxTry
//    {
//      len = self.write(data: Array(a.dropFirst(len)))
//      print(len)
//      n = n + 1
//    }
//    
//    if n >= maxTry || len != a.count
//    {
//      Log.error("SerialPort.writeLine fail..")
//    }
//  }
//  
//  /**
//
//   */
//  public func readLine(lineEnd: String = "\r\n",
//                       maxTry: Int = 10000) -> String?
//  {
//    var line = ""
//    var loopCounter = 0
//    while(loopCounter < maxTry)
//    {
//      loopCounter = loopCounter + 1
//      if let c = read()
//      {
//        line += String(Character(Unicode.Scalar(c)))
//        if line.contains(lineEnd)
//        {
//          return line.trim()
//        }
//      }
//      else
//      {
//        Log.error("\(self) readLine() fail to read")
//        break
//      }
//    }
//    if loopCounter >= maxTry
//    {
//      Log.error("\(self) readLine maxTry reached")
//    }
//    
//    return nil
//  }
//  
////  public class var list: [String]
////  {
////    #if os(macOS)
////    guard let classes = IOServiceMatching(kIOSerialBSDServiceValue) else {return [String]()}
////    var iter: io_iterator_t = 0 // io_iterator_t is aka UINT32
////    guard KERN_SUCCESS == IOServiceGetMatchingServices(kIOMasterPortDefault, classes, &iter) else {return [String]()}
////    var port: io_object_t = IOIteratorNext(iter)
////    while port != 0
////    {
////      let s = "IOCalloutDevice".data(using: .utf8)!
////      
////      s.withUnsafeBytes
////      {
////        (unsafeBytes) in
////        let bytes = unsafeBytes.bindMemory(to: UInt8.self).baseAddress!
////        let callOutDeviceKey = CFStringCreateWithBytes(kCFAllocatorDefault, bytes, s.count, CFStringBuiltInEncodings.UTF8.rawValue, true)
////        if let cfPath = IORegistryEntryCreateCFProperty(port, callOutDeviceKey, kCFAllocatorDefault, 0)
////        {
////          let result = CFStringGetCString(cfPath, <#T##buffer: UnsafeMutablePointer<CChar>!##UnsafeMutablePointer<CChar>!#>, <#T##bufferSize: CFIndex##CFIndex#>, <#T##encoding: CFStringEncoding##CFStringEncoding#>)
////        }
////      }
////      
////      //let callOutDeviceKey = CFStringCreateWithBytes(kCFAllocatorDefault, bytes, ioCallOutDevice.count, CFStringBuiltInEncodings.UTF8.rawValue, true)
//////      if let cfPath = IORegistryEntryCreateCFProperty(port, CFStringCreateWithBytes(kCFAllocatorDefault, "IOCalloutDevice".u, <#T##encoding: CFStringEncoding##CFStringEncoding#>)("IOCalloutDevice"), kCFAllocatorDefault, 0)
//////      {
//////
//////      }
////    }
////    
////    return [String]()
////    #endif
////    
////    #if os(Linux)
////    return [String]()
////    #endif
////    
////  }
//}
//#endif // if !os(iOS)
