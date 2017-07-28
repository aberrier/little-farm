//
//  storyButton.swift
//  LittleFarm
//
//  Created by saad on 20/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
class LFButton : UIButton
{
    var text : String = "Undefined"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        setup()
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    func setup()
    {
        layer.cornerRadius = 10
        layer.backgroundColor = UIColorSet.darkBlue.cgColor
        setTitleColor(UIColorSet.ligthOrange, for: .normal)
        setTitleColor(UIColorSet.darkOrange, for: .selected)
        titleLabel?.font = UIFont(name : "Century Gothic", size : 25)
        titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    
}
