//
//  AxisCoordinate.swift
//  LittleFarm
//
//  Created by saad on 23/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class AxisCoordinate: SCNNode {
    let radius : CGFloat = 0.015
    let height : CGFloat = 0.7
    let heightPyramid : CGFloat = 0.1
    var sizePyramid : CGFloat
    override init() {
        
        sizePyramid = radius*3
        super.init()
        //x axis
        self.addChildNode(createArrow(xPos: height/2, yPos: 0, zPos: 0, xRot: 0, yRot: 0, zRot: 1, color: UIColor.red))
        //y axis
        self.addChildNode(createArrow(xPos: 0, yPos: height/2, zPos: 0, xRot: 0, yRot: 0, zRot: 0, color: UIColor.green))
        //z axis
        self.addChildNode(createArrow(xPos: 0, yPos: 0, zPos: height/2, xRot: 1, yRot: 0, zRot: 0, color: UIColor.yellow))
    }
    func createArrow(xPos : CGFloat, yPos : CGFloat, zPos : CGFloat , xRot : CGFloat , yRot : CGFloat , zRot : CGFloat , color : UIColor) -> SCNNode
    {
        let Cylinder = SCNCylinder(radius: radius, height: height)
        Cylinder.firstMaterial?.diffuse.contents = color
        let NodeCylinder = SCNNode(geometry: Cylinder)
        NodeCylinder.rotation = SCNVector4(xRot,yRot,zRot,CGFloat(Double.pi/2))
        NodeCylinder.position = SCNVector3(xPos,yPos,zPos)
        
        let Pyramid = SCNPyramid(width: sizePyramid, height: heightPyramid , length: sizePyramid)
        Pyramid.firstMaterial?.diffuse.contents = color
        let NodePyramid = SCNNode(geometry: Pyramid)
        NodePyramid.rotation = SCNVector4(xRot,yRot,zRot,CGFloat(-Double.pi/2))
        NodePyramid.position = SCNVector3(xPos*2,yPos*2,zPos*2)
        let str : String = xPos != 0 ? "x" : (yPos != 0 ? "y" : (zPos != 0 ? "z" : "0"))
        let Text = SCNText(string: str, extrusionDepth: 5)
        Text.firstMaterial?.diffuse.contents = UIColor.black
        let NodeText = SCNNode(geometry : Text)
        //NodeText.rotation = SCNVector4(xRot,yRot,zRot,CGFloat((zRot != 0 ? -1 : 1)*Double.pi/2))
        NodeText.position = SCNVector3(xPos*2,yPos*2,zPos*2)
        NodeText.scale = SCNVector3(0.01,0.01,0.01)
        let Node = SCNNode()
        Node.addChildNode(NodeCylinder)
        Node.addChildNode(NodePyramid)
        Node.addChildNode(NodeText)
        return Node
    }
    required init?(coder aDecoder: NSCoder) {
        sizePyramid = radius*2
        super.init(coder: aDecoder)
    }
}
