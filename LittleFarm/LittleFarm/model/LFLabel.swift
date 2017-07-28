//
//  niceLabel.swift
//  LittleFarm
//
//  Created by saad on 25/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class LFLabel: UILabel {

    
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
        numberOfLines = 5
        layer.cornerRadius = 10
        layer.borderWidth = 4
        layer.borderColor = UIColorSet.ligthOrange.cgColor
        textColor = UIColorSet.darkBlue
        font = UIFont(name : "Century Gothic", size : 25)
    }
    
}
