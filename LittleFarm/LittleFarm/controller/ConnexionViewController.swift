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
    @IBOutlet var validateButton: actionButton!
    @IBOutlet var infoLabel: UILabel!
    
    let dataManager = PersistentDataManager.sharedInstance
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    @IBAction func validate(sender : UIButton)
    {
        if !dataManager.connectUser(email: idField.text!, password: passwordField.text!)
        {
            infoLabel.text = "Impossible de se connecter !"
        }
        else
        {
            QRCodeQuery()
        }
    }
    func QRCodeQuery()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        
        let QRCodeView = storyboard.instantiateViewController(withIdentifier: "QRCodeView") as! QRCodeViewController
        QRCodeView.nextController = .ARViewController
        
        self.present(QRCodeView, animated: true, completion: nil)
    }
}
