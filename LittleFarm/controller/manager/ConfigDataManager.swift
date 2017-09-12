//
//  ConfigDataManager.swift
//  LittleFarm
//
//  Created by saad on 25/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation

enum cameraInformation
{
    case intrinsicMatrix
    case distorsionMatrix
}

class ConfigDataManager
{
    static let sharedInstance = ConfigDataManager()
    
    var cameraTab : [String : [cameraInformation : [Double]]] = [:]
    var scenario = StoryScenario.instance
    private init()
    {
        extractCameraFeatures()
        extractStory()
    }
    func extractCameraFeatures()
    {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "camera", ofType: "json" )!))
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let cameras = json["camera"] as? [[String: Any]]
            {
                for camera in cameras
                {
                    if let model = camera["model"] as? String , let intrinsic = camera["intrinsic"] as? [Double] , let distorsion = camera["distorsion"] as? [Double]
                    {
                        var cameraData  : [cameraInformation:[Double]] = [:]
                        cameraData[.intrinsicMatrix] = intrinsic
                        cameraData[.distorsionMatrix] = distorsion
                        cameraTab[model] = cameraData
                    }
                }
            }
        } catch {
            print("Error deserializing camera JSON: \(error)")
        }
    }
    func extractStory()
    {
        //Empty map
        scenario.data = [:]
        //Serialize json
        do
        {
            //Get url
            let data = try Data(contentsOf : URL(fileURLWithPath: Bundle.main.path(forResource: "story", ofType: "json")!))
            //Get the json file
            if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any],
                let story = json["story"] as? [[String : Any]]
            {
                //Get specific screen
                for screen in story
                {
                    //Get basic informations
                    if let text = screen["text"] as? String , let id = screen["id"] as? String,
                        let arrowAction = screen["action"] as? [String : String] , let expression = screen["expression"] as? String
                    {
                        //Load buttons
                        var buttons : [StoryDataButton] = []
                        if let buttonsTmp = screen["buttons"] as? [[String : Any]]
                        {
                            for button in buttonsTmp
                            {
                                if let textButton = screen["text"] as? String, let actionButton = screen["action"] as? [String : String]
                                {
                                    var dataButton = StoryDataButton(text: textButton, action: .DoNothing)
                                    if let actionTypeStr  = actionButton["type"]
                                    {
                                        //Load action of button
                                        switch(actionTypeStr)
                                        {
                                        case "callStoryScreen" :
                                            if let screenIdButton = button["screenId"] as? String
                                            {
                                                dataButton = StoryDataButton(text: text, action: .CallStoryScreen(screenIdButton))
                                            }
                                            
                                        case "callController" :
                                            if let controllerId = button["controllerId"] as? String, let controllerTypeStr = button["controllerType"] as? String
                                            {
                                                var controllerType : controllerType = .nothing
                                                switch(controllerTypeStr)
                                                {
                                                case "ARViewController" :
                                                    controllerType = .ARViewController
                                                case "RegisterViewController" :
                                                    controllerType = .RegisterViewController
                                                default :
                                                    print("Extracting story  - Controller type not supported.")
                                                }
                                                dataButton = StoryDataButton(text: textButton, action: .CallController(controllerId, controllerType))
                                            }
                                            
                                            break
                                        case "checkpointStory" :
                                            if let screenId = button["screendId"] as? String
                                            {
                                                dataButton = StoryDataButton(text: textButton, action: .CheckpointStory(screenId))
                                            }
                                            
                                            break
                                        case "endApplication" :
                                            dataButton = StoryDataButton(text: textButton, action: .EndApplication)
                                            break
                                        case "endStory" :
                                            dataButton = StoryDataButton(text: textButton, action: .EndStory)
                                            break
                                        case "doNothing" :
                                            dataButton = StoryDataButton(text: textButton, action: .DoNothing)
                                            break
                                        default :
                                            print("Extracting story - Action type not supported.")
                                            break
                                        }
                                    }
                                    else
                                    {
                                        print("Extracting story - Action type is missing.")
                                    }
                                    
                                    buttons += [dataButton]
                                    
                                }
                            }
                        }
                        //Load arrow action
                        var actionType = StoryAction.DoNothing
                        if let actionTypeStr  = arrowAction["type"]
                        {
                            //Load action of button
                            switch(actionTypeStr)
                            {
                            case "callStoryScreen" :
                                if let screenIdButton = arrowAction["screenId"]
                                {
                                    actionType = .CallStoryScreen(screenIdButton)
                                }
                                
                            case "callController" :
                                if let controllerId = arrowAction["controllerId"], let controllerTypeStr = arrowAction["controllerType"]
                                {
                                    var controllerType : controllerType = .nothing
                                    switch(controllerTypeStr)
                                    {
                                    case "ARViewController" :
                                        controllerType = .ARViewController
                                    case "RegisterViewController" :
                                        controllerType = .RegisterViewController
                                    default :
                                        print("Extracting story  - Controller type not supported.")
                                    }
                                    actionType = .CallController(controllerId, controllerType)
                                }
                                
                                break
                            case "checkpointStory" :
                                if let screenId = arrowAction["screendId"]
                                {
                                    actionType = .CheckpointStory(screenId)
                                }
                                
                                break
                            case "endApplication" :
                                actionType = .EndApplication
                                break
                            case "endStory" :
                                actionType = .EndStory
                                break
                            case "doNothing" :
                               actionType = .DoNothing
                                break
                            default :
                                print("Extracting story - Action type not supported.")
                                break
                            }
                        }
                        //Merge all the data and create a new screen
                        let newScreen = StoryScreen(message: text, arrowAction: actionType, dataButtons: buttons, expression: expression)
                        scenario.data[id] = newScreen
                    }
                }
            }
        } catch
        {
            print("Error deserializing story JSON: \(error)")
        }
    }
    func getCamera(informations: cameraInformation,ofModel : String) -> [Double]?
    {
        if let cameraData = cameraTab[ofModel]
        {
            if let matrix = cameraData[informations]
            {
                return matrix
            }
        }
        return nil
        
    }
    
    
}


