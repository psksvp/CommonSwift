import Foundation
import CommonSwift


main()

func main()
{
  let port = SerialPort(path: "/dev/cu.usbmodem14201", baud: .b9600)
  //Thread.sleep(forTimeInterval: 1000)
  print(port.readLine())
  while true
  {
    print("Enter Text:")
    if let s = readLine()
    {
      if 0 == s.count
      {
        break
      }
      port.writeLine(s)
    }
    else
    {
      print("kb readLine error")
    }
    
    Thread.sleep(forTimeInterval: 1)
    
    if let r = port.readLine()
    {
      print("read \(r)")
    }
    else
    {
      print("read fail")
    }
  }
  
  print("exiting")
}
