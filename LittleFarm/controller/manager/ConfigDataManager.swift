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
    
    private init()
    {
        extractCameraFeatures()
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
            print("Error deserializing JSON: \(error)")
        }
        print("\n\(cameraTab)\n")
    }
    func getCamera(informations: cameraInformation,ofModel : String) -> [Double]?
    {
        if let cameraData = cameraTab[ofModel]
        {
            if let matrix = cameraData[informations]
            {
                print("MATRIX \(matrix)")
                return matrix
            }
        }
        return nil
        
    }
    
    
}


