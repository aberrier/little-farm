//
//  StoryScenario.swift
//  LittleFarm
//
//  Created by saad on 27/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class StoryScenario
{
    static let instance = StoryScenario()
    var data : [String : StoryScreen]
    //This is where the script is written
    private init()
    {
        data = [:]
        
        //Default scenario
        let 😀 = StoryScreen(message: "Aucune histoire n'a été chargé.",
                               arrowAction: .DoNothing,
                               dataButtons: [StoryDataButton(text : "Fermer", action : .EndStory)],
                               expression:  generalInformations.defaultImage)
        data[generalInformations.firstStoryId] = 😀
        
        
    }
}
