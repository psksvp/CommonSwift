import Foundation
import CommonSwift

struct SensorValue : Codable
{
  public let id: UUID
  public let moisture: Float
  public let temperature: Float
  public let humidity: Int
  public let light: Float
}

class GrowModule
{
  let port: SerialPort
  let ready: Bool
  
  var alive: Bool
  {
    guard let s = self.sendRequest("alive") else {return false}
    return "ready" == s
  }
  
  var id: String?
  {
    sendRequest("id")
  }
  
  var sensor: SensorValue?
  {
    guard let s = self.sendRequest("sensor") else {return nil}
    do
    {
      let v = try JSONDecoder().decode(SensorValue.self, from: s.data(using: .utf8)!)
      return v
    }
    catch
    {
      return nil
    }
  }
  
  init(port: String)
  {
    self.port = SerialPort(path: port, baud: .b9600)
    if let s = self.port.readLine()
    {
      print(s)
      self.ready = true
    }
    else
    {
      print("???")
      self.ready = false
    }
  }
  
  func sendRequest(_ cmd: String) -> String?
  {
    self.port.writeLine(cmd)
    Thread.sleep(forTimeInterval: 1)
    guard let s = self.port.readLine() else {return nil}
    return s
  }
  
}


let g = GrowModule(port: "/dev/cu.usbserial-2130")
while(!g.ready)
{
  print("waiting ...")
  Thread.sleep(forTimeInterval: 1)
}

print(">", terminator: "")
while let cmd = readLine()
{
  if cmd == "quit"
  {
    break;
  }
  
  switch cmd
  {
    case "quite"  : break
    case "alive"  : print(g.alive)
    case "sensor" : print(g.sensor)
    case "id"     : print(g.id)
    default       : print("cmd??")
  }
  
  print(">", terminator: "")
}

print("done")

  


//print("HelloWorld")
////mat()
////
////func mat()
////{
////  let v = Vector<Int>([1, 2, 3, 4])
////  print(v)
////  print("------")
////  let m = Matrix<Int>(rows: 2, cols: 3, [1, 2, 3, 4, 5, 6])!
////  print(m)
////  print("------")
////  print(m.vector(row: 0))
////  print("------")
////  print(m.vector(row: 1))
////  print("------")
////  print(m.vector(column: 0))
////  print("------")
////  print(m.vector(column: 1))
////  print("------")
////  print(m.vector(column: 2))
////  print("------")
////  
////  let c2 = m.vector(column: 2)
////  c2[0] = -1
////  print(m)
////  print("------")
////  
////}
//
//
//
//func testFSMonitor()
//{
//  let m = FS.monitor(directory: URL(fileURLWithPath: "/home/psksvp/workspace/temp"))
//  {
//    changed in
//    
//    print(changed)
//  }
//  print("running \(m)")
//
//  RunLoop.main.run() // need fucking runloop....
//}
//  
//  
//@available(macOS 10.13, *)
//func testRemoteRun()
//{
//  if let lines = OS.remoteRun(command: ["cd", "workspace", "&&", "ls", "-l"],
//                                 keyFile: "/Users/psksvp/.ssh/joseon",
//                              remoteHost: "psksvp@joseon.local")
//  {
//    for l in lines.components(separatedBy: "\n")
//    {
//      print(l)
//    }
//  }
//  else
//  {
//    print("fail")
//  }
//}
//
//
//@available(macOS 10.13, *)
//func testInterativeRemoteRun()
//{
//  let sw = OS.interactiveRemoteRun(command: ["/home/psksvp/.local/swift/usr/bin/swift"],
//                                   keyFile: "/Users/psksvp/.ssh/joseon",
//                                remoteHost: "psksvp@joseon.local")
//  {
//    (t) -> () in
//    
//    switch t
//    {
//      case .stdOut(let s) : print("stdOut: \(s)")
//      case .stdError(let s) : print("stdErr: \(s)")
//    }
//   
//  }
//
//  var running = true
//
//  while running //&& sw.running
//  {
//    if let s = readLine(),
//       s.count > 0,
//       "quit" != s
//    {
//      sw.sendInput(s)
//    }
//    else
//    {
//      sw.interrupt()
//      running = !running
//    }
//  }
//  
//  print("exiting")
//}
//
//@available(macOS 10.13, *)
//func testSpawnInteractive()
//{
//  let sw = OS.SpawnInteractive(["/Users/psksvp/Local/python/bin/python3", "-m", "http.server", "8001"]) //(["/usr/bin/swift"])
//  {
//    (t) -> () in
//    
//    switch t
//    {
//      case .stdOut(let s)   : print("stdOut: \(s)")
//      case .stdError(let s) : print("stdErr: \(s)")
//    }
//   
//  }
//
//  var running = true
//
//  while running && sw.running
//  {
//    print("enter > ")
//    if let s = readLine(),
//       s.count > 0,
//       "quit" != s
//    {
//      sw.sendInput(s)
//    }
//    else
//    {
//      sw.interrupt()
//      running = !running
//    }
//  }
//  
//  print("exiting")
//}
//
//



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
