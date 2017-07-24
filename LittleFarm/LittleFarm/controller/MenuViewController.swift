//
//  MenuViewController.swift
//  LittleFarm
//
//  Created by saad on 20/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

struct menuSections {
    static var wip = 0
    static var exploration = 1
    static var rubis = 2
    static var trees = 3
    static var badges = 4
}
class MenuViewController : UIViewController
{
    
    let dataManager = PersistentDataManager.sharedInstance
    
    @IBOutlet var menuSectionView : UIView!
    
    @IBOutlet var wipSection : menuSection!
    @IBOutlet var explorationSection: menuSection!
    @IBOutlet var rubySection : menuSection!
    @IBOutlet var treeSection : menuSection!
    @IBOutlet var badgeSection : menuSection!
    @IBOutlet var disconnectButton : UIButton!
    func numberOfSections(in tableView: UITableView) -> Int {
        return generalInformations.numberOfSections
    }
    
    override func viewDidLoad() {
        //Border style
        menuSectionView.layer.borderWidth = 5
        menuSectionView.layer.borderColor = UIColorSet.darkBlue.cgColor
        menuSectionView.layer.cornerRadius = 4
        
        wipSection.loadSection(imagePath: "heart", text: "Mon WIP")
        explorationSection.loadSection(imagePath: "wand", text: "Exploration")
        badgeSection.loadSection(imagePath: "badge", text: "Mes badges")
        rubySection.loadSection(imagePath: "ruby", text: "Mes rubis")
        treeSection.loadSection(imagePath: "leaves", text: "Mes arbres")
    }
    @IBAction func disconnectUser(sender : UIButton)
    {
        
        dataManager.disconnectUser()
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        let landingView = storyboard.instantiateViewController(withIdentifier: "landing") as! LandingController
        
        self.present(landingView, animated: true, completion: nil)
    }
  
}
