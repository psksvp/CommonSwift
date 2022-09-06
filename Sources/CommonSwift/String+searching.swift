import Foundation 

public extension StringProtocol
{
  func matchAll(usingRegex p: String) -> [(range: Range<String.Index>, text: String)]
  {
    var indices = [(Range<String.Index>,String)]()
    var searchStartIndex = self.startIndex

    while searchStartIndex < self.endIndex,
          let range = self.range(of: p, options: [.regularExpression], range: searchStartIndex..<self.endIndex),
          !range.isEmpty
    {
        let text = String(self[range])
        indices.append((range, text))
        searchStartIndex = range.upperBound
    }

    return indices
  }
  
  func matchAndLiftGroups(usingRegex pattern: String) -> [(match: (range: Range<String.Index>, text: String), groups: [String])]
  {
    let r = self.matchAll(usingRegex: pattern).compactMap
    {
      (range: Range<String.Index>, text: String) -> (match: (range: Range<String.Index>, text: String), groups: [String])? in
      
      let regex = try? NSRegularExpression(pattern: pattern, options:[])
      if let match = regex?.firstMatch(in: text,
                                       options: [],
                                       range: NSRange(text.startIndex ..< text.endIndex, in: text))
      {
        let lifted = (0 ..< match.numberOfRanges).map
                     {
                       (i: Int) -> String in
                     
                       let range = Range(match.range(at: i), in: text)!
                       return String(text[range])
                     }
        
        if lifted.isEmpty
        {
          return nil
        }
        else if 1 == lifted.count
        {
          return ((range, lifted.first!), [String]())
        }
        else
        {
          return ((range, lifted.first!), Array(lifted.dropFirst()))
        }
      }
      else
      {
        return nil
      }
    }
    
    return r
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
	
  // TODO: outlaw this function
  // modified from https://stackoverflow.com/questions/40413218/swift-find-all-occurrences-of-a-substring
  @available(*, deprecated, message: "use matchAll(usingRegex p: String) -> [(range: Range<String.Index>, text: String)]")
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
  
  // TODO: outlaw this function
  @available(*, deprecated, message: "matchAndLiftGroups(usingRegex pattern: String) -> [(match: String, groups: [String])]")
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
