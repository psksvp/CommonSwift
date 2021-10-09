import Foundation
import CommonSwift
               
//if let lines = sshRemoteRun(command: ["cd", "workspace", "&&", "ls", "-l"],
//                      keyFile: "/Users/psksvp/.ssh/joseon",
//                   remoteHost: "psksvp@joseon.local")
//{
//  for l in lines.components(separatedBy: "\n")
//  {
//    print(l)
//  }
//}
//else
//{
//  print("fail")
//}



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
  let sw = OS.SpawnInteractive(["/Users/psksvp/Local/python/bin/python3", "-m", "http.server", "8001"]) //(["/usr/bin/swift"])
  {
    (s, t) -> () in
    
    switch t
    {
      case .stdOut : print("stdOut: \(s)")
      case .stdError : print("stdErr: \(s)")
    }
   
  }

  var running = true

  while running && sw.running
  {
    print("enter > ")
    if let s = readLine(),
       s.count > 0
    {
      if "quit" == s
      {
        sw.interrupt()
        running = false
      }
      else
      {
        sw.sendInput(s)
      }
    }
    else
    {
      running = !running
    }
  }
  
  print("exiting")
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



//class ProcessViewController: NSViewController {
//
//     var executeCommandProcess: Process!
//
//     func executeProcess() {
//
//     DispatchQueue.global().async {
//
//
//           self.executeCommandProcess = Process()
//           let pipe = Pipe()
//
//           self.executeCommandProcess.standardOutput = pipe
//           self.executeCommandProcess.launchPath = ""
//           self.executeCommandProcess.arguments = []
//           var bigOutputString: String = ""
//
//           pipe.fileHandleForReading.readabilityHandler = { (fileHandle) -> Void in
//               let availableData = fileHandle.availableData
//               let newOutput = String.init(data: availableData, encoding: .utf8)
//               bigOutputString.append(newOutput!)
//               print("\(newOutput!)")
//               // Display the new output appropriately in a NSTextView for example
//
//           }
//
//           self.executeCommandProcess.launch()
//           self.executeCommandProcess.waitUntilExit()
//
//           DispatchQueue.main.async {
//                // End of the Process, give feedback to the user.
//           }
//
//     }
//   }
//
//}
