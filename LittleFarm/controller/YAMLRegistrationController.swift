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
    @IBOutlet var backArrow: UIButton!
    @IBOutlet var nextArrow: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var validateButton: UIButton!
    @IBOutlet var ignoreButton: UIButton!
    @IBOutlet var terminateButton: UIButton!
    @IBOutlet var infoText: UILabel!
    @IBOutlet var meshWrapperView: UIView!
    @IBOutlet var selector: UIImageView!
    
    @IBOutlet var imageWrapperView: UIView!
    
    
    
    //Data
    var scene = SCNScene()
    var pointsNode = SCNNode()
    let openCVRegistration = OpenCVRegistration()
    let imgData = ["img"]
    var currentIndex = 0
    var modeDrag = false
    var testNode = SCNNode()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //setup
        
        selector.isHidden = true
        meshDisplay.autoenablesDefaultLighting = true
        meshDisplay.allowsCameraControl = true
        meshDisplay.scene = scene
        meshDisplay.backgroundColor = UIColor.clear
        let axis = AxisCoordinate()
        scene.rootNode.addChildNode(axis)
        scene.rootNode.addChildNode(pointsNode)
        scene.rootNode.camera? = SCNCamera()
        scene.rootNode.camera?.zNear = -1
        
        infoText.numberOfLines = 2
        //open cv setup
        openCVRegistration.setup()
        //gesture recognizers
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragMesh))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchAction))
        let longPressRecognizer = UILongPressGestureRecognizer(target : self,action : #selector(activateDrag))
        longPressRecognizer.minimumPressDuration = 0.5
        panRecognizer.delegate = self
        longPressRecognizer.delegate = self
        tapRecognizer.delegate = self
        meshWrapperView.addGestureRecognizer(panRecognizer)
        meshWrapperView.addGestureRecognizer(longPressRecognizer)
        imageWrapperView.addGestureRecognizer(tapRecognizer)
        //Load mesh
        if let virtualObjectScene = SCNScene(named: "art.scnassets/mesh.scn")
        {
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                wrapperNode.addChildNode(child)
            }
            
            testNode = wrapperNode
            scene.rootNode.addChildNode(wrapperNode)
            
        }
        else
        {
            return;
        }
        //setup image display
        updateDisplay()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
            let image =  UIImage(named: imgData[currentIndex])!
            let x = Int32((coord.x*image.size.width)/(imageWrapperView.frame.size.width))
            let y = Int32((coord.y*image.size.height)/(imageWrapperView.frame.size.height))
            
            print("Image dimension : x:\(image.size.width) , y:\(image.size.height)")
            print("Coord : x:\(coord.x) , y:\(coord.y)")
            print("Swift : x:\(x) , y:\(y)")
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
            }
        case nextArrow :
            if currentIndex < imgData.count
            {
                currentIndex+=1
            }
        default : break
        }
    }
    func updateDisplay()
    {
        //Coordinates
        let data = openCVRegistration.getCurrentVertex()!
        let originalImage = UIImage(named: imgData[currentIndex])
        
        pointsNode = openCVRegistration.scnNodeOf3DPoints()
        scene.rootNode.addChildNode(pointsNode)
        
        if openCVRegistration.isRegistrationFinished()
        {
            infoText.text = "Registration finished."
            imageDisplay.image = openCVRegistration.computePose(originalImage)
        }
        else
        {
            
            infoText.text = "Where is the point (\(data.getX()),\(data.getY()),\(data.getZ())) ?"
            print("Image dimension 2 : x:\(originalImage?.size.width) , y:\(originalImage?.size.height)")
            imageDisplay.image = openCVRegistration.add2DPoints(originalImage)
        }
        
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
            meshDisplay.backgroundColor = UIColor.clear
        default : break
        }
    }
    @objc func dragMesh(_ sender : UIPanGestureRecognizer)
    {
        if modeDrag
        {
            switch(sender.state)
            {
                
            case .began :
                meshWrapperView.layer.borderWidth = 4
                meshWrapperView.layer.borderColor = UIColorSet.darkBlue.cgColor
            case .changed :
                let coord = sender.location(in: self.view)
                meshWrapperView.center = coord
            case .ended :
                meshWrapperView.layer.borderWidth = 0
                meshWrapperView.layer.borderColor = UIColor.clear.cgColor
            default :
                break
            }
        }
        
    }
    
}


