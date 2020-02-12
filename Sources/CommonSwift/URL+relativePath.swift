import Foundation

// modified from 
// https://stackoverflow.com/questions/48351839/swift-equivalent-of-rubys-pathname-relative-path-from
// base is assumed to be a dir
extension URL
{
  func relativePath(from base: URL) -> String?
  {
    // Ensure that both URLs represent files:
    guard self.isFileURL && base.isFileURL  else
    {
      return nil
    }

    // Remove/replace "." and "..", make paths absolute:
    let destComponents = self.standardized.pathComponents
    let baseComponents = base.standardized.pathComponents

    // Find number of common path components:
    let i = Set(destComponents).intersection(Set(baseComponents)).count

    // Build relative path:
    let relComponents = Array(repeating: "..", count: baseComponents.count - i) +
                        destComponents[i...]
    return relComponents.joined(separator: "/")
  }
}