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
    var map : [String : StoryScreen]
    //This is where the script is written
    private init()
    {
        map = [:]
        
        //Scenario writing
        let 😀 = StoryScreen(message: "Aaaaaaaaahhh\nJe suis tellement fatigué...\nQui me réveille ? Es tu un humain ?",
                               arrowAction: .DoNothing,
                               dataButtons: [StoryDataButton(text : "Oui je suis un humain", action : .CallStoryScreen("start-02")),
                                             StoryDataButton(text : "Non, je suis un ouistiti", action : StoryAction.CallStoryScreen("start-01a"))],
                               expression:  "default")
        
        map[generalInformations.firstStoryId] = 😀
        let 😇 = StoryScreen(message: "Hihihi ! Génial ! J'adore les humains ! Comment tu t'appelles ?",
                               arrowAction: .EndStory,
                               dataButtons: [],
                               expression:  "default")
        
        map["start-02"] = 😇
        let 🤡 = StoryScreen(message: "Hihihi ! Tu es un petit farceur toi !",
                               arrowAction: .EndStory,
                               dataButtons: [],
                               expression:  "default")
        
        map["start-01a"] = 🤡
        
        
    }
}
