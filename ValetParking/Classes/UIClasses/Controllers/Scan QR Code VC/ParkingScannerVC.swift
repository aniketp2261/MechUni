//
//  ParkingScannerVC.swift
//  ValetParking
//
//  Created by admin on 26/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//
import AVFoundation
import UIKit
import Alamofire
import FloatingPanel

class ParkingScannerVC: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var PlaceByIDArray:[NearbyPlaceModel] = []
    var captureStatus : Bool = false
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


    var fpc = FloatingPanelController()
    var QRArray: [QrArrayData] = []
    var SearchPlaceVc = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
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
    private func showBottomSheet(model:NearbyPlaceModel){
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 30
        let vc = storyboard?.instantiateViewController(withIdentifier: "ParkingPlaceVC") as! ParkingPlaceVC
        fpc.delegate = self
        fpc.contentViewController = vc
        vc.parkingPlaceDelegate = self
        vc.nearbyPlaceModel = model
        fpc.isRemovalInteractionEnabled = true
       // fpc.move(to: .full, animated: true)
        
        self.present(fpc, animated: true, completion: nil)
        fpc.surfaceView.appearance = appearance
    }
    @IBAction func backBtnAction() {
        if SearchPlaceVc == false{
            navigationController?.popViewController(animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.scannerToHomeScreen.rawValue), object: false)
        } else{
            navigationController?.popViewController(animated: false)
        }
    }
}

extension ParkingScannerVC: AVCaptureMetadataOutputObjectsDelegate {
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
                messageLabel.text = metadataObj.stringValue

                if let mData = metadataObj.stringValue?.data(using: .utf8){
                    let myDataJson = try? JSONDecoder().decode(QrArrayData.self, from: mData)
                    if myDataJson?._id != 0{
                        getPlaceByID(id: myDataJson?._id ?? 0)
                    }else{
                        AlertFunctions.showAlert(message: "", title: "Wrong QR Code Detected..", image: nil){
                            if self.SearchPlaceVc == false{
                                self.navigationController?.popViewController(animated: false)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.scannerToHomeScreen.rawValue), object: false)
                            } else{
                                self.navigationController?.popViewController(animated: false)
                            }
                        }
                        self.view.makeToast("Wrong QR Code Detected..")
                    }
                }
            }
        }
    }
}
extension ParkingScannerVC: ParkingPlaceVCDelegate {
   func sliderReachedToEnd(model: NearbyPlaceModel?) {
       let vc = storyboard?.instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
       vc.nearbyModel = model
        vc.myCarsDelegate = self
       navigationController?.pushViewController(vc, animated: true)
   }
}
extension ParkingScannerVC: DefaultDelegate{
    func shouldNavBack() {
        
    }
}
extension ParkingScannerVC: FloatingPanelControllerDelegate{
    
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        print("WIll Remove")
        tabBarController?.tabBar.isHidden = false
    }
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        print("ParkingScannerVC state0000 ---- \(fpc.state)")
        if fpc.state == .tip {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            if self.SearchPlaceVc == false{
                self.navigationController?.popViewController(animated: false)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.scannerToHomeScreen.rawValue), object: false)
            } else{
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    func getPlaceByID(id:Int){
        let params:[String:Any] = ["_id":id]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.BaseURL+"customer_table/find_parkingplaces_by_id",method: .post,parameters: params,headers: nil).responseJSON { apiResponse in
                print("getPlaceByIDapiResponse ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            print("getPlaceByIDResults--- \(results)")
                            self.PlaceByIDArray.removeAll()
                            for result in results{
                                let img = result["image"] as? String ?? ""
                                let parkingName = result["parking_name"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let mobileNumber = result["mobilenumber"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let typeOfVehicle = String(result["type_of_vehicle"] as? Int ?? 0)
                                let twoWheelerCost = result["two_wp_cost"] as? Int ?? 0
                                let fourWheelerCost = result["four_wp_cost"] as? Int ?? 0
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let placeId = String(result["_id"] as? Int ?? 0)
                                let twoWheelerAvailableParking = result["two_wheeler_available_parking"] as? Int ?? 0
                                let fourWheelerAvailableParking = result["four_wheeler_available_parking"] as? Int ?? 0
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: typeOfVehicle, twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: placeId, twoWheelerAvailableParking: String(twoWheelerAvailableParking), distance: "",fourWheelerAvailableParking: String(fourWheelerAvailableParking), endOpeningHours: endOpeningHours)
                                print("PlaceByIdmodel----- \(model)")
                                self.PlaceByIDArray.append(model)
                                break
                            }
                            DispatchQueue.main.async {
                                for placeByIdArr in self.PlaceByIDArray{
                                    self.showBottomSheet(model: placeByIdArr)
                                    break
                                }
                            }
                        }
                    }
                case .failure(_):
                    AlertFunctions.showAlert(message: "ApiError....") {
                    }
                    print("failure")
                }
            }
        }
    }
}


