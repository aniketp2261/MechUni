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
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
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
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        .lightContent
    }
    @IBAction func backBtnAction() {
        navigationController?.popViewController(animated: false)
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

//                {
//                           ticket_id:"TD-",
//                           car_pick_up_status:true || payment_done_status:true
//                }
                // api call
                messageLabel.text = metadataObj.stringValue
                let json = JSON(metadataObj.stringValue ?? "")
//                let Data = json[0] as! [String:Any]
//                for data1 in Data{
//                    var parkid = data1["_id"] as! Int
//                    let model = QrArrayData(_id: parkid)
//                    self.QRArray = model
//                }
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
//                AlertFunctions.showAlert(message: "MyDataDictionary888 \(json.dictionaryObject)")
//                let alert = UIAlertController(title: "METADATA--\(metadataObj)", message: "StringValue--\(metadataObj.stringValue ?? "")", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
//                    nextAlert()
//                }))
//                self.present(alert, animated: true, completion: nil)
//                func nextAlert(){
//                    var pid = "\(json["_id"].intValue)\(json["_id"].int8)\(json["_id"].int16)\(json["_id"].int32)\(json["_id"].int64)"
//
//                    var pid2 = "\(json[0].intValue)"
//                    var pid3 = "\(json[0].int)"
//                    if pid != nil && pid != "" && pid2 != nil && pid2 != ""{
//                        let alert = UIAlertController(title: "JSONDATA--\(json)", message: "ParkingID1--\(pid)\n ParkingID2--\(pid2)", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
//                            let mAlert = UIAlertController(title: "Data", message: "Mdata000 --- \(json[0].stringValue)\n type00-- \(json[1].stringValue)\n mData0009 --- \(json[0].numberValue) \n m8899 --- \(json[0])", preferredStyle: .alert)
//                            self.present(mAlert, animated: true, completion: nil)
//                        }))
//                        self.present(alert, animated: true, completion: nil)
//                    } else {
//                        let alert = UIAlertController(title: "JSONDATA--\(json)", message: "Error--\(json["_id"].error!)", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                        print(json["_id"].error!)
//                    }
//                }
//                if let QRData = metadataObj as? [String: Any]{
//                    let alert = UIAlertController(title: nil, message: "\(QRData)", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
//                        nextAlert()
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//
//                    func nextAlert(){
//                        let pid = String(QRData["_id"] as? Int ?? 0)
//                        let alert = UIAlertController(title: nil, message:  pid, preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
//                        }))
//                        self.present(alert, animated: true, completion: nil)
//                        if pid == id{
//                            updateCarPickupStatusToApi(ticketID: ticketId ?? "")
//                            self.navigationController?.popViewController(animated: false)
//                        }
//                        else{
//                            self.view.makeToast("Wrong Qr code Detected...")
//                        }
//                    }
//
//                }
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
