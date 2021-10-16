//
//  File.swift
//  
//
//  Created by psksvp on 16/10/21.
//

import Foundation


public extension FS
{
  class Monitor
  {
    private let monitorQueue: DispatchQueue
    private let monitorSource: DispatchSourceFileSystemObject?
    private let file: CInt
    
    public init?(directory url: URL, fDirectoryChanged: @escaping () -> Void)
    {
      self.file = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
      self.monitorQueue = DispatchQueue(label: "FS.DirectoryMonitor",
                                   attributes: .concurrent)
      self.monitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.file,
                                                                          eventMask: .write,
                                                                              queue: self.monitorQueue)
      
      self.monitorSource?.setEventHandler
      {
        
        fDirectoryChanged()
      }
      
      self.monitorSource?.resume()
    }
    
    deinit
    {
      close(self.file)
    }
    
  }
}
