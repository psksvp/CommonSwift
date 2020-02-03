import Foundation 

public extension StringProtocol
{
  func trim() -> String
  {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
	
	// mod to compile on swift 5,1 from https://gist.github.com/pwightman/64c57076b89c5d7f8e8c
  func javaScriptEscapedString() -> String 
	{
    // Because JSON is not a subset of JavaScript, the LINE_SEPARATOR and PARAGRAPH_SEPARATOR unicode
    // characters embedded in (valid) JSON will cause the webview's JavaScript parser to error. So we
    // must encode them first. See here: http://timelessrepo.com/json-isnt-a-javascript-subset
    // Also here: http://media.giphy.com/media/wloGlwOXKijy8/giphy.gif
    let str = self.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
                  .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
    // Because escaping JavaScript is a non-trivial task (https://github.com/johnezang/JSONKit/blob/master/JSONKit.m#L1423)
    // we proceed to hax instead:
    let data = try! JSONSerialization.data(withJSONObject:[str], options: [])
    let encodedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
    return encodedString.substring(with: NSMakeRange(1, encodedString.length - 2))
  }
}