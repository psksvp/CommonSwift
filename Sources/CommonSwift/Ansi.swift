
public class ANSI
{
  static let esc = "\u{001B}["
  
  public enum Color: Int
  {
    case black = 30
    case red = 31
    case green = 32
    case yellow = 33
    case blue = 34
    case magenta = 35
    case cyan = 36
    case white = 37
    case normal = 0
    case bold = 1
    case underline = 4
    case blink = 5
    case reverse = 7
    case concealed = 8
  }

  private init() {}

  public class func setCursor(row: Int, col: Int) -> Void { print("\(esc)\(row);\(col)H")}
  public class func cursorUp(n: Int) -> Void { print("\(esc)\(n)A")}
  public class func cursorDown(n: Int) -> Void {print("\(esc)\(n)B")}
  public class func cursorForward(n: Int) -> Void {print("\(esc)\(n)C")}
  public class func cursorBackward(n: Int) -> Void {print("\(esc)\(n)D")}
  public class func clearScreen() -> Void {print("\(esc)2J")}
  public class func clearLine() -> Void {print("\(esc)K")}
  public class func setForeground(color: ANSI.Color) -> Void {print("\(esc)\(color.rawValue)m")}
  public class func setBackground(color: ANSI.Color) -> Void {print("\(esc)\(color.rawValue + 10)m")}
  public class func setTextAttribute(a: Int) -> Void {print("\(esc)\(a)m")}
    
  public class func test() -> Void
  {
    clearScreen()
    setCursor(row: 10, col: 10)
    setForeground(color: .red)
    setBackground(color: .green)
    print("HelloWorld")
  }
}
