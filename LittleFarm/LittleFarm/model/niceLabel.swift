//
//  niceLabel.swift
//  LittleFarm
//
//  Created by saad on 25/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class niceLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        
        numberOfLines = 2
        layer.cornerRadius = 10
        layer.borderWidth = 4
        layer.borderColor = UIColorSet.ligthOrange.cgColor
        textColor = UIColorSet.darkBlue
        font = UIFont(name : "Century Gothic", size : 25)
    }
    /*
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        self.setNeedsLayout()
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
 */
    
}
