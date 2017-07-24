//
//  RegisterViewController.swift
//  LittleFarm
//
//  Created by saad on 20/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class RegisterViewController : UIViewController
{
    var productId : String = "toto"
    @IBOutlet var textLabel : UILabel!
    @IBOutlet var image : UIImageView!
    @IBOutlet var nextButton : UIButton!
    var sequence : Int = 0
    override func viewDidLoad() {
        textLabel.layer.cornerRadius = 30
        textLabel.layer.borderColor = UIColorSet.ligthOrange.cgColor
        textLabel.textColor = UIColorSet.darkBlue
        textLabel.font = UIFont(name : "Century Gothic", size : 25)
        updateSequence()
    }
    func updateSequence()
    {
        switch(sequence)
        {
        case 0 :
            textLabel.text = "Tiens tiens...\nOn dirait qu'il y a quelqu'un là dedans"
            image.image = UIImage(named: "egg-2")
        case 1 :
            textLabel.text = "Bravo !\nVous venez d'adopter un petit wip !"
            image.image = UIImage(named:  "egg-3")
        case 2 :
            textLabel.text = "Oh!\npetit wip vient de se cacher.."
            image.image = UIImage(named:  "egg-1")
        case 3 :
            textLabel.text = "Nous vous inquiétez pas, les wips sont connus pour être craintifs face aux inconnus.."
            image.image = UIImage(named:  "egg-1")
        case 4 :
            textLabel.text = "Il faut d'abord le rassurer.\nCommencez par vous présenter."
            image.image = UIImage(named:  "egg-1")
            //add button
        case 5 :
            //special sequence : register form
            print("5")
        case 6 :
            textLabel.text = "Ah ! le voilà qu'il sort de sa cachette.\nPromettez-vous à petit wip de prendre soin de lui ?"
            image.image = UIImage(named:  "egg-3")
        default : break
        }
    }
    @IBAction func moveToNextSequence(sender : UIButton)
    {
        switch(sequence)
        {
        case 0,1,2,3:
            sequence+=1
            updateSequence()
        case 4:
            //if sender ==
            sequence+=1
        default: break
        }
    }
}
