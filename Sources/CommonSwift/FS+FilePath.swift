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
//  FS+FilePath.swift
//  SwiftScratch
//
//  Created by psksvp on 18/9/19.
//  Copyright © 2019 com.psksvp. All rights reserved.
//

import Foundation

public extension FS
{
  struct FilePath
  {
    public let path: String
    public let directory: String
    public let filename: String
  
    // must be file path, and file must exist
    public init?(_ p: String)
    {
      var dir = ObjCBool(true)
      guard FileManager.default.fileExists(atPath: p, isDirectory: &dir),
            false == dir.boolValue,
            let components = FileManager.default.componentsToDisplay(forPath: p) else
      {
        Log.error("fail to construct Path from string \(p), path is not a file")
        return nil
      }
      
      self.path = p
      self.filename = FileManager.default.displayName(atPath: p)
      self.directory = "/\(components.dropFirst().dropLast().joined(separator: "/"))" //MS Windowz? go to hell
    }
    
    public var fileExtension: String?
    {
      guard let dotIdx = self.filename.range(of: ".", options: String.CompareOptions.backwards) else
      {
        return nil
      }
      
      return String(self.filename[dotIdx])
    }
    
    public var filenameWithOutExtension: String
    {
      guard let dotIdx = self.filename.range(of: ".", options: String.CompareOptions.backwards) else
      {
        // there is no dot ext, so just return
        return self.filename
      }
    
      return String(self.filename[self.filename.startIndex ..< dotIdx.lowerBound])
    }
  }
}
