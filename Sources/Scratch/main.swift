import Foundation
import CommonSwift
import Cocoa


if #available(OSX 10.13, *)
{
  testSpawnInteractive()
}
else
{
  // Fallback on earlier versions
}

@available(OSX 10.13, *)
func testSpawnInteractive()
{
  let sw = OS.SpawnInteractive(["/usr/bin/swift"])
  {
    (stdOut, stdErr) -> () in
    
    print(" \(stdOut)   \(stdErr) ")
  }
  
  var running = true
  
  DispatchQueue.global(qos: .background).async
  {
    while running
    {
      print("enter > ")
      if let s = readLine(),
         s.count > 0
      {
        sw.pipe(s)
      }
      else
      {
        running = !running
      }
    }
  }
  
  RunLoop.main.run()
}

//main()
//
//func main()
//{
//  let m = CommonDialogs.listChooser(["hello", "world", "sun", "river"])
//  print(m)
//}
//
//
//
//func testImage()
//{
//  do
//  {
//    let imageData = try Data(contentsOf: URL(fileURLWithPath: "/Users/psksvp/Pictures/psksvp.jpg"))
//    let image = NSImage(data: imageData)!
//    image.lockFocus();
//    "HelloWorld".draw(at: CGPoint(x: 10, y: 10))
//    image.unlockFocus()
//    let outputData = image.tiffRepresentation
//    try outputData?.write(to: URL(fileURLWithPath: "/Users/psksvp/Desktop/output.tiff"))
//  }
//  catch
//  {
//    print("fail to load")
//  }
//}
//
//
//func mainSerial()
//{
//  let port = SerialPort(path: "/dev/cu.usbmodem14201", baud: .b9600)
//  //Thread.sleep(forTimeInterval: 1000)
//  print(port.readLine()!)
//  while true
//  {
//    print("Enter Text:")
//    if let s = readLine()
//    {
//      if 0 == s.count
//      {
//        break
//      }
//      port.writeLine(s)
//    }
//    else
//    {
//      print("kb readLine error")
//    }
//    
//    Thread.sleep(forTimeInterval: 1)
//    
//    if let r = port.readLine()
//    {
//      print("read \(r)")
//    }
//    else
//    {
//      print("read fail")
//    }
//  }
//  
//  print("exiting")
//}
