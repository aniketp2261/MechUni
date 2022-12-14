//
//  ScannerViewController.swift
//  ValetParking
//
//  Created by Sachin Patil on 12/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//
import AVFoundation
import UIKit
import Alamofire
import SwiftyJSON


struct QrArrayData: Codable {
    let _id: Int
    let image:String
    let parking_name:String
    let address:String
    let mobilenumber:String
    let lat,long:String
    let type_of_vehicle:String
}

class ScannerViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var ticketId:String? = nil
    var id:String? = nil
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topBar: UIView!
    @IBOutlet weak var ScanView: UIView!
    @IBOutlet weak var ReScanImg: UIImageView!

    var QRArray: [QrArrayData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        print("IDDDDD----\(id ?? "")")
        print("TicketIddddd----\(ticketId ?? "")")
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = ScanView.layer.bounds
            ScanView.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession.startRunning()
            
            // Move the message label and top bar to the front
            ScanView.bringSubviewToFront(messageLabel)
            ScanView.bringSubviewToFront(topBar)
            
            // Initialize QR Code Frame to highlight the QR Code
            qrCodeFrameView = UIView()
            
            if let qrcodeFrameView = qrCodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                qrcodeFrameView.layer.borderWidth = 2
                ScanView.addSubview(qrcodeFrameView)
                ScanView.bringSubviewToFront(qrcodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue anymore
            print(error)
            return
        }
        ReScanImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reScanAction)))
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        .lightContent
    }
    @IBAction func backBtnAction() {
        navigationController?.popViewController(animated: false)
    }
    @objc func reScanAction(){
        captureSession.startRunning()
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                captureSession.stopRunning()
                // api call
                messageLabel.text = metadataObj.stringValue
                let json = JSON(metadataObj.stringValue ?? "")
                if let mData = metadataObj.stringValue?.data(using: .utf8){
                    let myDataJson = try? JSONDecoder().decode(QrArrayData.self, from: mData)
                    if String(myDataJson?._id ?? 0) == id{
                         updateCarPickupStatusToApi(ticketID: ticketId ?? "")
                    }else{
                        AlertFunctions.showAlert(message: "", title: "Wrong QR Code Detected..", image: nil) {
                            self.navigationController?.popViewController(animated: true)
                        }
                        self.view.makeToast("Wrong QR Code Detected..")
                    }
                }
            }
        }
    }
}
//MARK: Api calls
extension ScannerViewController {
    /// function should be called when the user scans the code
    func updateCarPickupStatusToApi(ticketID:String){
        let params:[String:Any] = ["ticket_id":ticketID,"car_pick_up_status":true]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.updateVehiclePickupStatus, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                debugPrint("UpdateStatusResponse ---- \(apiResponse)")
                switch apiResponse.result {
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? String ?? ""
                        if status == "Success"{
                            let msg = apiDict["message"] as? String
                            self.view.makeToast(msg)
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CarPickUp"), object: nil, userInfo: nil)
                                UserDefaults.standard.setValue(ticketID,forKey: "TicketId")
                                self.navigationController?.popViewController(animated: false)
                            }
                        }
                    }
                case .failure(_):
                    self.view.makeToast(apiResponse.error?.localizedDescription)
                }
            }
        }
    }
}
