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
//  OS.swift
//  SwiftScratch
//
//  Created by psksvp on 18/9/19.
//  Copyright © 2019 com.psksvp. All rights reserved.
//

import Foundation



public struct OS
{
  private init() {}
  
  @available(OSX 10.13, *)
  @discardableResult
	public static func spawn(_ args:[String], _ stringForInputPipe:String?) -> (stdout: String, stderr: String)?
  {
    if args.isEmpty
    {
      return nil
    }
    else
    {
      let outputPipe = Pipe()
      let errorPipe = Pipe()
      let inputPipe = Pipe()
      let task = Process()
      task.executableURL = URL(fileURLWithPath: args[0])
      task.standardOutput = outputPipe
      task.standardError = errorPipe
      task.standardInput = inputPipe
      
      if(args.count > 1)
      {
        task.arguments = Array(args.dropFirst())
      }
      
      do 
      {
        try task.run()
        if let inputString = stringForInputPipe
        {
          inputPipe.fileHandleForWriting.write(Data(inputString.utf8))
          inputPipe.fileHandleForWriting.closeFile()
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        return (stdout: String(decoding: outputData, as: UTF8.self), 
                stderr: String(decoding: errorData, as: UTF8.self))
      }
      catch let error as NSError
      {
        Log.error("OS.spawn \(args) fail: \(error.localizedDescription)")
        return nil
      }
    }
  }
	
  @available(OSX 10.13, *)

  public class SpawnInteractive
  {
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    let inputPipe = Pipe()
    let task = Process()
    let outputHandler: (String, String) -> ()

    private var  notID: Any?


    public init(_ args:[String], outputHandler f:@escaping (String, String) -> ())
    {
      outputHandler = f
      task.executableURL = URL(fileURLWithPath: args[0])
      task.standardOutput = outputPipe
      task.standardError = errorPipe
      task.standardInput = inputPipe
      if(args.count > 1) {  task.arguments = Array(args.dropFirst()) }

      notID = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: nil, queue: OperationQueue.main)
              {

                [unowned self] note in

                let handle = note.object as! FileHandle
                guard handle === outputPipe.fileHandleForReading ||
                      handle === errorPipe.fileHandleForReading else
                {
                  print("cannot obtain handle to out or err")
                  return
                }

                defer { handle.waitForDataInBackgroundAndNotify() }
                let data = handle.availableData
                let str = String(decoding: data, as: UTF8.self)
                if handle === outputPipe.fileHandleForReading
                {
                  outputHandler(str, "")
                }
                else
                {
                  outputHandler("", str)
                }
              }

      task.launch()

      outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
      errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }

    deinit
    {
      if let i = notID
      {
        NotificationCenter.default.removeObserver(i)
      }
      task.terminate()
    }

    public func pipe(_ s: String)
    {
      self.inputPipe.fileHandleForWriting.write("\(s)\n".data(using: .utf8)!)
    }
    
    public func pipe(bytes: [UInt8])
    {
      let d = Data(bytes)
      self.inputPipe.fileHandleForWriting.write(d)
    }
    
    public func interrupt()
    {
      task.interrupt()
    }

  }
  
  
} //OS

extension Collection where Element == String
{
  @discardableResult
  public func spawn(stdInput: String? = nil) -> String?
  {
    if #available(OSX 10.13, *)
    {
      if let (stdout, stderr) = OS.spawn(self as! [String], stdInput)
      {
        if !stderr.isEmpty
        {
          Log.info(stderr)
        }
        return stdout
      }
      else
      {
        return nil
      }
    }
    else
    {
      // Fallback on earlier versions
      Log.error("spawn is unavailable")
      return nil
    }
  }
}
