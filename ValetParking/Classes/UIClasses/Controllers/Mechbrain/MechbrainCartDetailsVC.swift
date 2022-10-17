//
//  MechbrainCartDetailsVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 02/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SKActivityIndicatorView

struct MechbrainCartDetailsModel {
    let id, providerId, customerId, serviceId, serviceName, serviceDescription, serviceCost, requiredTime, serviceStatus, serviceType: String
    let pickupAvailable: Bool
    let serviceImages: [String]
}

class MechbrainCartDetailsVC: UIViewController {
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var MyCartLbl: UILabel!
    @IBOutlet weak var CartListTableView: UITableView!
    @IBOutlet weak var PayableAmtLbl: UILabel!
    @IBOutlet weak var LocationPickUpView: UIView!
    @IBOutlet weak var LocationPickUpHeight: NSLayoutConstraint!
    @IBOutlet weak var LocationPickUpLbl: UILabel!
    @IBOutlet weak var LocationBtn: UIButton!
    @IBOutlet weak var TotalAmountLbl: UILabel!
    @IBOutlet weak var PlaceOrderLbl: UILabel!
    @IBOutlet weak var Note: UITextField!
    @IBOutlet weak var selectVehicleBtn: UIButton!
    @IBOutlet weak var CartListTVHeight: NSLayoutConstraint!
    @IBOutlet weak var VehicleView: ShadowView!
    @IBOutlet weak var VehicleNoLbl: UILabel!
    @IBOutlet weak var VehicleImg: UIImageView!
    @IBOutlet weak var VehicleTypeImg: UIImageView!
    @IBOutlet weak var VehicleTypeLbl: UILabel!
    
