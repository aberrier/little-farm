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
    @IBOutlet var textLabel : UILabel!
    @IBOutlet var connexionButton : UIButton!
    @IBOutlet var registerButton : UIButton!
    @IBOutlet var startButton : UIButton!
    
    
    var isConnected : Bool = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationView : UIViewController = segue.destination
        if destinationView is QRCodeViewController
        {
            
        }
        if destinationView is ARViewController
        {
            
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        textLabel.numberOfLines = 4
        if let isConnected = dataManager.generalInfos?.value(forKey: "isConnected") as? Bool
        {
            if isConnected
            {
                self.isConnected = true
                if let currentUser = dataManager.getCurrentUser()
                {
                    let surname = currentUser.value(forKey: "surname") as? String
                    textLabel.text = "Content de te revoir, \(surname!) !"
                    connexionButton.isHidden = true
                    registerButton.isHidden = true
                    startButton.isHidden = false
                }
                else
                {
                    print("Can't get the current user.")
                }
            }
            else
            {
                self.isConnected = false
                textLabel.text = "Bienvenue dans le monde de LittleFarm !"
                connexionButton.isHidden = false
                registerButton.isHidden = false
                startButton.isHidden = true
            }
        }
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func QRCodeQuery( UIBut : UIButton)
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        
        let QRCodeView = storyboard.instantiateViewController(withIdentifier: "QRCodeView") as! QRCodeViewController
        QRCodeView.nextController = .RegisterViewController
        
        self.present(QRCodeView, animated: true, completion: nil)
    }
}

