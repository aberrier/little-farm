//
//  RegisterScenario.swift
//  LittleFarm
//
//  Created by saad on 29/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation

class RegisterScenario
{
    static let instance = RegisterScenario()
    var tab : [RegisterScreen]
    //This is where the script is written
    private init()
    {
        tab = []
        tab += [RegisterScreen(register: false,
                               lines: 2,
                               text: "Tiens tiens...\nOn dirait qu'il y a quelqu'un là dedans",
                               image: "egg-2")] //0
        tab += [RegisterScreen(register: false,
                               lines: 2,
                               text: "Bravo !\nVous venez d'adopter un petit wip !",
                               image: "egg-3")] //1
        tab += [RegisterScreen(register: false,
                               lines: 2,
                               text: "Oh!\npetit wip vient de se cacher..",
                               image: "egg-1")] //2
        tab += [RegisterScreen(register: false,
                               lines: 1,
                               text: "Nous vous inquiétez pas,\n les wips sont connus pour être craintifs face aux inconnus..",
                               image: "egg-1")] //3
        tab += [RegisterScreen(register: false,
                               lines: 2,
                               text: "Il faut d'abord le rassurer.\nCommencez par vous présenter.",
                               image: "egg-1")] //4
        tab += [RegisterScreen(register: true,
                               lines: 0,
                               text: "",
                               image: "default")] //5
        tab += [RegisterScreen(register: false,
                               lines: 2,
                               text: "Ah ! le voilà qu'il sort de sa cachette.\nPromettez-vous à petit wip de prendre soin de lui ?",
                               image: "egg-3")] //6
        tab += [RegisterScreen(register: false,
                               lines: 2,
                               text: "Tiens tiens...\nOn dirait qu'il y a quelqu'un là dedans",
                               image: "egg-2",
                               end : true)] //7
        
    }
}
