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
                print("STP : \(generalInfos?.value(forKeyPath: "isConnected") as! Bool)")
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
            print("awai")
            return getUser(userId : currentUser?.value(forKeyPath : "id") as! String)
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
        user.setValue(newUser.onStoryMode, forKeyPath: "onStoryMode")
        user.setValue(newUser.storyId, forKeyPath: "storyId")
        
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
                currentUser.setValue(user.name, forKeyPath: "name")
                currentUser.setValue(user.surname, forKeyPath: "surname")
                currentUser.setValue(user.id, forKeyPath: "id")
                currentUser.setValue(user.password, forKeyPath: "password")
                currentUser.setValue(user.image, forKeyPath: "image")
                currentUser.setValue(user.productId, forKeyPath: "productId")
                currentUser.setValue(user.gender, forKeyPath: "gender")
                currentUser.setValue(user.email, forKeyPath: "email")
                currentUser.setValue(user.birthDate, forKeyPath: "birthDate")
                currentUser.setValue(user.onStoryMode, forKeyPath: "onStoryMode")
                currentUser.setValue(user.storyId, forKeyPath: "storyId")
                return true
            }
        }
        return false
    }
    
    func deleteUser(userId : String)
    {
        
        for user in users
        {
            let id = user.value(forKeyPath: "id") as? String
            if id == userId
            {
                persistentContainer.viewContext.delete(user)
            }
        }
        updateData()
        
        
    }
    
    func deleteAllUsers()
    {
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
            
        } catch {
            print("Error while trying to delete all users.")
        }
        updateData()
    }
    
    func updateData()
    {
        initUsers()
        initGeneralInfos()
        initValidProductKeys()
        checkValidConnection()
    }
    
    func checkValidConnection()
    {
        //Check if the user connected still exists
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
                        return
                    }
                }
                generalInfos?.setValue(false, forKeyPath: "isConnected")
                generalInfos?.setValue("", forKeyPath: "userConnectedId")
                
            }
        }
    }
    func getUser(userId : String) ->UserData?
    {
        let newUser = UserData()
        for user in users
        {
            let id = user.value(forKeyPath: "id") as? String
            if userId == id
            {
                
                newUser.name = user.value(forKey: "name") as! String
                newUser.surname = user.value(forKey: "surname") as! String
                newUser.id = user.value(forKey: "id") as! String
                newUser.password = user.value(forKey: "password") as! String
                newUser.image = user.value(forKey: "image") as! String
                newUser.productId = user.value(forKey: "productId") as! String
                newUser.gender = user.value(forKey: "gender") as! Int16
                newUser.email = user.value(forKey: "email") as! String
                newUser.birthDate = user.value(forKey: "birthDate") as! Date
                newUser.onStoryMode = user.value(forKey: "onStoryMode") as! Bool
                newUser.storyId = user.value(forKeyPath: "storyId") as! String
                return newUser
            }
        }
        print("Can't find user : \(userId)!")
        return nil
    }
    func getUser(indexInTab : Int) ->UserData?
    {
        let newUser = UserData()
        if(indexInTab < users.count)
        {
            let user = users[indexInTab]
            newUser.name = user.value(forKey: "name") as! String
            newUser.surname = user.value(forKey: "surname") as! String
            newUser.id = user.value(forKey: "id") as! String
            newUser.password = user.value(forKey: "password") as! String
            newUser.image = user.value(forKey: "image") as! String
            newUser.productId = user.value(forKey: "productId") as! String
            newUser.gender = user.value(forKey: "gender") as! Int16
            newUser.email = user.value(forKey: "email") as! String
            newUser.birthDate = user.value(forKey: "birthDate") as! Date
            return newUser
            
        }
        print("Index too big !")
        return nil
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

