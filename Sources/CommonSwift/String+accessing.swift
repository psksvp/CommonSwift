import Foundation

public extension StringProtocol
{
	@available(OSX 10.15, *)
  func isRangeInBound(_ range: NSRange) -> Bool
  {
    guard let _ = Range(range, in: self) else {return false}
    return true
  }
  
	@available(OSX 10.15, *)
  func substring(with nsrange: NSRange) -> Substring?
  {
    guard let range = Range(nsrange, in: self) else { return nil }
    return self[range] as? Substring
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
}