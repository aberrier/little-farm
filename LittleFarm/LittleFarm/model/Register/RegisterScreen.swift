//
//  RegisterScreen.swift
//  LittleFarm
//
//  Created by saad on 29/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation

class RegisterScreen
{
    let registerForm : Bool
    let numberOfLines : Int
    let text : String
    let image : String
    let end : Bool
    
    
    init()
    {
        registerForm = false
        numberOfLines = 1
        text = ""
        image = "default"
        end = false
        
    }
    init(register : Bool,lines : Int,text : String,image : String,end : Bool = false)
    {
        self.registerForm = register
        self.numberOfLines = lines
        self.text = text
        self.image = image
        self.end = end
        
    }
}
