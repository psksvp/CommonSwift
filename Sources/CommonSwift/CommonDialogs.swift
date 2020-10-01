//
//  File.swift
//  
//
//  Created by psksvp on 1/10/20.
//
#if os(macOS)
import Foundation

@discardableResult
func osascriptRun(_ code: String) -> String?
{
  return ["/usr/bin/osascript"].spawn(stdInput: code)
}

class CommonDialogs
{
  private init() {}
  
  class func listChooser(_ ls: [String],
                        title: String = "Select One" ) -> Int?
  {
    let script = """
    set ls to {\(ls.map {"\"\($0)\""}.joined(separator: ","))}
    set r to choose from list ls with prompt "\(title)" default items {\"\(ls[0])\"}
    r

    """
    
    guard let selected = osascriptRun(script) else {return nil}
    return ls.firstIndex(where: {$0 == selected.trim()})
  }
  
  class func textInput(prompt: String = "Plase Enter text") -> String?
  {
    let script = """
    set r to display dialog "\(prompt)" default answer "" with icon note
    r
    """
    
    guard let response = osascriptRun(script) else {return nil}
    print(response)
    guard let m = response.trim().range(of: "text returned:") else {return nil}
    return String(response[m.upperBound ..< response.endIndex])
  }
  
  class func showText(_ s: String)
  {
    osascriptRun("display dialog \"\(s)\"")
  }
  
  class func chooseFile(prompt: String = "Plase choose a file:") -> String?
  {
    let script = """
    set r to choose file name with prompt "\(prompt)"
    """
    guard let r = osascriptRun(script) else {return nil}
    return "/Volumes/\(r.replacingOccurrences(of: ":", with: "/"))"
  }
  
  class func chooseColor() -> (Float32, Float32, Float32)?
  {
    guard let r = osascriptRun("set theColor to choose color default color {0, 65535, 0}")
    else {return nil}
    
    let m = r.components(separatedBy: ",")
    guard  m.count >= 3 else {return nil}
    
    return (Float32(m[0])! / Float32(65535),
            Float32(m[1])! / Float32(65535),
            Float32(m[2])! / Float32(65535))
  }
}

#endif
