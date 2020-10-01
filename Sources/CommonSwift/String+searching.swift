import Foundation 

public extension StringProtocol
{
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
  func liftRegexPattern(_ pattern: String) -> [(Int, String)]
  {
     var indices = [(Int,String)]()
     var searchStartIndex = self.startIndex

     while searchStartIndex < self.endIndex,
           let range = self.range(of: pattern, options: [.regularExpression], range: searchStartIndex..<self.endIndex),
           !range.isEmpty
     {
       let index = distance(from: self.startIndex, to: range.lowerBound)
       let text = String(self[range])
       indices.append((index, text))
       searchStartIndex = range.upperBound
     }

     return indices
  }
  
  func regexLift(usingPattern pattern: String) -> [String]
  {
    var result = [String]()
    let regex = try? NSRegularExpression(pattern: pattern, options:[])
    for (_, mmBlock) in self.liftRegexPattern(pattern)
    {
      if let match = regex?.firstMatch(in: mmBlock,
                                       options: [],
                                       range: NSRange(mmBlock.startIndex..<mmBlock.endIndex, in: mmBlock)),
         let range = Range(match.range(at: 1), in: mmBlock)
      {
        result.append(String(mmBlock[range]))
      }
    }
    
    return result
  }
}
