//
//  InterfaceController.swift
//  BitWatch WatchKit Extension
//
//  Created by Greg Heo on 2014-11-19.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation
import BitWatchKit

class InterfaceController: WKInterfaceController {
  @IBOutlet weak var priceLabel: WKInterfaceLabel!
  @IBOutlet weak var image: WKInterfaceImage!
  @IBOutlet weak var lastUpdatedLabel: WKInterfaceLabel!

  let tracker = Tracker()
  var updating = false

  override func awakeWithContext(context: AnyObject!) {
    super.awakeWithContext(context)

    NSLog("%@ awakeWithContext", self)

    updatePrice(tracker.cachedPrice())
    image.setHidden(true)
    updateDate(tracker.cachedDate())
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    NSLog("%@ will activate", self)

    update()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    NSLog("%@ did deactivate", self)
    super.didDeactivate()
  }

  @IBAction func refreshTapped() {
    update()
  }

  private func updateDate(date: NSDate) {
    self.lastUpdatedLabel.setText("Last updated \(Tracker.dateFormatter.stringFromDate(date))")
  }

  private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
    if originalPrice.isEqualToNumber(newPrice) {
      // 1
      image.setHidden(true)
    } else {
      // 2
      if newPrice.doubleValue > originalPrice.doubleValue {
        image.setImageNamed("Up")
      } else {
        image.setImageNamed("Down")
      }
      image.setHidden(false)
    }
  }

  private func updatePrice(price: NSNumber) {
    priceLabel.setText(Tracker.priceFormatter.stringFromNumber(price))
  }

  private func update() {
    if !updating {
      updating = true
      let originalPrice = tracker.cachedPrice()
      tracker.requestPrice { (price, error) -> () in
        if error == nil {
          self.updatePrice(price!)
          self.updateDate(NSDate())
          self.updateImage(originalPrice, newPrice: price!)
        }
        self.updating = false
      }
    }
  }
}
