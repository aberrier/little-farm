//
//  storyButton.swift
//  LittleFarm
//
//  Created by saad on 20/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class actionButton : UIButton
{
    var controllerToCall : String = ""
    var text : String = "Undefined"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        
        layer.cornerRadius = 30
        layer.backgroundColor = UIColorSet.darkBlue.cgColor
        setTitleColor(UIColorSet.ligthOrange, for: .normal)
        setTitleColor(UIColorSet.darkOrange, for: .selected)
        titleLabel?.font = UIFont(name : "Century Gothic", size : 25)
        titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    
}
