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
    var currentUserInstancied : Bool = false
    var dataIsInstancied : Bool = false
    var currentUser : NSManagedObject?
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
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
        initGeneralInfos()
        initUsers()
        initValidProductKeys()
        createFirstData()
        //addInitialKeys()
        //addUser(name: "Alain", surname: "Berrier", id: "id01", password: "wesh", image: "ruby", productId: "n1", gender: 0, email: "alain@berrier.fr", birthDate: Date(timeIntervalSince1970: 234500))
        //setConnectedUser(userId: "id01")
    }
    
    func createFirstData()
    {
        
        if !dataIsInstancied
        {
            let entity = NSEntityDescription.entity(forEntityName: "MainInformations",
                                                    in: persistentContainer.viewContext)!
            
            let infos = NSManagedObject(entity: entity,
                                         insertInto: persistentContainer.viewContext)
            
            infos.setValue(true, forKeyPath: "isInstancied")
            infos.setValue(false, forKeyPath: "isConnected")
            infos.setValue("", forKeyPath: "userConnectedId")
            
            do {
                try persistentContainer.viewContext.save()
                generalInfosList.append(infos)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    func initGeneralInfos()
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MainInformations")
        do {
            generalInfosList = try persistentContainer.viewContext.fetch(fetchRequest)
            if generalInfosList.count != 0
            {
                generalInfos = generalInfosList[0]
                dataIsInstancied = true
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func initUsers()
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            users = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func initValidProductKeys()
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ValidProductKeys")
        do {
            validProductKeys = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func getCurrentUser() -> NSManagedObject?
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
                            return currentUser
                        }
                    }
                    print("Can't find user !")
                    return nil
                }
                else
                {
                    print("No user connected")
                    currentUser = nil
                    return currentUser
                }
            }
            else
            {
                print("Could not acces main informations.")
            }
        }
        else
        {
            return currentUser
        }
        return nil
    }
    func connectUser(email : String, password : String) -> Bool
    {
        for user in users
        {
            if let currentEmail = user.value(forKey: "email") as? String
            {
                if let currentPassword = user.value(forKey: "password") as? String
                {
                    if let currentId = user.value(forKey: "id") as? String
                    {
                        if currentEmail == email && currentPassword == password
                        {
                            setConnectedUser(userId: currentId)
                            return true
                        }
                    }
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
    func addInitialKeys()
    {
        addProductKey(key: "toto")
        addProductKey(key: "foret")
        addProductKey(key: "rose")
    }
    func addProductKey(key : String)
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
    func addUser(newUser : UserData)
    {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User",
                                                in: managedContext)!
        let user = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        user.setValue(newUser.name, forKeyPath: "name")
        user.setValue(newUser.surname, forKeyPath: "surname")
        user.setValue(newUser.id, forKeyPath: "id")
        user.setValue(newUser.password, forKeyPath: "password")
        user.setValue(newUser.image, forKeyPath: "image")
        user.setValue(newUser.productId, forKeyPath: "productId")
        user.setValue(newUser.gender, forKeyPath: "gender")
        user.setValue(newUser.email, forKeyPath: "email")
        user.setValue(newUser.birthDate, forKeyPath: "birthDate")
        
        do {
            try managedContext.save()
            users.append(user)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
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
