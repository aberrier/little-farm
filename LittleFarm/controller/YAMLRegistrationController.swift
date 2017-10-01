//
//  YAMLRegistrationController.swift
//  LittleFarm
//
//  Created by saad on 21/08/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit

class YAMLRegistrationController : UIViewController, UIGestureRecognizerDelegate
{
    @IBOutlet var meshDisplay: SCNView!
    @IBOutlet var imageDisplay: UIImageView!
    
    @IBOutlet var infoText: UILabel!
    @IBOutlet var meshWrapperView: UIView!
    @IBOutlet var selector: UIImageView!
    
    @IBOutlet var imageWrapperView: UIView!
    @IBOutlet var standardCommand: UIView!
    @IBOutlet var layerCommand: UIView!
    
    //Standard command
    @IBOutlet var backArrow: UIButton!
    @IBOutlet var nextArrow: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var validateButton: UIButton!
    @IBOutlet var ignoreButton: UIButton!
    @IBOutlet var terminateButton: UIButton!
    
    //Layer command
    @IBOutlet var layerSwitch: UISwitch!
    @IBOutlet var yStepper: UIStepper!
    @IBOutlet var xStepper: UIStepper!
    @IBOutlet var validateLayering: UIButton!
    
    let configData = ConfigDataManager.sharedInstance
    
    //Data
    var scene = SCNScene()
    var pointsNode = SCNNode()
    var meshNode = SCNNode()
    let openCVRegistration = OpenCVRegistration()!
    let imgData = ConfigDataManager.sharedInstance.imagesForCreation

    var imgTab : [UIImage] = []
    var currentIndex = 0
    var modeDrag = false
    var modeDragSelector = false
    let filename = ConfigDataManager.sharedInstance.configCreation["filename"]!
    let device = ConfigDataManager.sharedInstance.configCreation["device"]!
    let meshName = ConfigDataManager.sharedInstance.configCreation["meshname"]!
    let sceneName = ConfigDataManager.sharedInstance.configCreation["scenename"]!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //print("\(GT.getFileOnString(name: name)!)")aa
        //setup
        //load the image array
        for str in imgData
        {
            if let image =  UIImage(named: str)
            {
                imgTab += [GT.normalizedImage(image: image)]
            }
            else
            {
                print("Image not loaded.")
                imgTab += [UIImage()]
            }
        }
        layerCommand.isHidden = !layerSwitch.isOn
        standardCommand.isHidden = layerSwitch.isOn
        xStepper.maximumValue = Double(imageWrapperView.frame.size.width)
        yStepper.maximumValue = Double(imageWrapperView.frame.size.height)
        meshDisplay.backgroundColor =  UIColor.white
        meshWrapperView.layer.borderColor = UIColor.clear.cgColor
        
        meshWrapperView.backgroundColor = UIColor.clear
        configData.extractCameraFeatures()
        selector.isHidden = true
        meshDisplay.autoenablesDefaultLighting = true
        meshDisplay.allowsCameraControl = true
        meshDisplay.scene = scene
        meshDisplay.backgroundColor = UIColor.clear
        let axis = AxisCoordinate()
        scene.rootNode.addChildNode(axis)
        scene.rootNode.addChildNode(pointsNode)
        
        infoText.numberOfLines = 2
        //OpenCV setup
        
