import Foundation

#if canImport(WebKit)
import WebKit

public extension WKWebView
{
  func scrollToVerticalPoint(_ y:Int)
  {
    let js = "window.scrollTo(0, \(y))"
    self.evaluateJavaScript(js)
    {
      (_, error) in
      
      if let _ = error
      {
        dump(error)
      }
    }
  }
  
  func readPageVerticalOffset(f: @escaping (Int) -> Void)
  {
    self.evaluateJavaScript("window.pageYOffset")
    {
      result, error in
      if let y = result as? Int
      {
        //self.savedPageYOffset = y
        f(y)
      }
      else
      {
        dump(error)
      }
    }
  }
  
  func scrollToAnchor(_ s:String) -> Void
  {
    let anchor = "\"#\(s.lowercased().trim().replacingOccurrences(of: " ", with: "-"))\""
    let js = "location.hash = \(anchor);"
    //Log.info("about to eval javascript \(js)")
    self.evaluateJavaScript(js)
    {
      (sender, error) in
      dump(error)
    }
  }
  
  func scrollToParagrah(withSubString s: String, searchReverse: Bool = false) -> Void
  {
    let loopHead = searchReverse ? "for(var i = x.length - 1; i >= 0; i--)" :
                                   "for(var i = 0; i < x.length; i++)"
    let js = """
    var bgColor = document.body.style.backgroundColor;
    var x = document.querySelectorAll("p, q, li, h1, h2, h3");
    var s = \(s)
    \(loopHead)
    {
      if(x[i].textContent.indexOf(s) >= 0)
      {
        x[i].scrollIntoView({behavior: "smooth", block: "start", inline: "start"});
        x[i].style.backgroundColor = "Azure";
        break;
      }
      else
      {
        x[i].style.backgroundColor = bgColor;
      }
    }
    """
    //Log.info("about to eval javascript\n\(js)")
    self.evaluateJavaScript(js)
    {
      (sender, error) in
      if let _ = error
      {
        dump(error)
      }
    }
  }
  
  // https://stackoverflow.com/questions/26851630/javascript-synchronous-native-communication-to-wkwebview
  func syncEvaluateJavaScript(_ script: String) -> Any?
  {
    var result: Any?
    var done = false
    let timeout = 3.0

    evaluateJavaScript(script)
    {
      (obj: Any?, _: Error?)->Void in
      result = obj
			done = true
//      if let e = error
//			{
//				//Log.error(e as! String)
//			}
    }
		
    while !done
    {
      let reason = CFRunLoopRunInMode(CFRunLoopMode.defaultMode, timeout, true)
      if reason != CFRunLoopRunResult.handledSource
      {
        break
      }
    }
   
    return result ?? nil
  }
}

#endif
