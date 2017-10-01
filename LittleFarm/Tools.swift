//
//  Tools.swift
//  LittleFarm
//
//  Created by saad on 28/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
import UIKit

public extension UIDevice {
    ///Get the name of the current device.
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
/**
 General tools that can be use for several actions such as :
 - Give a random position
 - Create an alert window
 - Normalize a UIImage object
 */
struct GT {
    /**
     Give an random position between the **lower** bound and the **upper** bound
     */
    static func randomPosition (lowerBound lower:Float, upperBound upper:Float) -> Float {
        return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
    }
    /**
     Display and "OK" alert popup.
     
     - Parameters:
         - title: The title of the popup
         - message: The message displayed on the popup
         - sender: The viewcontroller where the popup alert is displayed
     */
    static func alert(_ title: String, message: String,sender : UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        sender.present(alert, animated: true, completion: nil)
    }
    /**
     Used to create a shake animation.
     ## Example of use : ##
     ````
     let view = UIView()
     view.layer.add(GT.giveShakeAnimation(), forKey: nil)
     ````
     - Returns: A *CAKeyframeAnimation* object that can be add to a layer.
     */
    static func giveShakeAnimation() -> CAKeyframeAnimation
    {
        let anim = CAKeyframeAnimation(keyPath : "transform")
        anim.values = [
            NSValue(caTransform3D:CATransform3DMakeTranslation(-5, 0, 0)),
            NSValue(caTransform3D:CATransform3DMakeTranslation(5, 0, 0))
        ]
        anim.autoreverses = true
        anim.repeatCount = 2
        anim.duration = 7/100
        return anim
    }
    /**
     Convert an *NSMutableArray* object to a simple array.
     - Parameter array: *NSMutableArray* object.
     - Returns: An array of *Any* object
     - Remark: The information about the type of the object inside of the initial array is lost.
     */
    static func convertObjectiveCArray(_ array : NSMutableArray) -> [Any]
    {
        var newArray : [Any] = []
        for object in array
        {
            newArray += [object]
        }
        return newArray
    }

    /**
     Concatenate the file named by **name** on a *String* object.
     - Parameter name: The name of the file with its extension
     - Returns: *nil* if the file can't be found.
     */
    static func getFileOnString(name : String) -> String?
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(name)
            //reading
            do {
                let text = try String(contentsOf: path, encoding: String.Encoding.utf8)
                print("[R] File generated at :\(path.absoluteString)")
                return text
            }
            catch {
                print("[R] No file for this name at : \(path.absoluteString)")
                return nil
            }
        }
        
        print("[R] Can't open directory.")
        return nil
        
        
    }
    /**
     Give the file named by **name** on a *Data* object.
     - Parameter name: The name of the file with its extension
     - Returns: *nil* if the file can't be found.
     */
    static func getFileOnData(name : String) -> Data?
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(name)
            //reading
            do {
                let data = try Data(contentsOf: path)
                print("[R] File generated at :\(path.absoluteString)")
                return data
            }
            catch {
                print("[R] No file for this name at : \(path.absoluteString)")
                return nil
            }
        }
        
        print("[R] Can't open directory.")
        return nil
        
        
    }
    /**
     Give the file with a full access path of **fullPath** on a *Data* object.
     - Parameter fullPath: The full access path of the file.
     - Returns: *nil* if the file can't be found.
     */
    static func getFileOnData(fullPath : String) -> Data?
    {
        let url = URL(fileURLWithPath: fullPath)
        do {
                let data = try Data(contentsOf: url)
                print("[R] File generated at :\(fullPath)")
                return data
            }
            catch {
                print("[R] No file for this name at : \(fullPath)")
                return nil
            }
    }
    /**
     Give the file path of of the file named by **name**.
     - Parameter name: The name of the file with its extension
     - Returns: *nil* if the file can't be found.
     */
    static func getFilePath(name : String) -> String?
    {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //On récupère le premier dossier, donc Documents
        let docsDir = dirPaths[0]
        if let path = NSURL(string: docsDir)!.appendingPathComponent(name)
        {
            if let data = NSData(contentsOf: path)
            {
                print("\(data.description)")
            }
            else
            {
                print("[W] Path for writing generated :\(path.absoluteString)")
            }
            return path.absoluteString
            
        }
        else
        {
            print("[W] Can't open path.")
        }
        return nil
    }
    /**
     Normalize a *UIImage* context.
     - Parameter image: *UIImage* input object.
     - Returns: *UIImage* normalized output object.
     */
    static func normalizedImage(image : UIImage) -> UIImage
    {
        if(image.imageOrientation == .up)
        {
             return image
        }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    

}
