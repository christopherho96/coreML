//
//  ViewController.swift
//  coreMLbeta
//
//  Created by Christopher Ho on 2017-07-22.
//  Copyright © 2017 chovo. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //load up the camera
        let captureSession = AVCaptureSession()
        
        //gives a preset crop of the view of the camera view
        captureSession.sessionPreset = .photo
        
        // type .video gives the back view of an iphone camera
        //guard unwrap is essential the if/else statement for unwrapping
        //so if it doesnt work, then just return nothing
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        // the try? accounts for if your device does not have a camera
        // the try is shortened version of do/catch block
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        //opens camera view onto frame of iphone view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        //monitor frame data of video
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
        captureSession.addOutput(dataOutput)
        
        //use of vision
        
        // let request = VNCoreMLRequest(model: <#T##VNCoreMLModel#>, completionHandler: <#T##VNRequestCompletionHandler?##VNRequestCompletionHandler?##(VNRequest, Error?) -> Void#>)
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>).perform(requests: [VNRequest])
    }
    
    //built in function that runs everytime camera captures a frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera captured frame:", Date())
        
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        //add question mark to try to avoid doing a full try/catch block
        guard let model = try? VNCoreMLModel(for:Resnet50().model) else {return}
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, err) in
        //check the error
         // print(finishedRequest.results)
        // put results of what the camera sees in an array
            guard let results = finishedRequest.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else
            {return}
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
    
}
