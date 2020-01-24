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

import Foundation

public extension Comparable 
{
  func clamped(to limits: ClosedRange<Self>) -> Self 
  {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}

public extension StringProtocol
{
  func trim() -> String
  {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func intIndex(of s: String) -> Int?
  {
    if let r = self.range(of: s)
    {
      return self.distance(from: self.startIndex, to: r.lowerBound)
    }
    else
    {
      return nil
    }
  }
	
	
  // modified from https://stackoverflow.com/questions/40413218/swift-find-all-occurrences-of-a-substring	
  func findAndLift(string: String, options mask: NSString.CompareOptions = []) -> [(Int, String)]
  {
     var indices = [(Int,String)]()
     var searchStartIndex = self.startIndex

     while searchStartIndex < self.endIndex,
           let range = self.range(of: string, options: mask, range: searchStartIndex..<self.endIndex),
           !range.isEmpty
     {
       let index = distance(from: self.startIndex, to: range.lowerBound)
       let text = String(self[range])
       indices.append((index, text))
       searchStartIndex = range.upperBound
     }

     return indices
  }
	
	//https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
	subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
	subscript(range: CountableRange<Int>) -> SubSequence 
	{
	    let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
	    return self[startIndex..<index(startIndex, offsetBy: range.count)]
	}
	subscript(range: ClosedRange<Int>) -> SubSequence 
	{
	    let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
	    return self[startIndex..<index(startIndex, offsetBy: range.count)]
	}
	subscript(range: CountablePartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
	subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
	subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
	
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


//func synchronized(_ syncedObj: Any, block: () -> ())
//{
//  objc_sync_enter(obj: syncedObj)
//  block()
//  objc_sync_exit(obj: syncedObj)
//}
