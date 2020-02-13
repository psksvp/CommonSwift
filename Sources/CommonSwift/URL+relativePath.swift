import Foundation

// modified from 
// https://stackoverflow.com/questions/48351839/swift-equivalent-of-rubys-pathname-relative-path-from
// base is assumed to be a dir
public extension URL
{
  func relativePath(from base: URL) -> String?
  {
    // Ensure that both URLs represent files:
		guard self.isFileURL &&
		      FileManager.default.fileExists(atPath: self.path) else
		{
			NSLog("self is not a fileURL or it does not exists")
			return nil
		}
		
	  var isDir = ObjCBool(true)
	  guard FileManager.default.fileExists(atPath: base.path, isDirectory: &isDir) &&
		      isDir.boolValue else
		{
			NSLog("base is not a directory or it does not exists")
			return nil
		}			
		

    // Remove/replace "." and "..", make paths absolute:
    let destComponents = self.resolvingSymlinksInPath().pathComponents
    let baseComponents = base.resolvingSymlinksInPath().pathComponents

    // Find number of common path components:
    //let i = Set(destComponents).intersection(Set(baseComponents)).count
		var i = 0
		while i < destComponents.count && i < baseComponents.count
		      && destComponents[i] == baseComponents[i]
		{
		   i += 1
		}

    // Build relative path:
    let relComponents = Array(repeating: "..", count: baseComponents.count - i) +
                        destComponents[i...]
    return relComponents.joined(separator: "/")
  }
}