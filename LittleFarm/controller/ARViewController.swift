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

class ARViewController: UIViewController, ARSCNViewDelegate, StoryViewDelegate {
    
    var dataManager = PersistentDataManager.sharedInstance
    
    //Debug variables, should be gone soon 🙂
    @IBOutlet var labelX : UILabel!
    @IBOutlet var labelY : UILabel!
    @IBOutlet var labelZ : UILabel!
    @IBOutlet var infoLabel : UILabel!
    @IBOutlet var dragSwitch : UISwitch!
    @IBOutlet var swiftText : UILabel!
    @IBOutlet var stepperX : UIStepper!
    @IBOutlet var stepperY : UIStepper!
    @IBOutlet var stepperZ : UIStepper!
    var boundingBoxView:UIView?
    
    //Position placement
    @IBOutlet var positionButton : UIButton!
    @IBOutlet var replacePositionbutton : UIButton!
    
    var positionTrigger = false
    {
        didSet
        {
            positionButton.isHidden = positionTrigger
            replacePositionbutton.isHidden = !positionTrigger
        }
    }
    //AR variables
    @IBOutlet var sceneView: ARSCNView!
    var testObjectIsInstancied : Bool = false
    var positionBuffer : SCNVector3 = SCNVector3(0,0,0)
    var object3D : testObject?
    
    //QRCode mode
    var qrZone : CGRect = CGRect.zero
    var scene : SCNScene = SCNScene()
    var qrCodeMode : Bool = false
    
    //Story variables
    let scenario = StoryScenario.instance
    @IBOutlet var storyView : StoryView!
    
    //Timer
    var actionActivated : Bool = false
    var timer = Timer()
    
    //OpenCV
    @IBOutlet var imageTest : UIImageView!
    
    var freeze = false
    var counter = 0
    var bufferBox : redBox = redBox()
    
    let openCV = OpenCVDetection()!
    var openCVTimer = Timer();
    
    let filename = ConfigDataManager.sharedInstance.configDetection["filename"]!
    let device = ConfigDataManager.sharedInstance.configDetection["device"]!
    let meshName = ConfigDataManager.sharedInstance.configDetection["meshname"]!
    
    //Filter
    let minX : Float = -1.0
    let maxX : Float = 1.0
    
    let minY : Float = -2.0
    let maxY : Float = 2.0
    
    let minZ : Float = -2.0
    let maxZ : Float = 0
    let minConfidence = 20.0
    
    //Average
    var positionArray: [SCNVector3] = []
    
    let configData = ConfigDataManager.sharedInstance
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Set the pan gesture recognizer
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touch)))
        
        // Delegate setup
        sceneView.delegate = self
        storyView.delegate = self
        
        //storyView setup
        storyView.setup()
        
        //Placement button setup
        positionButton.isHidden = positionTrigger
        replacePositionbutton.isHidden = !positionTrigger
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
        //Add the axis
        let axis = AxisCoordinate()
        axis.position = SCNVector3Zero
        //sceneView.scene.rootNode.addChildNode(axis)
        
        //If QRCode mode is activated, we place the 3D Object on it
        if(qrCodeMode)
        {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(setPositionOfObjectOnQRZone)), userInfo: nil, repeats: true)
        }
        else
        {
            setObjectTest()
        }
        
        //OpenCV setup
        
        //let ymlPath = Bundle.main.path(forResource: "ORBL", ofType: "yml")!
<<<<<<< HEAD
        let ymlPath = GT.getFileForWriting(name: "ORB.yml")!
        setupDetection(ymlPath: ymlPath, plyPath: Bundle.main.path(forResource: "mesh", ofType: "ply")!)
        //Code : get the 2D Position of object
        //Hittest
=======
        let ymlPath = GT.getFilePath(name: filename)!
        setupDetection(ymlPath: ymlPath, plyPath: Bundle.main.path(forResource: meshName, ofType: "ply")!)
        
