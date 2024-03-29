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
//  FS+DeviceFile.swift
//  SwiftScratch
//
//  Created by psksvp on 18/9/19.
//  Copyright © 2019 com.psksvp. All rights reserved.
//

import Foundation

#if os(macOS) || os(Linux)
public extension FS
{
  class func deviceFile(atPath p: String) -> DeviceFile?
  {
    let ds = DeviceFile(path: p)
    
    return ds.fileDesciptor >= 0 ? ds : nil
  }
  
  /**
      DeviceFile posix api
   */
  class DeviceFile
  {
    private let fd: Int32
    
    public var fileDesciptor: Int32
    {
      get {return self.fd}
    }

    //////////////////////////////////////////////
    public init(path: String, flags: Int32 = O_RDONLY)
    {
      self.fd = open(path, flags|O_NONBLOCK)
    }

    //////////////////////////////////////////////
    deinit
    {
      if -1 != fileDesciptor
      {
        close(fileDesciptor)
      }
    }

    //////////////////////////////////////////////
    public func read(size: Int, msTimeout: Int32) -> [UInt8]?
    {
      let fds = UnsafeMutablePointer<pollfd>.allocate(capacity: 1)
      defer { fds.deallocate() }
      
      fds[0].fd = self.fd
      
      if poll(fds, 1, msTimeout) > 0
      {
         var rawBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
         defer { rawBuffer.deallocate() }
#if os(Linux)
         let bytesRead = SwiftGlibc.read(fileDesciptor, rawBuffer, size)
#elseif os(macOS)
         let bytesRead = Darwin.read(fileDesciptor, rawBuffer, size)
#endif
         if(bytesRead > 0)
         {
           return Array(UnsafeBufferPointer(start: rawBuffer, count: bytesRead))
         }
      }
      
      return nil
    }


    //////////////////////////////////////////////
    public func ioctlRead(request: UInt) -> UInt8?
    {
      var a = UInt8(0)
      
      if -1 != ioctl(self.fd, request, &a)
      {
        return a
      }
      else
      {
        return nil
      }
    }
  }
}
#endif
