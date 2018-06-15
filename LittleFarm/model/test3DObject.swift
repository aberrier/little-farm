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
        guard let virtualObjectScene = SCNScene(named: "art.scnassets/happy.scn") else {return}
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        
        self.addChildNode(wrapperNode)
        
    }
}
