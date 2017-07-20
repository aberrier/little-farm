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

class LandingController : UIViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationView : UIViewController = segue.destination
        if destinationView is QRCodeViewController
        {
            return
        }
        if destinationView is ARViewController
        {
            let ARView : ARViewController = destinationView as! ARViewController
            switch(segue.identifier!)
            {
            case "shipView": ARView.scene = SCNScene(named: "art.scnassets/ship.scn")!
            case "cyborgView": ARView.scene = SCNScene(named: "art.scnassets/Cyborg.scn")!
            case "pringlesView" : ARView.scene = SCNScene(named: "art.scnassets/Pringles.scn")!
            default : break
            }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

