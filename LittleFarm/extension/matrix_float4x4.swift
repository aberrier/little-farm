//
//  matrix_float4x4.swift
//  LittleFarm
//
//  Created by Alain on 15/09/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import Foundation
public extension matrix_float4x4 {
    
    func toRedBox() -> redBox
    {
        let box = redBox()!
        box.setX(self.columns.3.x)
        box.setY(self.columns.3.y)
        box.setZ(self.columns.3.z)
        box.setConfidence(100)
        return box
    }
}
