//
//  Tools.swift
//  LittleFarm
//
//  Created by saad on 28/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
struct GT {
    static func randomPosition (lowerBound lower:Float, upperBound upper:Float) -> Float {
        return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
    }
    //Display popup
    static func alert(_ title: String, message: String,sender : UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        sender.present(alert, animated: true, completion: nil)
    }
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
    static func convertObjectiveCArray(_ array : NSMutableArray) -> [Any]
    {
        var newArray : [Any] = []
        for object in array
        {
            newArray += [object]
        }
        return newArray
    }
    
}
