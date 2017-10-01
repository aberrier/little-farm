//
//  General.swift
//  LittleFarm
//
//  Created by saad on 22/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
/**
 Contains informations about general stuff
 */
struct generalInformations
{
    ///Number of sections on the menu.
    static var numberOfSections = 5
    ///Number of profil images available when an user register.
    static var numberOfProfilImages = 6
    /**
     Id of the first screen of the story.
     
     **If this id doesn't exist on the story json file, an error can occur.**
     */
    static var firstStoryId = "start-01"
    //Array of the texts displayed for gender selection
    static var registerGenderTab = ["Je suis un garçon !","Je suis une fille !"]
    //Array of profil image names
    static var registerImageTab = ["girl-1","girl-2","boy-1","boy-2","robot","alien"]
    /**
     Name of the default image
     
    **If the default image doesn't exist, and error will occur.**
     */
    static var defaultImage = "default"
    
}
