//
//  File.swift
//  
//
//  Created by psksvp on 16/10/21.
//

import Foundation


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
