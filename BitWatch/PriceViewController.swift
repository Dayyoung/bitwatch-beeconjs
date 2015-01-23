//
//  PriceViewController.swift
//  BitWatch
//
//  Created by Mic Pringle on 19/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//  http://www.raywenderlich.com/89562/watchkit-tutorial-with-swift-getting-started

import UIKit
import BitWatchKit

import WebKit


class PriceViewController: UIViewController, WKScriptMessageHandler ,WKUIDelegate {
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var horizontalLayoutConstraint: NSLayoutConstraint!
    
  @IBOutlet weak var refreshButton: UIButton!
    
  @IBOutlet var containerView : UIView! = nil
  var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        
        var contentController = WKUserContentController();
        
        var userScript = WKUserScript(
            source:"AreYouReady()",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: false
        )
        
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(self, name: "beeconJSHandler")
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame:self.containerView.bounds,
            configuration: config)
        
        self.containerView = self.webView
        
        self.webView?.UIDelegate = self
    }

  let tracker = Tracker()
  let xOffset: CGFloat = -22
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var url = NSURL(string:"http://beeconjs-dayyoung-1.c9.io/beehybrid2.html")
    //var url = NSURL(string:"http://google.com")
    var req = NSURLRequest(URL: url!)
    self.webView!.loadRequest(req);
    // Do any additional setup after loading the view, typically from a nib.
    
    view.tintColor = UIColor.blackColor()
    
    horizontalLayoutConstraint.constant = 0
    
    //updateCoin();
    
    refreshButton.addTarget(self, action: "updateCoin", forControlEvents: UIControlEvents.TouchDown)
    
  }
  func updateCoin()
  {
    let originalPrice = tracker.cachedPrice()
    updateDate(tracker.cachedDate())
    updatePrice(originalPrice)
    tracker.requestPrice { (price, error) -> () in
        if error? == nil {
            self.updateDate(NSDate())
            self.updateImage(originalPrice, newPrice: price!)
            self.updatePrice(price!)
            
            var coinData = Tracker.priceFormatter.stringFromNumber(price!)
            var coinDate = "\(Tracker.dateFormatter.stringFromDate(NSDate()))";
            self.webView?.evaluateJavaScript("updateBeetCoin('"+coinDate+"','"+coinData!+"')", completionHandler: nil)
        }
    }
    
  }
  
  private func updateDate(date: NSDate) {
    self.dateLabel.text = "Last updated \(Tracker.dateFormatter.stringFromDate(date))"
  }
  
  private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
    if originalPrice.isEqualToNumber(newPrice) {
      horizontalLayoutConstraint.constant = 0
    } else {
      if newPrice.doubleValue > originalPrice.doubleValue {
        imageView.image = UIImage(named: "Up")
      } else {
        imageView.image = UIImage(named: "Down")
      }
      horizontalLayoutConstraint.constant = xOffset
    }
  }
  
  private func updatePrice(price: NSNumber) {
    self.priceLabel.text = Tracker.priceFormatter.stringFromNumber(price)
  }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "beeconJSHandler")
        {
            println("BeeconJS.com : \(message.body)");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        
        //println("webView:\(webView) runJavaScriptAlertPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        let alertController = UIAlertController(title: frame.request.URL.host, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler()
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
}
