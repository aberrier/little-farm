//
//  File.swift
//  LittleFarm
//
//  Created by saad on 27/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation


enum StoryAction
{
    case CallStoryScreen(String)
    case CallController(String,controllerType)
    case CheckpointStory(String)
    case EndApplication
    case EndStory
    case DoNothing
}

extension StoryAction : Equatable
{
    static func ==(lhs : StoryAction, rhs : StoryAction) -> Bool
    {
        switch(lhs, rhs)
        {
            
        case (let .CallStoryScreen(code1), let .CallStoryScreen(code2)):
            return code1 == code2
        case ( let .CallController(code1, type1), let .CallController(code2, type2)):
            return code1 == code2 && type1==type2
        case (let .CheckpointStory(code1), let .CheckpointStory(code2)):
            return code1 == code2
        case (.EndApplication, .EndApplication):
            return true
        case (.EndStory, .EndStory):
            return true
        case (.DoNothing, .DoNothing):
            return true
        default :
            return false
        }
    }
}
