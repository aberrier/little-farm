//
//  File.swift
//  LittleFarm
//
//  Created by saad on 27/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class StoryScreen
{
    let nextButton : Bool
    let nextButtonAction : StoryAction
    let dataList : [StoryDataButton]
    let imageFace : String
    let text : String
    
    
    init()
    {
        nextButton=false
        nextButtonAction = .DoNothing
        dataList = []
        imageFace = "default"
        text = "Undefined"
        
    }
    init(message : String,arrowAction : StoryAction,dataButtons : [StoryDataButton],expression : String)
    {
        text = message
        nextButton = arrowAction == StoryAction.DoNothing ? false : true
        nextButtonAction = arrowAction
        dataList = dataButtons
        imageFace = expression
        
    }
}

