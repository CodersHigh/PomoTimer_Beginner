//
//  RoundButton.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 14..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 2
        self.layer.borderColor = self.tintColor?.CGColor
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    }

    override var highlighted : Bool {
        didSet {
            if highlighted {
                self.backgroundColor = self.tintColor
                self.layer.borderColor = self.titleColorForState(.Highlighted)?.CGColor
                
            } else {
                self.backgroundColor = UIColor.clearColor()
                self.layer.borderColor = self.tintColor?.CGColor
            }
        }
    }
    
}


class CircleButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.size.width/2
        self.layer.borderWidth = 2
        self.layer.borderColor = self.tintColor?.CGColor
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    override var highlighted : Bool {
        didSet {
            if highlighted {
                self.backgroundColor = self.tintColor
                self.layer.borderColor = self.titleColorForState(.Highlighted)?.CGColor
                
            } else {
                self.backgroundColor = UIColor.clearColor()
                self.layer.borderColor = self.tintColor?.CGColor
            }
        }
    }
    
}
