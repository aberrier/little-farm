//
//  PersistentDataManager.swift
//  LittleFarm
//
//  Created by saad on 23/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import CoreData
import UIKit

class PersistentDataManager
{
    static let sharedInstance = PersistentDataManager()
    
    var users: [NSManagedObject] = []
    var generalInfosList : [NSManagedObject] = []
    var validProductKeys : [NSManagedObject] = []
    
    var generalInfos: NSManagedObject?
    var currentUser : NSManagedObject?
    
    var currentUserInstancied : Bool = false
    var dataIsInstancied : Bool = false
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "main")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init()
    {
        updateData()
        if !dataIsInstancied
        {
            setupFirstPersistentData()
        }
        addInitialKeys()
        //addUser(name: "Alain", surname: "Berrier", id: "id01", password: "wesh", image: "ruby", productId: "n1", gender: 0, email: "alain@berrier.fr", birthDate: Date(timeIntervalSince1970: 234500))
        //setConnectedUser(userId: "id01")
    }
    
    //*** Main setup functions ***
    func updateData()
    {
        setupUsers()
        setupGeneralInformations()
        setupValidProductKeys()
        calibrateConnectionInformations()
        saveContext()
    }
    
    private func setupFirstPersistentData()
    {
        
        let managerContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "MainInformations",
                                                in: managerContext)!
        
        let infos = NSManagedObject(entity: entity,
                                    insertInto: managerContext)
        
        infos.setValue(true, forKeyPath: "isInstancied")
        infos.setValue(false, forKeyPath: "isConnected")
        infos.setValue("", forKeyPath: "userConnectedId")
        
        do {
            try managerContext.save()
            generalInfosList.append(infos)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    private func setupGeneralInformations()
    {
        let managerContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MainInformations")
        do {
            generalInfosList = try managerContext.fetch(fetchRequest)
            if generalInfosList.count != 0
            {
                generalInfos = generalInfosList[0]
                dataIsInstancied = generalInfos?.value(forKey: "isInstancied") as! Bool
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func setupUsers()
    {
        let managerContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            users = try managerContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func setupValidProductKeys()
    {
        let managerContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ValidProductKeys")
        do {
            validProductKeys = try managerContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    private func calibrateConnectionInformations()
    {
        //Check if the user connected still exists
        if let isConnected = generalInfos?.value(forKey: "isConnected") as? Bool
        {
            if isConnected
            {
                let currentId = generalInfos?.value(forKeyPath: "userConnectedId") as? String
                for user in users
                {
                    if currentId == user.value(forKeyPath: "id") as? String
                    {
                        return
                    }
                }
                generalInfos?.setValue(false, forKeyPath: "isConnected")
                generalInfos?.setValue("", forKeyPath: "userConnectedId")
                
            }
        }
    }
    //*** Functions relative to user informations
    func getCurrentUser() -> UserData?
    {
        
        if !currentUserInstancied
        {
            if let isConnected = generalInfos?.value(forKey: "isConnected") as? Bool
            {
                if isConnected
                {
                    let currentId = generalInfos?.value(forKeyPath: "userConnectedId") as? String
                    for user in users
                    {
                        let id = user.value(forKeyPath: "id") as? String
                        if id == currentId
                        {
                            currentUser = user
                            currentUserInstancied = true
                            return getUser(userId: id!)
                        }
                    }
                    print("Can't find user !")
                    return nil
                }
                else
                {
                    print("No user connected")
                    currentUser = nil
                    return nil
                }
            }
            else
            {
                print("Could not acces main informations.")
            }
        }
        else
        {
            return getUser(userId : currentUser?.value(forKeyPath : "id") as! String)
        }
        return nil
    }
    
    func connectUser(email : String, password : String) -> Bool
    {
        for user in users
        {
            if let currentEmail = user.value(forKey: "email") as? String,let currentPassword = user.value(forKey: "password") as? String, let currentId = user.value(forKey: "id") as? String
            {
                if currentEmail == email && currentPassword == password
                {
                    setConnectedUser(userId: currentId)
                    return true
                }
            }
        }
        return false
    }
    
    func setConnectedUser(userId : String)
    {
        generalInfos?.setValue(userId, forKey: "userConnectedId")
        generalInfos?.setValue(true, forKey: "isConnected")
    }
    
    func disconnectUser()
    {
        generalInfos?.setValue("", forKey: "userConnectedId")
        generalInfos?.setValue(false, forKey: "isConnected")
    }
    func addUser(newUser : UserData)
    {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User",
                                                in: managedContext)!
        let user = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        
        UserDataOnNSObject(NSUser: user, user: newUser)
        do {
            try managedContext.save()
            users.append(user)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func changeUser(user : UserData) -> Bool
    {
        for currentUser in users
        {
            if  user.id == currentUser.value(forKey: "id") as? String
            {
                UserDataOnNSObject(NSUser: currentUser, user: user)
                return true
            }
        }
        return false
    }
    
    func deleteUser(userId : String)
    {
        
        let managerContext = persistentContainer.viewContext
        for user in users
        {
            let id = user.value(forKeyPath: "id") as? String
            if id == userId
            {
                managerContext.delete(user)
            }
        }
        updateData()
    }
    
    func deleteAllUsers()
    {
        let managerContext = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managerContext.execute(deleteRequest)
            try managerContext.save()
            
        } catch {
            print("Error while trying to delete all users.")
        }
        updateData()
    }
    
    
    
    func getUser(userId : String) ->UserData?
    {
        for user in users
        {
            let id = user.value(forKeyPath: "id") as? String
            if userId == id
            {
                return NSObjectOnUserData(NSUser: user)
            }
        }
        print("Can't find user : \(userId)!")
        return nil
    }
    func getUser(indexInTab : Int) ->UserData?
    {
        if(indexInTab < users.count)
        {
            return NSObjectOnUserData(NSUser: users[indexInTab])
            
        }
        print("Index too big !")
        return nil
    }
    private func UserDataOnNSObject(NSUser : NSManagedObject, user : UserData)
    {
        NSUser.setValue(user.name, forKeyPath: "name")
        NSUser.setValue(user.surname, forKeyPath: "surname")
        NSUser.setValue(user.id, forKeyPath: "id")
        NSUser.setValue(user.password, forKeyPath: "password")
        NSUser.setValue(user.image, forKeyPath: "image")
        NSUser.setValue(user.productId, forKeyPath: "productId")
        NSUser.setValue(user.gender, forKeyPath: "gender")
        NSUser.setValue(user.email, forKeyPath: "email")
        NSUser.setValue(user.birthDate, forKeyPath: "birthDate")
        NSUser.setValue(user.onStoryMode, forKeyPath: "onStoryMode")
        NSUser.setValue(user.storyId, forKeyPath: "storyId")
    }
    private func NSObjectOnUserData(NSUser : NSManagedObject) -> UserData
    {
        let newUser = UserData()
        newUser.name = NSUser.value(forKey: "name") as! String
        newUser.surname = NSUser.value(forKey: "surname") as! String
        newUser.id = NSUser.value(forKey: "id") as! String
        newUser.password = NSUser.value(forKey: "password") as! String
        newUser.image = NSUser.value(forKey: "image") as! String
        newUser.productId = NSUser.value(forKey: "productId") as! String
        newUser.gender = NSUser.value(forKey: "gender") as! Int16
        newUser.email = NSUser.value(forKey: "email") as! String
        newUser.birthDate = NSUser.value(forKey: "birthDate") as! Date
        newUser.onStoryMode = NSUser.value(forKey: "onStoryMode") as! Bool
        newUser.storyId = NSUser.value(forKey: "storyId") as! String
        return newUser
    }
    //***Functions relative to product keys***
    
    private func addInitialKeys()
    {
        addProductKey(key: "toto")
        addProductKey(key: "foret")
        addProductKey(key: "rose")
    }
    
    private func addProductKey(key : String)
    {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ValidProductKeys",
                                                in: managedContext)!
        let productId = NSManagedObject(entity: entity,
                                        insertInto: managedContext)
        productId.setValue(key, forKeyPath: "value")
        do {
            try managedContext.save()
            validProductKeys.append(productId)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func isProductKeyValid(key : String) -> Bool
    {
        for currentKey in validProductKeys
        {
            let currentKeyValue = currentKey.value(forKeyPath: "value") as? String
            if key == currentKeyValue
            {
                return true
            }
        }
        return false
    }
    
    //*** Others functions ***
    func getNewId() -> String
    {
        return "id\(users.count)"
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


