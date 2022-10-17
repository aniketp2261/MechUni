
//
//  ConfirmAndParkVC.swift
//  ValetParking
//
//  Created by admin on 10/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

protocol ConfirmAndParkVCDelegate {
    func onTicketCreated()
}

class ConfirmAndParkVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var confirmAndParkBtn:UIButton!
    @IBOutlet weak var parkingNameLbl:UILabel!
    @IBOutlet weak var parkingLocationLbl:UILabel!
    @IBOutlet weak var parkingChargesLbl:UILabel!
    @IBOutlet weak var parkingImgView:UIImageView!
    @IBOutlet weak var plateNoLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var bottomSheetView:UIView!
    @IBOutlet weak var crossBtnImg:UIImageView!
    
    var confirmAndParkDelegate:ConfirmAndParkVCDelegate? = nil
    
    var nearbyPostModel:NearbyPlaceModel? = nil
    var carId:String? = nil
    var vehicleType:String? = nil
    var plateNo:String? = nil
    var img:UIImage? = nil
    let dateFormatter = DateFormatter()
    var someDateTime = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if vehicleType == "1"{
            parkingChargesLbl.text = nearbyPostModel?.twoWheelerCost
        } else {
            parkingChargesLbl.text = nearbyPostModel?.fourWheelerCost
        }
        parkingImgView.image = img
        dateFormatter.dateFormat = "yyyy-MM-dd"
        parkingNameLbl.text = nearbyPostModel?.parkingName
        parkingLocationLbl.text = nearbyPostModel?.address
        plateNoLbl.text = plateNo
        
        dateLbl.text = dateFormatter.string(from: Date())
        confirmAndParkBtn.addBorder(color: .red)
        confirmAndParkBtn.layer.cornerRadius = confirmAndParkBtn.bounds.height/2
        parkingImgView.layer.cornerRadius = 8
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        bottomSheetView.layer.cornerRadius = 30
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(exitGesture))
        view.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exitGesture))
        crossBtnImg.addGestureRecognizer(tapGesture)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        someDateTime = formatter.string(from: date)
        print("someDateTime ---- \(someDateTime)")
    }
    @objc func exitGesture(){
        dismiss(animated: true, completion: nil)
    }
    // MARK: IBActions
    @IBAction func confirmAndParkAction(){
        if let requestModel = nearbyPostModel {
            let params:[String:Any] = [
                "id_parking_management": requestModel.placeId,
                "_id_car_details": carId ?? "",
                "current_time": someDateTime,
                "_id_customer_table": UserDefaults.standard.string(forKey: "userID") ?? ""
            ]
            print("createTicketParams000---- \(params)")
            if Connectivity.isConnectedToInternet
            {
                Alamofire.request(APIEndPoints.createTicket, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                    debugPrint("apiResponse000000 ---- \(apiResponse)")
                    switch apiResponse.result{
                    case .success(_):
                       if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? Int ?? 0
                        if status == 0 {
                            let msg = apiDict["message"] as? String ?? ""
                            AlertFunctions.showAlert(message: "",title: "\(msg)") {
                            }
                        }
                        else{
                            self.dismiss(animated: true) {
                                AlertFunctions.showAlert(message: "", title: "Your Vehicle \(self.plateNo ?? "") is Parked."){
                                    self.confirmAndParkDelegate?.onTicketCreated()
                                }
                            }
                        }
                        print("apiDict000 --- \(apiDict)")
                    }
                    case .failure(_):
                        print("error00000 --- \(apiResponse.error!.localizedDescription)")
                    }
                }
            } else{
                NetworkPopUpVC.sharedInstance.Popup(vc: self)
            }
        }
    }
}