>>>>>>> 9129b835c26218ff2cb161d0472e50bf5b7806e1
        //Debug view
        //View to highligth the boudingbox
        boundingBoxView = UIView()
        
        if boundingBoxView != nil {
            boundingBoxView?.layer.borderColor = UIColor.green.cgColor
            boundingBoxView?.layer.borderWidth = 2
            sceneView.addSubview(boundingBoxView!)
            sceneView.bringSubview(toFront: boundingBoxView!)
            
        }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        timer.invalidate()
        openCVTimer.invalidate()
    }
    private func determineWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        let arHitTestResults = sceneView.hitTest(CGPoint(x: boundingBox.midX, y: boundingBox.midY), types: [.featurePoint])
        
        // Filter results that are to close
        if let closestResult = arHitTestResults.filter({ LFFilter($0.worldTransform.toRedBox()) }).first {
            //            print("vector distance: \(closestResult.distance)")
            return SCNVector3.positionFromTransform(closestResult.worldTransform)
        }
        return nil
    }
    private func determineWorldCoordInAllArea(_ boundingBox: CGRect) -> SCNVector3? {
        var positionsList : [SCNVector3] = []
        for x in Int(boundingBox.minX)...Int(boundingBox.maxX)
        {
            for y in Int(boundingBox.minY)...Int(boundingBox.maxY)
            {
                let arHitTestResults = sceneView.hitTest(CGPoint(x: x, y: y), types: [.featurePoint])
                
                // Filter results that are too close
                if let closestResult = arHitTestResults.filter({ LFFilter($0.worldTransform.toRedBox()) }).first {
                    //            print("vector distance: \(closestResult.distance)")
                    positionsList += [SCNVector3.positionFromTransform(closestResult.worldTransform)]
                }
            }
        }
        return SCNVector3.center(positionsList)
        //return nil
    }
    @IBAction func setPositionOfObject( _ sender : UIButton)
    {
        object3D?.position = applyCameraTransformation(SCNVector3(0,0,-0.10))
        positionTrigger = true
        
    }
    @IBAction func replacePosition( _ sender : UIButton)
    {
        positionTrigger = false
    }
    func setupDetection(ymlPath : String,plyPath : String)
    {
        //Camera calibration
        if let cameraIntrinsic = configData.getCamera(informations: .intrinsicMatrix, ofModel: device) ,
            let cameraDistorsion = configData.getCamera(informations: .distorsionMatrix, ofModel: device)
        {
            openCV.loadCameraParameters(cameraIntrinsic)
            openCV.loadDistorsionParameters(cameraDistorsion)
        }
        else
        {
            print("No calibration matrix found for \(device)")
        }
        //File path
        openCV.setFilePaths(ymlPath,plyPath )

        //Time interval
        openCV.setTimeInterval(0.016)
        //Setup
        openCV.setup()
        //Start detection
        openCVTimer = Timer.scheduledTimer(timeInterval: openCV.getTimeInterval(), target: self, selector: (#selector(openCVFrameDetection)), userInfo: nil, repeats: true)
    }
    @objc func openCVFrameDetection()
    {
        
        if object3D != nil && !freeze
        {
            
            let sampleBuffer = sceneView.session.currentFrame?.capturedImage
            let data = openCV.detect2DBoundingBox(on: sampleBuffer)!
            //print("AREA : \(area)")
            boundingBoxView?.frame = data.getArea()
            print("Box : \(data.getArea()) , \(data.getConfidence())")
            if let position = determineWorldCoord(data.getArea()) {
                print("New position \(position)")
                positionArray.append(position)
            }
            print("Average position : \(SCNVector3.center(positionArray))")
            object3D?.position = SCNVector3.center(positionArray)
            if positionArray.count > 100
            {
                positionArray = []
            }
            updatePositionDisplay()
            /*
             let data : redBox = openCV.detect(on: sampleBuffer)
             print("Position given by openCV : \(data.getX()),\(data.getY()),\(data.getZ())")
             imageTest.image = data.getImage()
             //Conversion to ARKIT coordinate scale
             
             data.setX(data.getX()/100)
             data.setY(data.getY()/100)
             data.setZ(-data.getZ()/10)
             print("Position after conversion : \(data.getX()),\(data.getY()),\(data.getZ())")
             if(!freeze && LFFilter(data))
             {
             object3D?.position = applyCameraTransformation(SCNVector3(data.getX(),data.getY(),data.getZ()))
             print("Position of object : \(object3D?.position)")
             
             updatePositionDisplay()
             }
             */
            
            
            
        }
        
    }
    //Modify position with steppers
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
        updatePositionDisplay()
    }
    
    //Update display of coordinates
    func updatePositionDisplay()
    {
        labelX.text="x: \(object3D?.position.x ?? 0)"
        labelY.text="y: \(object3D?.position.y ?? 0)"
        labelZ.text="z: \(object3D?.position.z ?? 0)"
        stepperX.value=Double(object3D!.position.x*100)
        stepperY.value=Double(object3D!.position.y*100)
        stepperZ.value=Double(object3D!.position.z*100)
        
    }
    //Timer
    @objc func setPositionOfObjectOnQRZone()
    {
        if sceneView.isPlaying && !actionActivated
        {
            //3D Position of the object
            if object3D == nil
            {
                self.infoLabel.text="Calculating coordinates"
                //Calculating coordinates
                self.setObjectTest()
                self.object3D?.position = self.PositionFor2Dto3DProjection(area: self.qrZone)
                self.updatePositionDisplay()
                self.infoLabel.text="Object placed"
                actionActivated = true
            }
            else
            {
                print("The object is already been placed")
            }
        }
        if actionActivated
        {
            stopTimer()
        }
        
    }
    func stopTimer()
    {
        timer.invalidate()
    }
    
    func getAverageValue(_ tab : [Float]) -> Float
    {
        var avr : Float = 0
        for val in tab
        {
            avr += val
        }
        return avr/Float(tab.count)
    }
    
    func LFFilter( _ data : redBox) -> Bool
    {
        if(data.getX() >= minX && data.getX() <= maxX &&
            data.getY() >= minY && data.getY() <= maxY &&
            data.getZ() >= minZ && data.getZ() <= maxZ &&
            data.getConfidence() >= minConfidence)
        {
            //print("Position(\(data.getX()),\(data.getY()),\(data.getZ()),\(data.getConfidence())%) accepted.")
            return true
        }
        //print("Stack : \(data.getX() >= minX):\(data.getX() <= maxX):\(data.getY() >= minY):\(data.getY() <= maxY):\(data.getZ() >= minZ):\(data.getZ() <= maxZ):\(data.getConfidence() >= minConfidence)")
        //print("Position(\(data.getX()),\(data.getY()),\(data.getZ()),\(data.getConfidence())%) rejected.")
        return false
    }
    
    func applyCameraTransformation(_ firstPos : SCNVector3) -> SCNVector3
    {
        if let cameraFrame = sceneView.session.currentFrame
        {
            let originalVector4 = vector4(firstPos.x, firstPos.y, firstPos.z, 1)
            let newVector4 = matrix_multiply(cameraFrame.camera.transform, originalVector4)
            return SCNVector3(newVector4.x/newVector4.w,newVector4.y/newVector4.w,newVector4.z/newVector4.w)
        }
        return firstPos
        
        
    }
    
    func stopOpenCVTimer()
    {
        openCVTimer.invalidate()
    }
    
    @IBAction func freezeSwitch(_ sender:UISwitch)
    {
        freeze = !freeze
    }
    
    //Add primal object
    func setObjectTest() {
        
        object3D = testObject()
        object3D?.loadModal()
        object3D?.name = "primal"
        sceneView.scene.rootNode.addChildNode(object3D!)
        
    }
    
    //Add new object without strong reference
    func addNewObject(position : SCNVector3) {
        let tree = testObject()
        tree.loadModal()
        tree.position = position
        sceneView.scene.rootNode.addChildNode(tree)
    }
    
    
    //Calculate the position on the 3D coordinate system
    func PositionFor2Dto3DProjection(area : CGRect)->SCNVector3
    {
        let physicalSize : Float = 0.07 //Replace 0.07 by the real size of QRCode
        let focalLength : Float = 0.03
        let coefAdjustment : Float = 9
        
        let averageSide = Float(area.height+area.width)/2
        let centeredX = area.origin.x+(area.height/2)
        let centeredY = area.origin.y+(area.width/2)
        
        let alpha = physicalSize/Float(UIScreen.main.nativeScale)*(averageSide/1000)
        
        let z =  focalLength/(coefAdjustment*alpha)
        let x = Float(UIScreen.main.nativeScale*centeredX/1000)*alpha
        let y = Float(UIScreen.main.nativeScale*centeredY/1000)*alpha
        
        let originalVector4 = vector4(x, y, -z, 1)
        let newVector4 = matrix_multiply(sceneView.session.currentFrame!.camera.transform, originalVector4)
        return SCNVector3(newVector4.x/newVector4.w,newVector4.y/newVector4.w,newVector4.z/newVector4.w)
    }
    
    
    
    //Touch on screen
    @objc func touch(sender : UITapGestureRecognizer)
    {
        
        if(dragSwitch.isOn)
        {
            for result in sceneView.hitTest(CGPoint(x: sender.location(in: view).x,y: sender.location(in: view).y), types: [.existingPlaneUsingExtent,.featurePoint])
            {
                //Pop up message for testing
                infoLabel.text="You move the object to \(result.worldTransform.columns.3)"
                
                //Moving the 3D Object to the new coordinates
                object3D?.position = SCNVector3(result.worldTransform.columns.3.x,result.worldTransform.columns.3.y,result.worldTransform.columns.3.z)
                updatePositionDisplay()
            }
        }
        else
        {
            for result in sceneView.hitTest(CGPoint(x: sender.location(in: view).x,y: sender.location(in: view).y), options: nil)
            {
                if result.node.parent?.name == "cupcake"
                {
                    turnObjectTest()
                    addObjectsTestOnFirstObject()
                }
            }
        }
    }
    //Turn animation
    func turnObjectTest()
    {
        let delay : Double = 1000
        let action = SCNAction.rotateBy(x: 0, y: 2*CGFloat(delay), z: 0, duration: delay)
        object3D?.runAction(action)
    }
    
    //Objects explosion animation
    func addObjectsTestOnFirstObject() {
        let obj : [testObject] = [testObject(),testObject(),testObject(),testObject()]
        let delay : Float = 4
        for newObj in obj
        {
            newObj.loadModal()
            newObj.position = object3D!.position
            sceneView.scene.rootNode.addChildNode(newObj)
            let xPos = GT.randomPosition(lowerBound: -0.2, upperBound: 0.2)
            let yPos = GT.randomPosition(lowerBound: 0, upperBound: 0.2)
            let zPos = GT.randomPosition(lowerBound: -0.2, upperBound: 0.2)
            let newAction = SCNAction.move(by: SCNVector3(xPos*delay,yPos*delay,zPos*delay), duration: Double(delay))
            newObj.runAction(newAction)
        }
    }
    
    //Story
    func storyPressButton(sender: StoryButton) {
        switch(sender.action)
        {
        case let .CallController(id,type) :
            print(id)
            //call the controller
            switch(type)
            {
                
            case .ARViewController:
                break
            case .RegisterViewController:
                break
            case .nothing:
                break
            }
        case let .CallStoryScreen(id) :
            //Load the new screen
            let newScreen = scenario.data[id]
            
            storyView.loadScreen(screen: newScreen!)
        case let .CheckpointStory(storyId) :
            if let currentUser = dataManager.getCurrentUser()
            {
                currentUser.storyId = storyId
                if !dataManager.changeUser(user: currentUser)
                {
                    print("ARView - storyPressButton - Checkpoint :  Can't change the current user.")
                }
            }
        //change the storyId on the current user
        case .EndApplication :
            //End application
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        case .EndStory:
            if let currentUser = dataManager.getCurrentUser()
            {
                currentUser.onStoryMode = false
                if !dataManager.changeUser(user: currentUser)
                {
                    print("ARView - storyPressButton - EndStory :  Can't change the current user.")
                }
            }
            //End story
            storyView.isHidden=true
        case .DoNothing : break
            
            
        }
    }
    
    //Old functions that doesn't work 😥
    func _hitTestOnRect(rect : CGRect) -> SCNVector3
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
    func _PositionFor2Dto3DProjection(coordinates : CGPoint, side : Float)->SCNVector3
    {
        let physicalSize : Float = 0.07 //Replace 0.07 by the real size of QRCode
        let focalLength : Float = 0.03
        let coefAdjustment : Float = 13
        let virtualSize = side/(2*1000*Float(UIScreen.main.nativeScale))
        let alpha = physicalSize/virtualSize
        //let alpha = physicalSize/Float(UIScreen.main.nativeScale)*(side/1000)
        
        let z =  focalLength*alpha*coefAdjustment
        let x = (alpha*Float(coordinates.x))/(10*1000*Float(UIScreen.main.nativeScale))
        let y = (alpha*Float(coordinates.y))/(30*1000*Float(UIScreen.main.nativeScale))
        
        print("Virtual length : \(virtualSize)")
        print("ALPHA : \(alpha)")
        print("x:\(x),y:\(y),z:\(-z)")
        return applyCameraTransformation(SCNVector3(x,y,z))
    }
    func _TransformMatrixFor2Dto3DProjection(coordinates : CGPoint, side : Float)->simd_float4x4
    {
        
        
        let physicalSize : Float = 0.07 //Replace 0.07 by the real size of QRCode
        let focalLength : Float = 0.03
        let coefAdjustment : Float = 9
        
        let alpha = physicalSize/Float(UIScreen.main.nativeScale)*(side/1000)
        let z =  focalLength/(coefAdjustment*alpha)
        let x = Float(UIScreen.main.nativeScale*coordinates.x/1000)*alpha
        let y = Float(UIScreen.main.nativeScale*coordinates.y/1000)*alpha
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -z
        translation.columns.3.x = x
        translation.columns.3.y  = y
        
        
        let newTransformMatrix = matrix_multiply(sceneView.session.currentFrame!.camera.transform, translation)
        return newTransformMatrix
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print(error.localizedDescription)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}





