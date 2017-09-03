//
//  ConnexionViewController.swift
//  LittleFarm
//
//  Created by saad on 24/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
class ConnexionViewController : UIViewController
{
    @IBOutlet var idField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var validateButton: LFButton!
    @IBOutlet var infoLabel: UILabel!
    
    let dataManager = PersistentDataManager.sharedInstance
    
    @IBAction func validate(sender : UIButton)
    {
        if !dataManager.connectUser(email: idField.text!, password: passwordField.text!)
        {
            infoLabel.text = "Impossible de se connecter !"
            view.layer.add(GT.giveShakeAnimation(), forKey: nil)
        }
        else
        {
           callARCodeController()
        }
    }
    func callARCodeController()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        let ARView = storyboard.instantiateViewController(withIdentifier: "ARView") as! ARViewController
        ARView.qrCodeMode = false
        self.present(ARView, animated: true, completion: nil)
    }
    func callQRCodeController()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        
        let QRCodeView = storyboard.instantiateViewController(withIdentifier: "QRCodeView") as! QRCodeViewController
        QRCodeView.nextController = .ARViewController
        
        self.present(QRCodeView, animated: true, completion: nil)
    }
}
