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
//  FS+Monitor.swift
//  SwiftScratch
//
//  Created by psksvp on 18/9/19.
//  Copyright © 2019 com.psksvp. All rights reserved.
//

import Foundation
import Dispatch


// function a little different on macOS and Linux.
// Windowzzzz? fuck you, go to hell!


public extension FS
{
#if os(macOS)

  class DirectoryMonitor
  {
    private let monitorQueue: DispatchQueue
    private let monitorSource: DispatchSourceFileSystemObject?
    private let file: CInt
    private var dirContent = Set<String>()
    
    public init(directory url: URL,
                eventMask em: DispatchSource.FileSystemEvent = .write,
                fDirectoryChanged: @escaping (Set<String>) -> Void)
    {
      self.file = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
      self.monitorQueue = DispatchQueue(label: "FS.DirectoryMonitor",
                                   attributes: .concurrent)
      self.monitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.file,
                                                                          eventMask: em,
                                                                              queue: self.monitorQueue)
      
      self.monitorSource?.setEventHandler
      {
        guard let c = FS.contentsOfDirectory(url.path) else { return }
        fDirectoryChanged(Set(c))
//        let n = Set(c)
//        let d = n.subtracting(self.dirContent)
//        guard !d.isEmpty else {return}
//        self.dirContent = n
//        fDirectoryChanged(d)
      }
      
      if let c = FS.contentsOfDirectory(url.path)
      {
        self.dirContent = Set(c)
      }
      
      self.monitorSource?.resume()
      Log.info("FS.monitor(\(url.path))")
    }
    
    deinit
    {
      close(self.file)
      Log.info("FS.monitor.deinit")
    }
  }
  
  ////////////////////
  ///
  ///
  class FileMonitor
  {
    let url: URL

    let fileHandle: FileHandle
    let source: DispatchSourceFileSystemObject

    public init(url: URL, eventMask em: DispatchSource.FileSystemEvent, fFileChanged: @escaping (URL, DispatchSource.FileSystemEvent) -> Void) throws
    {
      self.url = url
      self.fileHandle = try FileHandle(forReadingFrom: url)

      self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileHandle.fileDescriptor,
                                                                   eventMask: em,
                                                                       queue: DispatchQueue.main)

      source.setEventHandler
      {
        let event = self.source.data
        fFileChanged(self.url, event)
      }

      source.setCancelHandler
      {
        try? self.fileHandle.close()
      }

      fileHandle.seekToEndOfFile()
      source.resume()
    }

    deinit
    {
      source.cancel()
    }
  }

#elseif os(Linux)

  class DirectoryMonitor
  {
    private let directoryPath: String
    private let process: OS.SpawnInteractive
    
    public init(directory url: URL, fDirectoryChanged: @escaping (Set<String>) -> Void)
    {
      func parse(_ line: String) -> Set<String>
      {
        let c = line.trim().components(separatedBy: ",")
        guard  c.count >= 3 else {return Set<String>()}
        
        return Set([c.first!])
      }
    
      self.directoryPath = url.path
      
      let script = """
      /usr/bin/inotifywait -m \(self.directoryPath) -e create -e moved_to -e moved_from -e delete |
      while read path action file; do
        echo "$file, $path, $action"
      done
      """
      
      let monitorSh = "\(FS.tempDir)/monitor\(UUID().uuidString).sh"
      FS.writeText(inString: script, toPath: monitorSh)
      self.process = OS.SpawnInteractive(["/usr/bin/sh", monitorSh])
                     {
                       out in
                     
                       switch out
                       {
                         case .stdOut(let line)  : let c = parse(line)
                                                   if !c.isEmpty
                                                   {
                                                     fDirectoryChanged(c)
                                                   }
                           
                         case .stdError(let err) : Log.error(err)
                       }
                     }
    }
    
    deinit
    {
      self.process.terminate()
    }
  }

#endif

  
  class func monitor(directory url: URL, fDirectoryChanged: @escaping (Set<String>) -> Void) -> DirectoryMonitor
  {
    DirectoryMonitor(directory: url, fDirectoryChanged: fDirectoryChanged)
  }
  
  class func monitor(file url: URL,
           eventMask em: DispatchSource.FileSystemEvent,
               fFileChanged: @escaping (URL, DispatchSource.FileSystemEvent) -> Void) throws -> FileMonitor
  {
    try FileMonitor(url: url, eventMask: em, fFileChanged: fFileChanged)
  }
}


/**

moved_to
    A file or directory was moved into a watched directory. This event occurs even if the file is simply moved from and to the same directory.
moved_from
    A file or directory was moved from a watched directory. This event occurs even if the file is simply moved from and to the same directory.
move
    A file or directory was moved from or to a watched directory. Note that this is actually implemented simply by listening for both moved_to and moved_from, hence all close events received will be output as one or both of these, not MOVE.
move_self
    A watched file or directory was moved. After this event, the file or directory is no longer being watched.
create
    A file or directory was created within a watched directory.
delete
    A file or directory within a watched directory was deleted.
delete_self

 */
