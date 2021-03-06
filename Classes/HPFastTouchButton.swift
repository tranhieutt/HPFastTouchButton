//
//  HPFastTouchButton.swift
//  HPFastTouchButton
//
//  Created by Huy Pham on 2/14/15.
//  Copyright (c) 2015 CoreDump. All rights reserved.
//

import UIKit

private class Target {
  
  weak var target: AnyObject?
  var action = Selector("")
  var event = UIControlEvents.TouchUpInside
}

private class ImageForState {
  
  var image: UIImage?
  var state = UIControlState.Normal
}

class HPFastTouchButton: UIView {
  
  // Override super class properties
  override var frame : CGRect {
    didSet {
      self.imageView.frame = self.bounds
      self.overlayView.frame = self.bounds
      self.titleLabel.frame = self.bounds
    }
  }
  
  var selectedColor: UIColor = UIColor(red: 217.0/255.0,
    green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
  
  // Views
  // Private
  private let overlayView = UIView()
  private let imageView = UIImageView()
  
  // Public
  let titleLabel = UILabel()
  var selected: Bool = false
  
  var enable: Bool = true {
    
    didSet {
      self.userInteractionEnabled = self.enable
    }
  }
  
  // Class properties
  private var imageForStateS: [ImageForState] = []
  private var targets: [Target] = []
  private var currentState = UIControlState.Normal
  
  // Custom init.
  required init(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
  }
  
  override init() {
    
    super.init(frame: CGRectZero)
    commonInit()
  }
  
  func commonInit() {
    
    self.backgroundColor = UIColor.clearColor()
    self.initView()
  }
  
  func initView() {
    
    self.imageView.backgroundColor = UIColor.clearColor()
    self.imageView.userInteractionEnabled = false
    
    self.overlayView.backgroundColor = UIColor.clearColor()
    self.overlayView.userInteractionEnabled =  false
    
    self.titleLabel.backgroundColor = UIColor.clearColor()
    
    self.addSubview(self.imageView)
    self.addSubview(self.overlayView)
    self.addSubview(self.titleLabel)
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    
    self.currentState = UIControlState.Highlighted
    self.setNeedsDisplay()
    if let nextResponder = self.nextResponder() {
      nextResponder.touchesBegan(touches, withEvent: event)
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    
    self.currentState = UIControlState.Normal
    self.setNeedsDisplay()
    if let nextResponder = self.nextResponder() {
      nextResponder.touchesMoved(touches, withEvent: event)
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    
    self.currentState = UIControlState.Normal
    self.setNeedsDisplay()
    self.triggerSelector()
    if let nextResponder = self.nextResponder() {
      nextResponder.touchesEnded(touches, withEvent: event)
    }
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    
    self.currentState = UIControlState.Normal
    self.setNeedsDisplay()
    if let nextResponder = self.nextResponder() {
      nextResponder.touchesEnded(touches, withEvent: event)
    }
  }
  
  private func compareTarget(target1: Target, target2: Target) -> Bool {
    
    if let targetObject1: AnyObject = target1.target {
      if let targetObject2: AnyObject = target2.target {
        if targetObject1.isEqual(targetObject2) {
          if target1.action == target2.action && target1.event == target2.event {
            return true
          }
        }
      }
    }
    return false
  }
  
  private func triggerSelector() {
    
    for target in targets {
      if let object: AnyObject = target.target {
        let delay = 0.0
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
          NSThread.detachNewThreadSelector(target.action, toTarget: object, withObject: object)
        })
      }
    }
  }
  
  private func imageForState(state: UIControlState) -> UIImage? {
    
    var normalImage: UIImage?
    for imageForState in self.imageForStateS {
      if imageForState.state == state {
        return imageForState.image
      } else if imageForState.state == UIControlState.Normal {
        normalImage = imageForState.image
      }
    }
    return normalImage
  }
  
  private func addImageForState(imageForState: ImageForState) {
    
    for (index, imageForStateElement) in enumerate(imageForStateS) {
      if imageForStateElement.state == imageForState.state {
        self.imageForStateS.removeAtIndex(index)
      }
    }
    self.imageForStateS.append(imageForState)
  }
  
  func addTarget(target: AnyObject?, action: Selector,
    forControlEvents controlEvents: UIControlEvents) {
      
      let newTarget = Target()
      newTarget.target = target
      newTarget.action = action
      newTarget.event = controlEvents
      
      for targetElement in targets {
        if compareTarget(newTarget, target2: targetElement) {
          return
        }
      }
      targets.append(newTarget)
  }
  
  func removeTarget(target: AnyObject?, action: Selector,
    forControlEvents controlEvents: UIControlEvents) {
      
      let newTarget = Target()
      newTarget.target = target
      newTarget.action = action
      newTarget.event = controlEvents
      
      for (index, targetElement) in enumerate(targets) {
        if compareTarget(newTarget, target2: targetElement) {
          targets.removeAtIndex(index)
        }
      }
  }
  
  func setImage(image: UIImage?, forState state: UIControlState) {
    
    let imageForState = ImageForState()
    imageForState.image = image
    imageForState.state = state
    self.addImageForState(imageForState)
  }
  
  
  func setTitle(title: String?, forState state: UIControlState) {
    
    NSLog("Not supported (Comming soon)... I'm a lazy boy, I need food, I love food, I love milk carrot, it's delicious... ;_;")
  }
  
  override func drawRect(rect: CGRect) {
    
    super.drawRect(rect)
    
    // Change background color.
    switch self.currentState {
    case UIControlState.Normal:
      self.overlayView.backgroundColor = UIColor.clearColor()
    case UIControlState.Highlighted:
      self.overlayView.backgroundColor = self.selectedColor
    default:
      self.overlayView.backgroundColor = UIColor.clearColor()
    }
    
    // Change image for state.
    if  self.selected {
      if let image = self.imageForState(UIControlState.Selected) {
        self.imageView.image = image
      } else {
        self.imageView.image = self.imageForState(self.currentState)
      }
    } else {
      self.imageView.image = self.imageForState(self.currentState)
    }
    
    // Set overlay alpha.
    if let image = self.imageView.image {
      self.overlayView.alpha = 0.6
    } else {
      self.overlayView.alpha = 1.0
    }
  }
  
  func debug(message: String, filename: String = __FILE__,
    function: String = __FUNCTION__, line: Int = __LINE__) {
      
      println("💚[\(filename.lastPathComponent):\(line)] \(function) 👉 \(message)")
  }
}
