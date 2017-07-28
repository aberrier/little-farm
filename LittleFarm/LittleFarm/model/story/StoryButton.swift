//
//  StoryButton.swift
//  LittleFarm
//
//  Created by saad on 27/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class StoryButton: LFButton {
    
    var action : StoryAction = .DoNothing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    init()
    {
        super.init(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func load(data : StoryDataButton)
    {
        setTitle(data.text, for: .normal)
        self.action = data.action
    }
    func transformOnClearButton()
    {
        layer.backgroundColor = UIColor.clear.cgColor
        setTitle("", for: .normal)
    }

}
