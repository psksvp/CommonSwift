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
//  FS.swift
//  SwiftScratch
//
//  Created by psksvp on 18/9/19.
//  Copyright © 2019 com.psksvp. All rights reserved.
//

import Foundation

public class FS
{
  private init() {}
  
  #if !os(iOS)
  @available(macOS 10.12, *)
  public static let tempDir = FileManager.default.temporaryDirectory.path
  #endif
  
  public class func readDictionary<K,V>(fromLocalPath path:String) -> [K:V]?
  {
    func onError()
    {
      Log.error("error reading dictionary from path: \(path)")
    }
    guard let dict = NSDictionary(contentsOf: URL(fileURLWithPath:path)) as? [K:V] else {return nil}
    return dict
  }
  
  @available(OSX 10.13, *)
  public class func writeDictionary<K,V>(_ d: [K:V], toLocalPath path:String)
  {
    do
    {
      #if os(macOS)
      try NSDictionary(dictionary: d).write(to: URL(fileURLWithPath:path))
      #else
      try NSDictionary(dictionary: d).write(to: URL(fileURLWithPath:path))
      #endif
    }
    catch
    {
      Log.error("Dictionary fail to write to: \(path)")
      Log.error("error: \(error)")
    }
  }
  
  
  public class func readText(fromURL url: URL) -> String?
  {
    do
    {
      let text = try String(contentsOf: url)
      return text
    }
    catch
    {
      return nil
    }
  }
  
  public class func readText(fromLocalPath path:String) -> String?
  {
    do
    {
      let text = try String(contentsOf: URL(fileURLWithPath:path))
      return text
    }
    catch
    {
      return nil
    }
  }
  
  public class func writeText(inString text:String, toPath path:String) -> Void
  {
    do
    {
      try text.write(to: URL(fileURLWithPath: path),
             atomically: true,
               encoding: String.Encoding.utf8)
    }
    catch
    {
      Log.error("FS.writeText Fail -> \(path)")
    }
  }
 
 public class func directoryExists(atPath p: String) -> Bool
 {
   var dir = ObjCBool(true)
   let s = FileManager.default.fileExists(atPath: p, isDirectory: &dir)
   return s && dir.boolValue
 }
 
 public class func createDirectory(_ p: String) -> Bool
 {
  let fm = FileManager.default
  do
  {
    let url = URL(fileURLWithPath: p, isDirectory: true)
    try fm.createDirectory(at: url, withIntermediateDirectories: true)
    return true
  }
  catch
  {
    Log.error("FS.createDirectory fail to create \(p)")
    return false
  }
 }
 
 public class func createDirectory(_ p: String, ignoreIfExists: Bool) -> Bool
 {
   if !directoryExists(atPath: p)
   {
    return createDirectory(p)
   }
 
   return true
 }
 
  public class func applicationSupportPath(forName name: String,
                                          createIfNotExists: Bool) -> String?
  {
    do
    {
      let url = try FileManager.default.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
      let appDir = "\(url.path)/\(name)"
			if !createDirectory(appDir, ignoreIfExists: true)
			{
        return nil
			}
			return appDir
    }
    catch
    {
    	Log.error("FS.applicationSupportDirectory fail with -> \(name)")
			return nil
    }
	}
	
	public class func applicationSupportPath(forName name: String, 
	                                         andResourceName rsc: String, 
                                           createIfNotExists: Bool = true) -> String?
	{
		guard let appDir = applicationSupportPath(forName: name, createIfNotExists: true) else {return nil}
		let rscDir = "\(appDir)/\(rsc)"
		if !createDirectory(rscDir, ignoreIfExists: true)
		{
			return nil
		}
		return rscDir
	}
  
  public class func contentsOfDirectory(_ path:String) -> [String]?
  {
    let fm = FileManager.default
    do
    {
      let contents = try fm.contentsOfDirectory(atPath: path)
      return contents
    }
    catch
    {
      Log.error("FS.contentsOfDirectory fail to get contents of path -> \(path)")
      return nil
    }
  }
  
  
  public class func writeBytes(inArray a:[UInt8], toPath path:String) -> Void
  {
    do
    {
      let data = Data(a)
      try data.write(to: URL(fileURLWithPath:path))
    }
    catch
    {
      Log.error("FS.writeBytes fail to write to file -> \(path)")
    }
  }
  
  public class func readBytes(inFile path: String) -> [UInt8]?
  {
    do
    {
       let data = try Data(contentsOf: URL(fileURLWithPath: path))
       return [UInt8](data)
    }
    catch
    {
      Log.error("FS.readBytes fail to read from file -> \(path)")
      return nil
    }
  }
  
  public class func readBytes(inFile path: String, length:Int) -> [UInt8]?
  {
    if let stream:InputStream = InputStream(fileAtPath: path)
    {
      var buffer = [UInt8](repeating: 0, count: length)
      stream.open()
      let l = stream.read(&buffer, maxLength: buffer.count) 
      stream.close()
      if -1 == l
      {
        Log.error("FS.readBytes fail to open file -> \(path)")
        return nil
      }
      else 
      {
        return buffer
      }    
    }
    else
    {
      Log.error("FS.readBytes fail to open file -> \(path)")
      return nil
    }
  }
}


