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
    @IBOutlet var goAR:UIButton!
    @IBOutlet weak var circularProgressView: KDCircularProgress!
    
    var codeRectangle:CGRect?
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    
    var QRCodeIsDetected : Bool = false
    var maxCountDownValue  = 3.0
    var currentCountDownValue  = 0.0
    var timeInterval = 0.1
    var progressPerSecond = 1.0
    var ARIsInstancied = false
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
    var timerDetection = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularProgressView.isHidden = true
        
        //QR Code initializer
        
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
            view.bringSubview(toFront: circularProgressView)
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
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
        ARIsInstancied = false
        circularProgressView.isHidden=true
        //timer=Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: (#selector(updateTilt)), userInfo: nil, repeats: true)
        
        
    }
    @objc func drag(sender : UIPanGestureRecognizer)
    {
        let step = sender.view!
        let coord = sender.location(in: self.view)
        step.center = coord
        
    }
    
    func initiateARView()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        let ARView = storyboard.instantiateViewController(withIdentifier: "ARView") as! ARViewController
        if let qrCode = codeRectangle
        {
            ARView.qrZone = qrCode
            ARView.QRDataVector=SCNVector3(0,0,0)
            ARView.QRDataVector.x = Float(qrCode.origin.x+qrCode.height/2)
            ARView.QRDataVector.y = Float(qrCode.origin.y+qrCode.width/2)
            ARView.QRDataVector.z = Float(qrCode.height+qrCode.width)/2
            print("Coordinates sended : \(ARView.QRDataVector)")
        }
        else
        {
            print("No QR zone detected.")
            ARView.QRDataVector=SCNVector3(0,0,-1)
            ARView.qrZone=CGRect.zero
        }
        self.navigationController?.show(ARView, sender: self)
    }
    /*
    @objc func updateTilt()
    {
        
        if let motionData = motionManager.deviceMotion {
            let alphaX = motionData.gravity.x*180
            let alphaY = motionData.gravity.y*180
            let alphaZ = motionData.gravity.z*180
            rotationLabel.text="Rotation - x:" + String(format : "%.2f",alphaX) + ",y:" + String(format : "%.2f",alphaY) + ",z:" + String(format : "%.2f",alphaZ)
        }
        
    }
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    @objc func displayCountDown()
    {
        if(currentCountDownValue >= maxCountDownValue && !ARIsInstancied)
        {
            stopTimerDetection()
            initiateARView()
            ARIsInstancied=true
        }
        else
        {
            increaseProgress(progressPerSecond*timeInterval)
        }
        
    }
    func stopTimerDetection()
    {
        timerDetection.invalidate()
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
            stopTimerDetection()
            resetProgress()
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
            
            self.QRCodeIsDetected=true
            
            //Start countdown
            if !timerDetection.isValid
            {
                //Display progress circle
                circularProgressView.isHidden=false
                timerDetection=Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: (#selector(displayCountDown)), userInfo: nil, repeats: true)
            }
            
            
            //Display message
            messageLabel.text = "Code : " + metadataObj.stringValue! + " is detected."
            
        }
        else
        {
            qrCodeFrameView?.frame = CGRect.zero
            stopTimerDetection()
            resetProgress()
            messageLabel.text = "Unreadable code"
            return
        }
        
        
    }
    func increaseProgress(_ step : Double) {
        if currentCountDownValue != maxCountDownValue {
            currentCountDownValue += step
            let newAngleValue = newAngle()
            circularProgressView.animate(toAngle: newAngleValue, duration: 0.5, completion: nil)
        }
    }
    func newAngle() -> Double {
        return 360 * (currentCountDownValue / maxCountDownValue)
    }
    func resetProgress() {
        currentCountDownValue = 0
        circularProgressView.animate(fromAngle: circularProgressView.angle, toAngle: 0, duration: 0.5, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationView : UIViewController = segue.destination
        if destinationView is ARViewController
        {
            let ARView : ARViewController = destinationView as! ARViewController
            ARView.isPositionGiven=true
            
            if let qrCode = codeRectangle
            {
                ARView.qrZone = qrCode
                ARView.QRDataVector=SCNVector3(0,0,0)
                ARView.QRDataVector.x = Float(qrCode.origin.x-qrCode.height/2)
                ARView.QRDataVector.y = Float(qrCode.origin.y-qrCode.width/2)
                ARView.QRDataVector.z = Float(qrCode.height+qrCode.width)/2
            }
            else
            {
                ARView.qrZone=CGRect.zero
            }
        }
    }
    
}

