//
//  User.swift
//  LittleFarm
//
//  Created by saad on 25/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation

class UserData
{
    var name : String = "UNDEFINED"
    var surname : String = "Undefined"
    var birthDate : Date = Date(timeIntervalSince1970: 0)
    var email : String = "no@email.com"
    var gender : Int16 = 0
    var image : String = "default"
    var id : String = "id??"
    var password : String = "1234"
    var productId : String = "????"
    
    var onStoryMode = false
    var storyId = ""
    
}
