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
    
    let dataManager = PersistentDataManager.sharedInstance
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet weak var circularProgressView: KDCircularProgress!
    
    var nextController : controllerType = .nothing
    
    
    
    
    //Video capture variables
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    //QRCode capture
    var codeRectangle:CGRect?
    var QRCodeIsDetected : Bool = false
    var ARIsInstancied = false
    var RegisterIsInstancied = false
    var timerDetection = Timer()
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
    
    
    //Circular progress variables
    var maxCountDownValue  = 1.0
    var currentCountDownValue  = 0.0
    var timeInterval = 0.1
    var progressPerSecond = 1.0
    
    
    
    var motionManager = CMMotionManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the video capture
        setupVideoCapture()
        // Move to the front all subviews
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: circularProgressView)
        circularProgressView.isHidden = true
        ARIsInstancied = false
        
        
    }
    
    func setupVideoCapture()
    {
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
    
    func initiateARView()
    {
        let storyboard = UIStoryboard(name : "Main", bundle : nil)
        let ARView = storyboard.instantiateViewController(withIdentifier: "ARView") as! ARViewController
        ARView.qrZone = codeRectangle!
        ARView.qrCodeMode = true
        self.present(ARView, animated: true, completion: nil)
    }
    
    @objc func countDownForARView()
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
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            
            QRCodeNotDetected()
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            QRCodeDetected(metadataObj)
        }
        else
        {
            QRCodeNotDetected()
        }
        
        
    }
    func QRCodeDetected(_ metadataObj : AVMetadataMachineReadableCodeObject)
    {
        switch(nextController)
        {
        case .ARViewController :
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            codeRectangle=barCodeObject!.bounds
            
            self.QRCodeIsDetected=true
            
            //Start countdown
            if !timerDetection.isValid
            {
                //Display progress circle
                circularProgressView.isHidden=false
                timerDetection=Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: (#selector(countDownForARView)), userInfo: nil, repeats: true)
            }
            
            
            //Display message
            messageLabel.text = "Code : " + metadataObj.stringValue! + " a été détecté."
            
        case .RegisterViewController:
            let newKey = metadataObj.stringValue!
            //Check if the key is on the list
            if dataManager.isProductKeyValid(key: newKey) && !RegisterIsInstancied
            {
                let storyboard = UIStoryboard(name : "Main", bundle : nil)
                let registerView = storyboard.instantiateViewController(withIdentifier: "registerView") as! RegisterViewController
                registerView.productId = newKey
                self.present(registerView, animated: true, completion: nil)
                RegisterIsInstancied = true
            }
            else
            {
                messageLabel.text = "Le code n'est pas reconnu comme une boite LittleFarm :/"
            }
        default :
            break
        }
    }
    func QRCodeNotDetected()
    {
        switch(nextController)
        {
        case .ARViewController :
            qrCodeFrameView?.frame = CGRect.zero
            stopTimerDetection()
            resetProgress()
            return
        case .RegisterViewController: break
        default : break
        }
        messageLabel.text = "Pas de QRCode détecté."
    }
    
    
    //Countdown circle functions
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
    
    
    
}



