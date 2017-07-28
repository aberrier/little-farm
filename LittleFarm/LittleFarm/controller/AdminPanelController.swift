//
//  AdminPanelController.swift
//  LittleFarm
//
//  Created by saad on 26/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class AdminPanelController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var userTableView : UITableView!
    
    var dataManager = PersistentDataManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //tableView
    @objc func refresh(_ refreshControl : UIRefreshControl)
    {
        refreshControl.endRefreshing()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.users.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newCell = userTableView.dequeueReusableCell(withIdentifier: "userCell") as! userForAdminPanelCell
        if let name = dataManager.users[indexPath.row].value(forKey: "name") as? String, let surname = dataManager.users[indexPath.row].value(forKey: "surname") as? String, let user = dataManager.getUser(indexInTab : indexPath.row)
        {
            newCell.user = user
            newCell.userButton.setTitle(surname + " " + name, for: .normal)
        }
        return newCell
        
    }
    

    
    //Display popup
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteUser(sender : UIButton)
    {
        let currentCell = sender.superview?.superview as! userForAdminPanelCell
        
        dataManager.deleteUser(userId: currentCell.user.id)
        userTableView.reloadData()
        alert("", message: "User deleted")
    }
    @IBAction func seeUser(sender : UIButton)
    {
        let currentCell = sender.superview?.superview as! userForAdminPanelCell
        userTableView.reloadData()
        alert(currentCell.user.surname + " " + currentCell.user.name, message: "\(currentCell.user)")
    }
    @IBAction func deleteAllUsers(sender : UIButton)
    {
        dataManager.deleteAllUsers()
        alert("", message: "All users deleted")
    }
    

}
