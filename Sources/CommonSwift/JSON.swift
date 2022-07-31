//
//  File.swift
//  
//
//  Created by psksvp on 16/7/2022.
//

import Foundation

public func codeable2JSON<T: Codable>(_ obj: T) -> String?
{
  do
  {
    let jsonEnc = JSONEncoder()
    jsonEnc.outputFormatting = .prettyPrinted
    let data = try jsonEnc.encode(obj)
    return String(decoding: data, as: UTF8.self)
  }
  catch
  {
    Log.error(error.localizedDescription)
    return nil
  }
}

public func JSON2Codable<T: Codable>(_ jsonString: String) -> T?
{
  do
  {
    guard let data = jsonString.data(using: .utf8) else {return nil}
    let obj = try JSONDecoder().decode(T.self, from: data)
    return obj
  }
  catch
  {
    Log.error(error.localizedDescription)
    return nil
  }
}

public func readJSON<T: Codable>(_ path: String) -> T?
{
  guard let json = FS.readText(fromLocalPath: path) else
  {
    Log.error("Fail to read JSON file: \(path)")
    return nil
  }
  
  return JSON2Codable(json)
}

@discardableResult
public func writeJSON<T: Codable>(_ obj: T, toFilePath: String) -> Bool
{
  guard let json = codeable2JSON(obj) else {return false}
  
  // TODO: fix this to return boolean
  FS.writeText(inString: json, toPath: toFilePath)
  
  return true
}
