//
//  ViewController.swift
//  LittleFarm
//
//  Created by saad on 11/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion
class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var stepperX : UIStepper!
    @IBOutlet var stepperY : UIStepper!
    @IBOutlet var stepperZ : UIStepper!
    
    @IBOutlet var labelX : UILabel!
    @IBOutlet var labelY : UILabel!
    @IBOutlet var labelZ : UILabel!
    
    var qrZone : CGRect = CGRect.zero
    var scene : SCNScene = SCNScene.init()
    var isPositionGiven : Bool = false
    var positionGiven : SCNVector3 = SCNVector3(0,0,0)
    var lastCameraTransform: matrix_float4x4?
    
    
    //Display popup
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the pan gesture recognizer
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touch)))
    
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
    }
    @objc func touch(sender : UITapGestureRecognizer)
    {
        for result in sceneView.hitTest(CGPoint(x: sender.location(in: view).x,y: sender.location(in: view).y), types: [.existingPlaneUsingExtent,.featurePoint])
        {
            alert("\(sender.location(in: view))", message: "\(result.worldTransform.columns.3)")
            let objectList = sceneView.scene.rootNode.childNodes
            
            for object : SCNNode in objectList
            {
                object.removeFromParentNode()
            }
            addObject(SCNVector3(result.worldTransform.columns.3.x,result.worldTransform.columns.3.y,result.worldTransform.columns.3.z))
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        if isPositionGiven
        {
            positionGiven=SCNVector3(0,0,0)
            /*
             var cpts : Float = 0
            for column in Int(qrZone.origin.x)...2*Int(qrZone.origin.x + qrZone.width)
            {
                for row in Int(qrZone.origin.y)...2*Int(qrZone.origin.y + qrZone.height)
                {
                    print("\(CGFloat(column)/2),\(CGFloat(row)/2)")
                    for result in sceneView.hitTest(CGPoint(x: CGFloat(column)/2,y:CGFloat(row)/2), types: [.existingPlaneUsingExtent,.featurePoint])
                    {
                        
                        positionGiven.x+=result.worldTransform.columns.3.x
                        positionGiven.y+=result.worldTransform.columns.3.y
                        positionGiven.z+=result.worldTransform.columns.3.z
                        cpts+=1
                    }
                }
            }
            positionGiven.x=positionGiven.x/cpts
            positionGiven.y=positionGiven.y/cpts
            positionGiven.z=positionGiven.z/cpts
            */
        }
        else {
            positionGiven=SCNVector3(0,0,-1)
        }
        addObject(positionGiven)
        stepperX.value=Double(positionGiven.x)
        stepperY.value=Double(positionGiven.y)
        stepperZ.value=Double(positionGiven.z)
        labelX.text="x: \(positionGiven.x)"
        labelY.text="y: \(positionGiven.y)"
        labelZ.text="z: \(positionGiven.z)"
        
    }
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        labelZ.text="\(frame.camera.transform)"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func modifyPosition(sender : UIStepper)
    {
        switch(sender)
        {
        case stepperX:
            positionGiven.x=Float(stepperX.value)/100
            labelX.text="x: \(positionGiven.x)"
        case stepperY:
            positionGiven.y=Float(stepperY.value)/100
            labelY.text="y: \(positionGiven.y)"
        case stepperZ:
            positionGiven.z=Float(stepperZ.value)/100
            labelZ.text="z: \(positionGiven.z)"
        default : break
        }
        
        let objectList = sceneView.scene.rootNode.childNodes
        
        for object : SCNNode in objectList
        {
            object.removeFromParentNode()
        }
        addObject(positionGiven)
    }
    
    func addObject(_ pos : SCNVector3) {
        let tree = testObject()
        tree.loadModal()
        tree.position = pos
        
        sceneView.scene.rootNode.addChildNode(tree)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
