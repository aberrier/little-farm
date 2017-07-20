//
//  test3DObject.swift
//  LittleFarm
//
//  Created by saad on 12/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import ARKit
class testObject : SCNNode {
    func loadModal() {
        guard let virtualOjectScene = SCNScene(named: "art.scnassets/tree.scn") else {return}
        
        let wrapperNode = SCNNode()
        
        for child in virtualOjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        
        self.addChildNode(wrapperNode)
        
    }
}
