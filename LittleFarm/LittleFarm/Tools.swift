//
//  Tools.swift
//  LittleFarm
//
//  Created by saad on 28/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation
struct GT {
    static func randomPosition (lowerBound lower:Float, upperBound upper:Float) -> Float {
        return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
    }
}
