//
//  QRCodeController.swift
//  LittleFarm
//
//  Created by saad on 11/07/2017.
//  Copyright © 2017 alain. All rights reserved.
//

import UIKit
import AVFoundation
import ARKit
import CoreMotion

class QRCodeViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var redPoint:UIButton!
    @IBOutlet var bluePoint:UIButton!
    @IBOutlet var goAR:UIButton!
    @IBOutlet var rotationLabel : UILabel!
    @IBOutlet var coordLabel : UILabel!
    
    var codeRectangle:CGRect?
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr]
    
    
    var motionManager = CMMotionManager()
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the pan gesture recognizer
        bluePoint.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(drag)))
        //Set the motion manager
        if(motionManager.isDeviceMotionAvailable)
        {
            motionManager.deviceMotionUpdateInterval=0.1;
            motionManager.startDeviceMotionUpdates()
            
        }
        else
        {
            print("Device motion is not available")
        }
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move to the front
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: goAR)
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                
                view.addSubview(redPoint)
                view.addSubview(bluePoint)
                bluePoint.center=CGPoint(x: 100, y: 100)
                
                view.bringSubview(toFront: redPoint)
                view.bringSubview(toFront: bluePoint)
                view.bringSubview(toFront: rotationLabel)
                view.bringSubview(toFront: coordLabel)
                
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
                
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //Create a timer for tilt tracking
        super.viewWillAppear(animated)
        timer=Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: (#selector(updateTilt)), userInfo: nil, repeats: true)
        
        //Display coordinates
        coordLabel.text="Size:[\(view.center.x),\(view.center.y)],Coord[\(bluePoint.center.x),\(bluePoint.center.y)]"
    }
    @objc func drag(sender : UIPanGestureRecognizer)
    {
        let step = sender.view!
        let coord = sender.location(in: self.view)
        step.center = coord
        //Display coordinates
        coordLabel.text="Size:[\(view.frame.size.height),\(view.frame.size.width)],Coord[\(bluePoint.center.x),\(bluePoint.center.y)]"
        
    }
    @objc func updateTilt()
    {
        
        if let motionData = motionManager.deviceMotion {
            let alphaX = motionData.gravity.x*180
            let alphaY = motionData.gravity.y*180
            let alphaZ = motionData.gravity.z*180
            rotationLabel.text="Rotation - x:" + String(format : "%.2f",alphaX) + ",y:" + String(format : "%.2f",alphaY) + ",z:" + String(format : "%.2f",alphaZ)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    func stopUpdateTilt()
    {
        timer.invalidate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR/barcode is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            qrCodeFrameView?.frame = barCodeObject!.bounds
            codeRectangle=barCodeObject!.bounds
            
            let rect = barCodeObject!.bounds
            
            let height = rect.height
            let width = rect.width
            let coord = rect.origin
            redPoint.center=(videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: coord))!
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue! + "[\(height),\(width)] x:\(rect.origin.x),y:\(rect.origin.y)"
            }
        }
        
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationView : UIViewController = segue.destination
        if destinationView is ViewController
        {
            let ARView : ViewController = destinationView as! ViewController
            ARView.isPositionGiven=true
            ARView.qrZone = codeRectangle!
        }
    }
    func calculatePosition(_ newRect: CGRect) -> CGRect
    {
        
        if let motionData = motionManager.deviceMotion {
            
            /*
            let alphaX = motionData.gravity.x*180
            let alphaY = motionData.gravity.y*180
            let alphaZ = motionData.gravity.z*180
            let newX = Float(sqrt(x*x+y*y))*sin(GLKMathDegreesToRadians(Float(alphaY)))
            let newY = Float(sqrt(x*x+y*y))*sin(GLKMathDegreesToRadians(Float(alphaY)))
             */
            //return SCNVector3(x,y,0)
        }
        
        return newRect
    }
}

