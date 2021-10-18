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


public extension FS
{
  class Monitor
  {
    private let monitorQueue: DispatchQueue
    private let monitorSource: DispatchSourceFileSystemObject?
    private let file: CInt
    private var dirContent = Set<String>()
    
    public init(directory url: URL, fDirectoryChanged: @escaping (Set<String>) -> Void)
    {
      self.file = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
      self.monitorQueue = DispatchQueue(label: "FS.DirectoryMonitor",
                                   attributes: .concurrent)
      self.monitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.file,
                                                                          eventMask: .write,
                                                                              queue: self.monitorQueue)
      
      self.monitorSource?.setEventHandler
      {
        print("here")
        guard let c = FS.contentsOfDirectory(url.path) else { return }
        let n = Set(c)
        let d = n.subtracting(self.dirContent)
        guard !d.isEmpty else {return}
        self.dirContent = n
        fDirectoryChanged(d)
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
}
