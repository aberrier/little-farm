//
//  LandingController.swift
//  LittleFarm
//
//  Created by saad on 11/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreSpotlight
import CoreData


class LandingController : UIViewController
{
    
    let dataManager = PersistentDataManager.sharedInstance
    @IBOutlet var titleText : UILabel!
    @IBOutlet var connexionButton : UIButton!
    @IBOutlet var registerButton : UIButton!
    @IBOutlet var startButton : UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //Title setup
        titleText.numberOfLines = 4
        
        
        //Setup view with user informations
        if let isConnected = dataManager.generalInfos?.value(forKey: "isConnected") as? Bool
        {
            var surname = ""
            if isConnected
            {
                if let currentUser = dataManager.getCurrentUser()
                {
                    surname = currentUser.surname
                }
                else
                {
                    print("Landing : Can't get the current user.")
                }
            }
            titleText.text = isConnected ? "Content de te revoir, \(surname) !" : "Bienvenue dans le monde de LittleFarm !"
            connexionButton.isHidden = isConnected
            registerButton.isHidden = isConnected
            startButton.isHidden = !isConnected
        }
        else
        {
            print("Landing : Can't read general informations on database")
        }

        
        
    }
    
    @IBAction func callQRCodeController(sender : UIButton)
    {
        //Call QRCodeController with its mission
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        let nextController : controllerType  = sender==startButton ? .ARViewController : (sender==registerButton ? .RegisterViewController : .nothing)
        let QRCodeView = storyboard.instantiateViewController(withIdentifier: "QRCodeView") as! QRCodeViewController
        QRCodeView.nextController = nextController
        self.present(QRCodeView, animated: true, completion: nil)
    }
    
}


