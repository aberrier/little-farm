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
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var stepperX : UIStepper!
    @IBOutlet var stepperY : UIStepper!
    @IBOutlet var stepperZ : UIStepper!
    
    @IBOutlet var labelX : UILabel!
    @IBOutlet var labelY : UILabel!
    @IBOutlet var labelZ : UILabel!
    
    @IBOutlet var goButton : UIButton!
    
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
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
        
        /*
        if isPositionGiven
        {
            let delay = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, execute:
            {
                
                print("Let's go !")
                self.placeObjectOnCamera()
                self.updatePositionDisplay()
                
                /*
                var cpts : Float = 0
                for column in Int(self.qrZone.origin.x)...2*Int(self.qrZone.origin.x + self.qrZone.width)
                {
                    for row in Int(self.qrZone.origin.y)...2*Int(self.qrZone.origin.y + self.qrZone.height)
                    {
                        //print("\(CGFloat(column)/2),\(CGFloat(row)/2)")
                        for result in self.sceneView.hitTest(CGPoint(x: CGFloat(column)/2,y:CGFloat(row)/2), types: [.existingPlaneUsingExtent,.featurePoint])
                        {
                            
                            self.positionGiven.x+=result.worldTransform.columns.3.x
                            self.positionGiven.y+=result.worldTransform.columns.3.y
                            self.positionGiven.z+=result.worldTransform.columns.3.z
                            cpts+=1
                        }
                        
                        
                    }
                }
                self.positionGiven.x=self.positionGiven.x/cpts
                self.positionGiven.y=self.positionGiven.y/cpts
                self.positionGiven.z=self.positionGiven.z/cpts
                 */
            }
           )
            
            
        }
        else {
            positionGiven=SCNVector3(0,0,-0.5)
        }
         */
        
        let delay = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, execute:
        {
            print("Let's go !")
            let tree = testObject()
            tree.loadModal()
            tree.position = SCNVector3(0,0,0)
            tree.simdTransform = self.TransformMatrixFor2Dto3DProjection(coordinates: CGPoint(x: CGFloat(self.positionGiven.x),y: CGFloat(self.positionGiven.y)), side: self.positionGiven.z)
            self.sceneView.scene.rootNode.addChildNode(tree)
            self.positionGiven=tree.position
            self.updatePositionDisplay()
            
            //Test tree
            let tree2 = testObject()
            tree2.loadModal()
            tree2.position = SCNVector3(0,0,0)
            tree2.simdTransform = self.TransformMatrixFor2Dto3DProjection(coordinates: CGPoint(x: 0,y: 0), side: self.positionGiven.z)
            self.sceneView.scene.rootNode.addChildNode(tree2)
        })
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func touch(sender : UITapGestureRecognizer)
    {
        
        for result in sceneView.hitTest(CGPoint(x: sender.location(in: view).x,y: sender.location(in: view).y), types: [.existingPlaneUsingExtent,.featurePoint])
        {
            //Pop up message for testing
            alert("\(sender.location(in: view))", message: "\(result.worldTransform.columns.3)\n Camera position : \(sceneView.session.currentFrame?.camera.transform)")
            
            //Moving the 3D Object to the new coordinates
            let objectList = sceneView.scene.rootNode.childNodes
            
            for object : SCNNode in objectList
            {
                object.removeFromParentNode()
            }
            positionGiven = SCNVector3(result.worldTransform.columns.3.x,result.worldTransform.columns.3.y,result.worldTransform.columns.3.z)
            addObject(position : positionGiven)
            updatePositionDisplay()
        }
        
        
    }
    
    @IBAction func changeSysCoord(_ sender: UIButton) {
        let objectList = sceneView.scene.rootNode.childNodes
        
        for object : SCNNode in objectList
        {
            object.removeFromParentNode()
        }
        let tree = testObject()
        tree.loadModal()
        sceneView.scene.rootNode.addChildNode(tree)
        updatePositionDisplay()
    }
    
    @IBAction func modifyPosition(sender : UIStepper)
    {
        switch(sender)
        {
        case stepperX:
            positionGiven.x=Float(stepperX.value)/100
        case stepperY:
            positionGiven.y=Float(stepperY.value)/100
        case stepperZ:
            positionGiven.z=Float(stepperZ.value)/100
        default : break
        }
        let objectList = sceneView.scene.rootNode.childNodes
        
        for object : SCNNode in objectList
        {
            object.removeFromParentNode()
        }
        addObject(position : positionGiven)
        updatePositionDisplay()
    }
    func updatePositionDisplay()
    {
        labelX.text="x: \(positionGiven.x)"
        labelY.text="y: \(positionGiven.y)"
        labelZ.text="z: \(positionGiven.z)"
        stepperX.value=Double(positionGiven.x*100)
        stepperY.value=Double(positionGiven.y*100)
        stepperZ.value=Double(positionGiven.z*100)
        
    }
    func addObject(position : SCNVector3) {
        let tree = testObject()
        tree.loadModal()
        tree.position = position
        sceneView.scene.rootNode.addChildNode(tree)
    }
    func TransformMatrixFor2Dto3DProjection(coordinates : CGPoint, side : Float)->simd_float4x4
    {
        
        
        //Conversion into meters
        var x = Float(UIScreen.main.nativeScale*coordinates.x/10000)
        var y = Float(UIScreen.main.nativeScale*coordinates.y/10000)
        let alpha = 0.07/Float(UIScreen.main.nativeScale)*(side/10000) //Replace 0.07 by the real size of QRCode
        alert("infos", message: "\(x),\(y),\(alpha)")
        x*=alpha
        y*=alpha
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.7
        translation.columns.3.x = x
        translation.columns.3.y  = y
        
        
        let newTransformMatrix = matrix_multiply(sceneView.session.currentFrame!.camera.transform, translation)
        return newTransformMatrix
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
