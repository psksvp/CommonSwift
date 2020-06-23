import Foundation
import CommonSwift

print("Hello me")

class JupiterAces : ASM
{
  let counter = ASM.state("counter", 0)
  
  init()
  {
    super.init([counter])
  }
  
  override func step() -> Bool
  {
    if counter[] > 10
    {
      return false
    }
    else
    {
      counter[] = counter[] + 1
      print(counter[])
      return true
    }
  }
}

let j = JupiterAces()

j.run()