        if let cameraIntrinsic = configData.getCamera(informations: .intrinsicMatrix, ofModel: device) ,
            let cameraDistorsion = configData.getCamera(informations: .distorsionMatrix, ofModel: device )
        {
            openCVRegistration.loadCameraParameters(cameraIntrinsic)
            openCVRegistration.loadDistorsionParameters(cameraDistorsion)
        }
        else
        {
            print("No calibration matrix found for \(device)")
        }
        //File path
        openCVRegistration.setFilePath(Bundle.main.path(forResource: meshName, ofType: "ply")!)
        openCVRegistration.setup()
        //gesture recognizers
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragObject))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchAction))
        let longPressRecognizer = UILongPressGestureRecognizer(target : self,action : #selector(activateDrag))
        longPressRecognizer.minimumPressDuration = 0.5
        panRecognizer.delegate = self
        longPressRecognizer.delegate = self
        tapRecognizer.delegate = self
        
        view.addGestureRecognizer(panRecognizer)
        view.addGestureRecognizer(longPressRecognizer)
        imageWrapperView.addGestureRecognizer(tapRecognizer)
        //Load mesh
        if let virtualObjectScene = SCNScene(named: "art.scnassets/"+sceneName+".scn")
        {
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                wrapperNode.addChildNode(child)
            }
            //set OpenCV mesh scale
            meshNode = wrapperNode
            openCVRegistration.setScale(meshNode.boundingSphere.radius)
            scene.rootNode.addChildNode(meshNode)
            
        }
        else
        {
            return
        }
        //setup image display
        updateDisplay()
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scene.rootNode.camera? = SCNCamera()
        scene.rootNode.camera?.zNear = -2
        xStepper.value = Double(meshWrapperView.frame.width/imageWrapperView.frame.width)*100
        yStepper.value = Double(meshWrapperView.frame.height/imageWrapperView.frame.height)*100
        
    }
    
    
    //Actions
    @IBAction func cancelAction(_ sender : UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func ignoreAction(_ sender : UIButton)
    {
        openCVRegistration.nextVertex()
        updateDisplay()
    }
    @IBAction func validateAction(_ sender : UIButton)
    {
        //Take the coordinates of selection
        //Make sur that the coordinates on screen match correctly on the Mat
        //Add the point
        if(selector.isHidden)
        {
            print("No point selected")
        }
        else
        {
            
            let coord = selector.center
            //coord.x = coord.x - 16
            //coord.y = coord.y - 13
            let image = imgTab[currentIndex]
            let x = Int32((coord.x*image.size.width)/(imageWrapperView.frame.size.width))
            let y = Int32((coord.y*image.size.height)/(imageWrapperView.frame.size.height))
            
            print("Point at : x:\(x) , y:\(y)")
            openCVRegistration.addPoint(x, y,image)
            
            updateDisplay()
            
            
        }
        
    }
    @IBAction func terminateAction(_ sender : UIButton)
    {
        //Create the YAML file
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func changeImage( _ sender : UIButton)
    {
        switch(sender)
        {
        case  backArrow :
            if currentIndex > 0
            {
                currentIndex-=1
                print(currentIndex)
            }
        case nextArrow :
            if currentIndex < imgData.count
            {
                currentIndex+=1
                print(currentIndex)
            }
        default : break
        }
        updateDisplay()
    }
    @IBAction func validateLayering(_ sender : UIButton)
    {
        //Re-setup to overwrite changes
        openCVRegistration.setup()
        meshNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red:0.71, green:0.90, blue:0.90, alpha:0.5)
        let sphere = SCNSphere(radius: CGFloat(0.1*meshNode.boundingSphere.radius))
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        pointsNode = SCNNode(geometry: sphere)
        pointsNode.position = SCNVector3Zero
        while !openCVRegistration.isRegistrationFinished()
        {
            let box : redBox = openCVRegistration.getCurrentVertex()
            var position = SCNVector3(box.getX(),box.getY(),box.getZ())
            pointsNode.position = position
            
            let image = imgTab[currentIndex]
            
            position = meshDisplay.projectPoint(position)
            var coord = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
            coord.x += meshWrapperView.frame.minX
            coord.y += meshWrapperView.frame.minY - imageWrapperView.frame.minY
            let test = UIImageView(image: UIImage(named: "ruby"))
            test.frame = CGRect(x: Int(coord.x), y: Int(coord.y), width: 10, height: 10)
            self.imageWrapperView.addSubview(test)
            
            let x = Int32((coord.x * image.size.width)/(imageWrapperView.frame.size.width))
            let y = Int32((coord.y * image.size.height)/(imageWrapperView.frame.size.height))
            print("Position : \(x),\(y)")
            print("Size : \(imgTab[currentIndex].size)")
            //openCVRegistration.addPoint(200, 200, imgTab[currentIndex])
            openCVRegistration.addPoint(x, y, imgTab[currentIndex])
        }
        updateDisplay()
    }
    @IBAction func switchLayerAction(_ sender : UISwitch)
    {
        layerCommand.isHidden = !sender.isOn
        standardCommand.isHidden = sender.isOn
        meshDisplay.backgroundColor = layerSwitch.isOn ? UIColor.clear : UIColor.white
        meshWrapperView.layer.borderColor = layerSwitch.isOn ? UIColor.black.cgColor : UIColor.clear.cgColor
        
    }
    @IBAction func modifySizeAction(_ sender : UIStepper)
    {
            meshWrapperView.frame = CGRect(x:meshWrapperView.frame.minX, y:meshWrapperView.frame.minY , width: (CGFloat(xStepper.value)*imageWrapperView.frame.width)/100 , height: (CGFloat(yStepper.value)*imageWrapperView.frame.height)/100 )
    }
    func updateDisplay()
    {
        //Coordinates
        let data = openCVRegistration.getCurrentVertex()!
        let originalImage = imgTab[currentIndex]
        pointsNode = openCVRegistration.scnNodeOf3DPoints()
        scene.rootNode.addChildNode(pointsNode)
        
        if openCVRegistration.isRegistrationFinished()
        {
            infoText.text = "Registration finished."
            
            imageDisplay.image = openCVRegistration.computePose(originalImage)
            openCVRegistration.saveFile(at: GT.getFilePath(name: filename)!)
            //print("\(GT.getFileOnString(name: name))")
            
            
        }
        else
        {
            infoText.text = "Where is the point (\(data.getX()),\(data.getY()),\(data.getZ())) ?\n\(openCVRegistration.getVertexIndex())/\(openCVRegistration.getNumVertex())"
            imageDisplay.image = originalImage
            imageDisplay.image = openCVRegistration.add2DPoints(originalImage)
        }
        //imageDisplay.image = openCVRegistration.add2DPoints(originalImage)
        
        
    }
    //Gesture recognizers
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func touchAction(_ sender : UITapGestureRecognizer)
    {
        if selector.isHidden
        {
            selector.isHidden=false
        }
        let coord = sender.location(in : imageWrapperView)
        selector.center = coord
    }
    @objc func activateDrag(_ sender : UILongPressGestureRecognizer)
    {
        if(selector.frame.contains(sender.location(in: view)))
        {
            switch(sender.state)
            {
                
            case .began:
                break
                //selector.layer.borderWidth = 4
            //selector.layer.borderColor = UIColorSet.darkBlue.cgColor
            case .changed:
                break
            //modeDragSelector = true
            case .ended:
                modeDragSelector = false
                //selector.layer.borderWidth = 0
            //selector.layer.borderColor = UIColor.clear.cgColor
            default : break
            }
        }
        if(meshWrapperView.frame.contains(sender.location(in: view)))
        {
            switch(sender.state)
            {
                
            case .began:
                meshDisplay.backgroundColor = UIColorSet.transparentGrayBlue
            case .changed:
                modeDrag = true
                meshDisplay.allowsCameraControl = false
            case .ended:
                modeDrag = false
                meshDisplay.allowsCameraControl = true
            default : break
            }
        }
        
    }
    @objc func dragObject(_ sender : UIPanGestureRecognizer)
    {
        if modeDrag
        {
            switch(sender.state)
            {
                
            case .began :
                meshWrapperView.layer.borderWidth = 4
                meshWrapperView.layer.borderColor = layerSwitch.isOn ? UIColor.black.cgColor : UIColorSet.darkBlue.cgColor
            case .changed :
                let coord = sender.location(in: self.view)
                meshWrapperView.center = coord
            case .ended :
                meshWrapperView.layer.borderWidth = 0
                meshWrapperView.layer.borderColor = layerSwitch.isOn ? UIColor.black.cgColor : UIColor.clear.cgColor
                meshDisplay.backgroundColor = layerSwitch.isOn ? UIColor.clear : UIColor.white
            default :
                break
            }
        }
        if modeDragSelector
        {
            switch(sender.state)
            {
            case .changed :
                let coord = sender.location(in: self.view)
                selector.center = coord
                
            default :
                break
            }
        }
        
    }
    
}