    var CartList: [MechbrainCartDetailsModel] = []
    var nearbyModel: NearbyPlaceModel? = nil
    var CartDelegate: DefaultDelegate? = nil
    var providerID: String = ""
    var lat: String = ""
    var long: String = ""
    var PickupAdd: String = ""
    var isPickUp: Bool = false
    var pickedLoc: Bool = false
    var vehicleId: String = ""
    var vehicleType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        VehicleView.isHidden = true
        CartDetailsAPI()
        if self.isPickUp == false{
            let lat = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLat") ?? "") ?? 0.0
            let lng = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLong") ?? "") ?? 0.0
            self.lat = String(lat)
            self.long = String(lng)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(VehicleData(_:)), name: NSNotification.Name(rawValue: "ServiceVehicle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationAddressData(_:)), name: NSNotification.Name(rawValue: "LocationPicked"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationPickUpView.layer.borderColor = UIColor.gray.cgColor
        selectVehicleBtn.layer.borderWidth = 1
        selectVehicleBtn.layer.borderColor = UIColor.red.cgColor
        selectVehicleBtn.layer.cornerRadius = selectVehicleBtn.frame.height / 2
        CartListTableView.delegate = self
        CartListTableView.dataSource = self
        CartListTableView.separatorStyle = .none
        backImg.isUserInteractionEnabled = true
        backImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
        LocationPickUpLbl.isUserInteractionEnabled = true
        PlaceOrderLbl.isUserInteractionEnabled = true
        LocationPickUpLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocationPickAction)))
        LocationBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocationPickAction)))
        selectVehicleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectVehicleAction)))
        PlaceOrderLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlaceOrderAction)))
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: false)
        CartDelegate?.shouldNavBack()
    }
    @objc func LocationPickAction(){
        let storyboard = UIStoryboard(name: "Mechbrain", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MechbrainLocPickUpVC") as! MechbrainLocPickUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func selectVehicleAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
        vc.ServiceFlow = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func VehicleData(_ not: Notification){
        VehicleView.isHidden = false
        guard let obj = not.object as? [String:Any?] else {return}
        print("SelectedVehicleData---\(obj)")
        print("carId--\(obj["carId"] as? String ?? "")")
        self.vehicleId = obj["carId"] as? String ?? ""
        print("vehicleType--\(obj["vehicleType"] as? String ?? "")")
        print("plateNo--\(obj["plateNo"] as? String ?? "")")
        print("carImage--\(APIEndPoints.BASE_IMAGE_URL)\(obj["vehicleImage"] as? String ?? "")")
        VehicleNoLbl.text = obj["plateNo"] as? String ?? ""
        VehicleImg.sd_setImage(with: URL(string: "\(APIEndPoints.BASE_IMAGE_URL)\(obj["vehicleImage"] as? String ?? "")"), placeholderImage: #imageLiteral(resourceName: "mycars-1"), options: [], context: nil)
        vehicleType = obj["vehicleType"] as? String ?? ""
        if obj["vehicleType"] as? String ?? "" == "1"{
            self.VehicleTypeImg.image = #imageLiteral(resourceName: "icBikeGray")
            self.VehicleTypeLbl.text = "Two Wheeler"
        } else{
            self.VehicleTypeImg.image = #imageLiteral(resourceName: "icCarGray")
            self.VehicleTypeLbl.text = "Four Wheeler"
        }
    }
    @objc func LocationAddressData(_ not: Notification){
        pickedLoc = true
        guard let obj = not.object as? [String:Any?] else {return}
        print("SelectedLocationData---\(obj)")
        print("Address--\(obj["address"] as? String ?? "")")
        print("Latttt--\(obj["lat"] as? String ?? "")")
        print("Longgg--\(obj["long"] as? String ?? "")")
        self.PickupAdd = obj["address"] as? String ?? ""
        self.lat = obj["lat"] as? String ?? ""
        self.long = obj["long"] as? String ?? ""
        navigationController?.popViewController(animated: true)
        self.CartDelegate?.shouldNavBack()
        LocationBtn.setTitle(obj["address"] as? String ?? "", for: .normal)
    }
    @objc func PlaceOrderAction(){
        if self.vehicleId == ""{
            self.view.makeToast("Please Select Vehicle")
        } else{
            var abcd = 0
            for list in self.CartList{
                print("ServiceType--\(list.serviceType)")
                if list.serviceType == "3" || list.serviceType == "0"{
                    abcd = 0
                } else if list.serviceType != self.vehicleType{
                    abcd = 1
                    break
                }
            }
            if(abcd == 0){
                print("Place Order")
                self.PlaceOrderAPI()
            } else{
                self.view.makeToast("Service not available for this vehicle.Please select another vehicle")
            }
        }
    }
}
extension MechbrainCartDetailsVC : UITableViewDelegate, UITableViewDataSource{
    @objc func RemoveCart(_ sender: UITapGestureRecognizer){
        RemoveCartAPI(cartId: CartList[sender.view?.tag ?? 0].id)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartListTVC") as! CartListTVC
        cell.selectionStyle = .none
        cell.ServiceNameLbl.text = CartList[indexPath.row].serviceName
        cell.ServiceAmountLbl.text = "Rs.\(CartList[indexPath.row].serviceCost).0"
        cell.RemoveCartImg.tag = indexPath.row
        cell.RemoveCartImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RemoveCart(_:))))
        return cell
    }
}
extension MechbrainCartDetailsVC{
    func CartDetailsAPI(){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String: Any] = ["customer_id": Int(userId) ?? 0]
        print("CartDetailsParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainCartList, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("CartDetailsAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            self.CartList.removeAll()
                            let results = apiDict["response_data"] as? [String: Any]
                            print("CartDetailsResult--- \(results)")
                            if let result = results{
                                let totalAmount = String(result["total_amount"] as? Int ?? 0)
                                let count = String(result["cart_count"] as? Int ?? 0)
                                if count != "0"{
                                    self.MyCartLbl.text = "My Cart (\(count))"
                                    self.TotalAmountLbl.text = "Rs.\(totalAmount)"
                                    self.PayableAmtLbl.text = "Rs. \(totalAmount)"
                                    let cartList = result["cart_list"] as? [[String: Any]] ?? []
                                    for list in cartList{
                                        let id = list["_id"] as? String ?? ""
                                        let providerId = list["provider_id"] as? String ?? ""
                                        let customerId = String(list["customer_id"] as? Int ?? 0)
                                        let serviceId = list["service_id"] as? String ?? ""
                                        let serviceName = list["service_name"] as? String ?? ""
                                        let serviceDescription = list["service_description"] as? String ?? ""
                                        let serviceCost = String(list["service_cost"] as? Int ?? 0)
                                        let requiredTime = String(list["required_time"] as? Int ?? 0)
                                        let serviceImages = list["service_images"] as? [String] ?? []
                                        let pickupAvailable = list["pickupAvailable"] as? Bool ?? false
                                        let serviceStatus = list["service_status"] as? String ?? ""
                                        let serviceType = String(list["service_type"] as? Int ?? 0)
                                        let model = MechbrainCartDetailsModel(id: id, providerId: providerId, customerId: customerId, serviceId: serviceId, serviceName: serviceName, serviceDescription: serviceDescription, serviceCost: serviceCost, requiredTime: requiredTime, serviceStatus: serviceStatus, serviceType: serviceType, pickupAvailable: pickupAvailable, serviceImages: serviceImages)
                                        self.CartList.append(model)
                                    }
                                } else{
                                    self.navigationController?.popViewController(animated: true)
                                    self.CartDelegate?.shouldNavBack()
                                }
                            }
                            DispatchQueue.main.async {
                                self.CartListTableView.reloadData()
                                self.CartListTVHeight.constant = CGFloat(self.CartList.count) * 50
                                for list in self.CartList{
                                    self.providerID = list.providerId
                                    if list.pickupAvailable == true{
                                        self.isPickUp = true
                                        self.LocationPickUpView.isHidden = false
                                        self.LocationPickUpHeight.constant = 85
                                    } else{
                                        self.LocationPickUpView.isHidden = true
                                        self.LocationPickUpHeight.constant = 0
                                    }
                                }
                            }
                        } else{
                            SKActivityIndicator.dismiss()
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        } else{
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NetworkPopUpVC") as! NetworkPopUpVC
            self.addChild(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
        }
    }
    func RemoveCartAPI(cartId: String){
        let params:[String:Any] = ["cart_id":cartId]
        print("RemoveCartParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainRemoveCart, method: .delete, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("RemoveCartAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            self.view.makeToast(message)
                            DispatchQueue.main.async {
                                self.CartListTableView.reloadData()
                                self.CartDetailsAPI()
                            }
                        } else{
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        }
    }
    func PlaceOrderAPI(){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params : [String: Any]
        if self.pickedLoc == true{
            params = ["provider_id":self.providerID,"customer_id":Int(userId) ?? 0,"lat":Float(self.lat) ?? 0.0,"long":Float(self.long) ?? 0.0,"pickup_address":self.PickupAdd,"note":Note.text!,"is_pickup":true,"vehicle_id":Int(self.vehicleId) ?? 0]
        } else{
            params = ["provider_id":self.providerID,"customer_id":Int(userId) ?? 0,"is_pickup":false,"note":Note.text!,"vehicle_id":Int(self.vehicleId) ?? 0]
        }
        print("PlaceOrderParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainPlaceOrder, method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("PlaceOrderAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            if message == "nomobilenumber"{
                                let storyboard = UIStoryboard(name: "Mechbrain", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "AddMobileNoVC") as! AddMobileNoVC
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: false, completion: nil)
                            } else{
                                let odID = apiDict["order_id"] as? String ?? ""
                                self.view.makeToast(message)
                                let storyboard = UIStoryboard(name: "Mechbrain", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "MechbrainOrderSuccessfulVC") as! MechbrainOrderSuccessfulVC
                                vc.OrderID = odID
                                UserDefaults.standard.setValue(odID, forKey: "OrderID")
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else{
                            SKActivityIndicator.dismiss()
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        }
    }
}
