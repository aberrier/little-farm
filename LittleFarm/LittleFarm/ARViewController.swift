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

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var stepperX : UIStepper!
    @IBOutlet var stepperY : UIStepper!
    @IBOutlet var stepperZ : UIStepper!
    
    @IBOutlet var labelX : UILabel!
    @IBOutlet var labelY : UILabel!
    @IBOutlet var labelZ : UILabel!
    @IBOutlet var infoLabel : UILabel!
    
    var qrZone : CGRect = CGRect.zero
    var scene : SCNScene = SCNScene.init()
    var isPositionGiven : Bool = false
    var testObjectIsInstancied : Bool = false
    var QRDataVector : SCNVector3 = SCNVector3(0,0,0)
    var object3D : testObject?
    var positionBuffer : SCNVector3 = SCNVector3(0,0,0)
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
        
        let delay = 1.0
        /*
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, execute:
        {
            print("Let's go !")
            //print("\(self.hitTestOnRect(rect: self.qrZone))")
            self.object3D = testObject()
            self.object3D?.loadModal()
            self.object3D?.position = SCNVector3(0,0,0)
            self.object3D?.simdTransform = self.TransformMatrixFor2Dto3DProjection(coordinates: CGPoint(x: CGFloat(self.QRDataVector.x),y: CGFloat(self.QRDataVector.y)), side: self.QRDataVector.z)
            self.object3D?.eulerAngles.z=90
            self.sceneView.scene.rootNode.addChildNode(self.object3D!)
            self.updatePositionDisplay()
            
        })
        */
        self.infoLabel.text="Initialization"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, execute:
            {
                print("Calculating coordinates")
                self.positionBuffer=self.PositionFor2Dto3DProjection(coordinates: CGPoint(x: CGFloat(self.QRDataVector.x),y: CGFloat(self.QRDataVector.y)), side: self.QRDataVector.z)
                self.infoLabel.text="Look around for 4 seconds"
                
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+4, execute:
            {
                self.addObjectTest()
                self.object3D?.position = self.positionBuffer
                self.updatePositionDisplay()
                self.infoLabel.text="Object placed"
                
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
    
    
    
    @IBAction func modifyPosition(sender : UIStepper)
    {
        switch(sender)
        {
        case stepperX:
            object3D?.position.x=Float(stepperX.value)/100
        case stepperY:
            object3D?.position.y=Float(stepperY.value)/100
        case stepperZ:
            object3D?.position.z=Float(stepperZ.value)/100
        default : break
        }
        /*
        let objectList = sceneView.scene.rootNode.childNodes
        
        for object : SCNNode in objectList
        {
            object.removeFromParentNode()
        }
        addObject(position : QRDataVector)
 */
        updatePositionDisplay()
    }
    func updatePositionDisplay()
    {
        labelX.text="x: \(object3D?.position.x ?? 0)"
        labelY.text="y: \(object3D?.position.y ?? 0)"
        labelZ.text="z: \(object3D?.position.z ?? 0)"
        stepperX.value=Double(object3D!.position.x*100)
        stepperY.value=Double(object3D!.position.y*100)
        stepperZ.value=Double(object3D!.position.z*100)
        
    }
    func addObjectTest() {
        
        if(!testObjectIsInstancied)
        {
            object3D = testObject()
            object3D?.loadModal()
            sceneView.scene.rootNode.addChildNode(object3D!)
            testObjectIsInstancied=true
        }
        else{
            print("Test object already instancied.")
        }
        
    }
    func addNewObject(position : SCNVector3) {
        let tree = testObject()
        tree.loadModal()
        tree.position = position
        sceneView.scene.rootNode.addChildNode(tree)
    }
    func PositionFor2Dto3DProjection(coordinates : CGPoint, side : Float)->SCNVector3
    {
        let physicalSize : Float = 0.07 //Replace 0.07 by the real size of QRCode
        let focalLength : Float = 0.03
        let coefAdjustment : Float = 9
        
        let alpha = physicalSize/Float(UIScreen.main.nativeScale)*(side/1000)
        let z =  focalLength/(coefAdjustment*alpha)
        let x = Float(UIScreen.main.nativeScale*coordinates.x/1000)*alpha
        let y = Float(UIScreen.main.nativeScale*coordinates.y/1000)*alpha
        
        let originalVector4 = vector4(x, y, -z, 1)
        let newVector4 = matrix_multiply(sceneView.session.currentFrame!.camera.transform, originalVector4)
        return SCNVector3(newVector4.x/newVector4.w,newVector4.y/newVector4.w,newVector4.z/newVector4.w)
    }
    func TransformMatrixFor2Dto3DProjection(coordinates : CGPoint, side : Float)->simd_float4x4
    {
        
        
        let physicalSize : Float = 0.07 //Replace 0.07 by the real size of QRCode
        let focalLength : Float = 0.03
        let coefAdjustment : Float = 9
        
        let alpha = physicalSize/Float(UIScreen.main.nativeScale)*(side/1000)
        let z =  focalLength/(coefAdjustment*alpha)
        let x = Float(UIScreen.main.nativeScale*coordinates.x/1000)*alpha
        let y = Float(UIScreen.main.nativeScale*coordinates.y/1000)*alpha
        
        
        //alert("infos", message: "x:\(x),y:\(y),z:\(z),\(alpha)")
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -z
        translation.columns.3.x = x
        translation.columns.3.y  = y
        
        
        let newTransformMatrix = matrix_multiply(sceneView.session.currentFrame!.camera.transform, translation)
        return newTransformMatrix
    }
    
    @objc func touch(sender : UITapGestureRecognizer)
    {
        
        for result in sceneView.hitTest(CGPoint(x: sender.location(in: view).x,y: sender.location(in: view).y), types: [.existingPlaneUsingExtent,.featurePoint])
        {
            //Pop up message for testing
            alert("\(sender.location(in: view))", message: "\(result.worldTransform.columns.3)\n Camera position : \(sceneView.session.currentFrame?.camera.transform ?? matrix_identity_float4x4)")
            
            //Moving the 3D Object to the new coordinates
            let objectList = sceneView.scene.rootNode.childNodes
            
            for object : SCNNode in objectList
            {
                object.removeFromParentNode()
            }
            object3D?.position = SCNVector3(result.worldTransform.columns.3.x,result.worldTransform.columns.3.y,result.worldTransform.columns.3.z)
            updatePositionDisplay()
        }
        
        
    }
    
    
    func hitTestOnRect(rect : CGRect) -> SCNVector3
    {
        var cpts : Float = 0
        var newPosition = SCNVector3(0,0,0)
        for column in Int(rect.origin.x)...Int(rect.origin.x + rect.width)
        {
            for row in Int(rect.origin.y)...Int(rect.origin.y + rect.height)
            {
                let newPoint = CGPoint(x: CGFloat(column)/view.frame.size.height,y:CGFloat(row)/view.frame.size.width)
                print("\(newPoint)")
                for result in self.sceneView.hitTest(newPoint, types: [.existingPlaneUsingExtent,.featurePoint])
                {
                    
                    newPosition.x+=result.worldTransform.columns.3.x
                    newPosition.y+=result.worldTransform.columns.3.y
                    newPosition.z+=result.worldTransform.columns.3.z
                    cpts+=1
                }
                
                
            }
        }
        
        newPosition.x=newPosition.x/cpts
        newPosition.y=newPosition.y/cpts
        newPosition.z=newPosition.z/cpts
        return newPosition
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
