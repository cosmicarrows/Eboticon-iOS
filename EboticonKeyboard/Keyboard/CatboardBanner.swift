//
//  CatboardBanner.swift
//  
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Licensed under the 3-clause ("New") BSD license.
//  Modified by Aaron Walton with contributions from others on GitHub

/*This is the suggestion bar. The title of this class comes from Alexei Baboulevitch original demo which had cat emoji. At this point, the names have not been updated.*/



import UIKit



class CatboardBanner: SuggestionView {
    
    var catSwitch: UISwitch = UISwitch()
    var catLabel: UILabel = UILabel()
	
	var touchToView: [UITouch:UIView]

    required init(darkMode: Bool, solidColorMode: Bool) {
		self.touchToView = [:]
		
        super.init(darkMode: darkMode, solidColorMode: solidColorMode)
		
        self.makeButtons(["", "", ""])
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func respondToSwitch() {
        UserDefaults.standard.set(self.catSwitch.isOn, forKey: kCatTypeEnabled)
        self.updateAppearance()
    }

    func suggestionButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.isExclusiveTouch = true
        btn.titleLabel!.minimumScaleFactor = 0.6
        btn.backgroundColor = UIColor(red:0.68, green:0.71, blue:0.74, alpha:1)
        btn.setTitle("", for: UIControlState())
        btn.setTitleColor(UIColor.white, for: UIControlState())
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel!.adjustsFontSizeToFitWidth = true

        return btn
    }
    
    fileprivate func makeButtons(_ labels: [String]) {

        self.btn1 = suggestionButton()
        self.btn2 = suggestionButton()
        self.btn3 = suggestionButton()

        self.LabelSuggestionButtons(labels)

        self.addSubview(self.btn1)
        self.addSubview(self.btn2)
        self.addSubview(self.btn3)

		addConstraintsToButtons()
    }

	override func draw(_ rect: CGRect) {}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
		
        if self.isHidden || self.alpha == 0 || !self.isUserInteractionEnabled {
            return nil
        }
        else
        {
            return (self.bounds.contains(point) ? self : nil)

        }

	}

	
	func addConstraintsToButtons()
	{
        var buttons = [btn1,btn2,btn3]

        for (index, button) in buttons.enumerated() {

            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)

            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)

            var rightConstraint : NSLayoutConstraint!

            if index == 2
            {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
                self.addConstraint(rightConstraint)
            }

            var leftConstraint : NSLayoutConstraint!

            if index == 0
            {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
            }
            else
            {

                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevtButton, attribute: .right, multiplier: 1.0, constant: 1)

                let firstButton = buttons[0]
                let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 1)

                widthConstraint.priority = 800
                self.addConstraint(widthConstraint)

            }

            self.removeConstraints([topConstraint, bottomConstraint, leftConstraint])
            self.addConstraints([topConstraint, bottomConstraint, leftConstraint])
        }
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let position = touch.location(in: self)
				let view = findNearestView(position)
				
				let viewChangedOwnership = self.ownView(touch, viewToOwn: view)
				if !viewChangedOwnership {
					self.handleControl(view, controlEvent: .touchDown)
					
					if touch.tapCount > 1 {
						// two events, I think this is the correct behavior but I have not tested with an actual UIControl
						self.handleControl(view, controlEvent: .touchDownRepeat)
					}
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let position = touch.location(in: self)
				
				let oldView = self.touchToView[touch]
				let newView = findNearestView(position)
				
				if oldView != newView
				{
					self.handleControl(oldView, controlEvent: .touchDragExit)
					
					let viewChangedOwnership = self.ownView(touch, viewToOwn: newView)
					
					if !viewChangedOwnership
					{
						self.handleControl(newView, controlEvent: .touchDragEnter)
					}
					else
					{
						self.handleControl(newView, controlEvent: .touchDragInside)
					}
				}
				else
				{
					self.handleControl(oldView, controlEvent: .touchDragInside)
				}
				
			}
			
		}
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let view = self.touchToView[touch]
				
				let touchPosition = touch.location(in: self)
				
				if self.bounds.contains(touchPosition)
				{
					self.handleControl(view, controlEvent: .touchUpInside)
				}
				else
				{
					self.handleControl(view, controlEvent: .touchCancel)
				}
				
				self.touchToView[touch] = nil
			}
			
		}
		
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent!)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let view = self.touchToView[touch]
				
				self.handleControl(view, controlEvent: .touchCancel)
				
				self.touchToView[touch] = nil
			}
		}
		
	}
	
	// TODO: there's a bit of "stickiness" to Apple's implementation
	func findNearestView(_ position: CGPoint) -> UIView? {
		if !self.bounds.contains(position) {
			return nil
		}
		
		var closest: (UIView, CGFloat)? = nil
		
		for anyView in self.subviews {
			let view = anyView
			
			if view.isHidden {
				continue
			}
			
			view.alpha = 1
			
			let distance = distanceBetween(view.frame, point: position)
			
			if closest != nil {
				if distance < closest!.1 {
					closest = (view, distance)
				}
			}
			else {
				closest = (view, distance)
			}
		}
		
		if closest != nil {
			return closest!.0
		}
		else {
			return nil
		}
	}
	
	func distanceBetween(_ rect: CGRect, point: CGPoint) -> CGFloat {
		if rect.contains(point) {
			return 0
		}
		
		var closest = rect.origin
		
		if (rect.origin.x + rect.size.width < point.x) {
			closest.x += rect.size.width
		}
		else if (point.x > rect.origin.x) {
			closest.x = point.x
		}
		if (rect.origin.y + rect.size.height < point.y) {
			closest.y += rect.size.height
		}
		else if (point.y > rect.origin.y) {
			closest.y = point.y
		}
		
		let a = pow(Double(closest.y - point.y), 2)
		let b = pow(Double(closest.x - point.x), 2)
		return CGFloat(sqrt(a + b));
	}
	
	func ownView(_ newTouch: UITouch, viewToOwn: UIView?) -> Bool {
		var foundView = false
		
		if viewToOwn != nil {
			for (touch, view) in self.touchToView {
				if viewToOwn == view {
					if touch == newTouch {
						break
					}
					else {
						self.touchToView[touch] = nil
						foundView = true
					}
					break
				}
			}
		}
		
		self.touchToView[newTouch] = viewToOwn
		return foundView
	}
	
	func handleControl(_ view: UIView?, controlEvent: UIControlEvents) {
		if let control = view as? UIControl {
			let targets = control.allTargets
			for target in targets { // TODO: Xcode crashes
				let actions = control.actions(forTarget: target, forControlEvent: controlEvent)
				if (actions != nil) {
					for action in actions! {
						let selector = Selector(action)
						
						control.sendAction(selector, to: target, for: nil)
					}
				}
			}
		}
		
	}

}
