//
//  MechbrainVC.swift
//  ValetParking
//
//  Created by Apple on 09/04/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import SDWebImageWebPCoder

///Mechbrain sheet delegate
protocol MechbrainVCDelegate {
    /// function to navigate to Home view controller
    func MechbrainHomeClickAction()
    /// function to navigate to Parking view controller
    func MechbrainParkingClickAction()
    /// function to navigate to Services view controller
    func MechbrainServicesClickAction()
    /// function to navigate to Loaction view controller
    func MechbrainSearchPlaceClickAction(nearbyModel: NearbyPlaceModel)
    /// function to navigate to mechBrain view controller
    func MechbrainMechBrainAction()
    /// function to navigate to insurance view controller
    func MechbrainInsuranceAction()
    /// function to navigate to servicesCategory view controller
    func MechbrainOrdersClickAction(order: OrderListModel)
    func MechbrainServicesByCategory(Category: CategoriesModel)
    func MechbrainNearbyServicesClick(provider: NearbyServiceProviderModel)
    func MechbrainSearchListAction()
}
protocol MechbrainServicesCatVCDelegate{
    func MechbrainNavigationBack()
}

class MechbrainVC: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var nearbyServiceTV: UITableView!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var parkingView: UIView!
    @IBOutlet weak var parkingImg: UIImageView!
    @IBOutlet weak var mechbrainImg: UIImageView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var ServicesImg: UIImageView!
    @IBOutlet weak var locationImg: UIImageView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var searchShadowView: ShadowView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var OrdersCollectionView: UICollectionView!
    @IBOutlet weak var OrdersCVHeight: NSLayoutConstraint!
    @IBOutlet weak var ServicesBtn: UIButton!
    @IBOutlet weak var LocationBtn: UIButton!

    var MechbrainSheetVCDelegate: MechbrainVCDelegate? = nil
    var BackVCDelegate: DefaultDelegate? = nil
    var nearbyPlacesArray: [NearbyPlaceModel] = []
    var serviceArray: [NearbyServiceProviderModel] = []
    var categoryArray: [CategoriesModel] = []
    var OrderList: [OrderListModel] = []
    var CurrentDay = String()
    var ServicesRad = true
    var LocationRad = false
    let dateFormatter = DateFormatter()
    var isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSearch.delegate = self
        nearbyServiceTV.delegate = self
        nearbyServiceTV.dataSource = self
        nearbyServiceTV.rowHeight = UITableView.automaticDimension
        nearbyServiceTV.estimatedRowHeight = 50
        nearbyServiceTV.showsVerticalScrollIndicator = false
        nearbyServiceTV.register(UINib(nibName: "NearbyServicesTVC", bundle: nil), forCellReuseIdentifier: "NearbyServicesTVC")
        OrdersCollectionView.register(UINib(nibName: "MechBrainOrdersCVC", bundle: nil), forCellWithReuseIdentifier: "MechBrainOrdersCVC")
        OrdersCollectionView.delegate = self
        OrdersCollectionView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name("AppEnterForeground"), object: nil)
        DispatchQueue.main.async {
            let date = Date()
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "eeee"
            let dayOfTheWeekString = dateFormate.string(from: date)
            self.CurrentDay = dayOfTheWeekString.lowercased()
        }
        ViewsAndAction()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICALLS()
    }
    @objc func appMovedToForeground() {
        APICALLS()
    }
    func APICALLS(){
        getOrderList()
        ProviderAPI()
        getServicesCategories()
    }
    func ViewsAndAction(){
        searchShadowView.shadowCornerRadius = searchShadowView.bounds.height/2
        homeImg.image = UIImage(named: "Home")?.withColor(.lightGray)
        parkingImg.image = #imageLiteral(resourceName: "Gray_Parking")
        ServicesImg.image = #imageLiteral(resourceName: "Gray_Services").withColor(.lightGray)
        mechbrainImg.image = UIImage(named: "MechBrain-2")
        if #available(iOS 13.0, *) {
            locationImg.image = UIImage(systemName: "map")?.withTintColor(.lightGray)
        } else {
            locationImg.image = UIImage(named: "Map")?.withColor(.lightGray)
        }
        homeView.isUserInteractionEnabled = true
        homeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeAction)))
        parkingView.isUserInteractionEnabled = true
        parkingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ParkingAction)))
        servicesView.isUserInteractionEnabled = true
        servicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ServicesAction)))
        locationView.isUserInteractionEnabled = true
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchParkingAction)))
    
        ServicesBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ServicesListAction)))
        LocationBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoacationAction)))
        ServicesBtn.titleLabel?.lineBreakMode = .byWordWrapping
    }
    @objc func ServicesListAction(){
        ServicesRad = true
        LocationRad = false
        ServicesBtn.setImage(#imageLiteral(resourceName: "ic_red_radio_circleFill"), for: .normal)
        LocationBtn.setImage(#imageLiteral(resourceName: "ic_red_radio_circle"), for: .normal)
        getServicesCategories()
    }
    @objc func LoacationAction(){
        ServicesRad = false
        LocationRad = true
        ServicesBtn.setImage(#imageLiteral(resourceName: "ic_red_radio_circle"), for: .normal)
        LocationBtn.setImage(#imageLiteral(resourceName: "ic_red_radio_circleFill"), for: .normal)
        ProviderAPI()
    }
    func ProviderAPI(){
        let lat = UserDefaults.standard.string(forKey: "CurrentLat") ?? ""
        let lng = UserDefaults.standard.string(forKey: "CurrentLong") ?? ""
        self.getNearbyServices(lat: lat, lng: lng, workingDay: self.CurrentDay)
        self.getNearbyPlaces(lat: lat, lng: lng, workingDay: self.CurrentDay)
    }
    @objc func HomeAction(){
        print("HomeAction")
        MechbrainSheetVCDelegate?.MechbrainHomeClickAction()
    }
    @objc func searchParkingAction(){
        print("searchParkingAction2")
        for nearby in nearbyPlacesArray{
            MechbrainSheetVCDelegate?.MechbrainSearchPlaceClickAction(nearbyModel: nearby)
            break
        }
    }
    @objc func ParkingAction(){
        print("ParkingAction")
        MechbrainSheetVCDelegate?.MechbrainParkingClickAction()
    }
    @objc func ServicesAction(){
        print("ServicesAction")
        MechbrainSheetVCDelegate?.MechbrainServicesClickAction()
    }
    func SkipLoginPopUp(){
        let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
        alert.tag = 50
        alert.show()
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if alertView.tag == 50{
            print("EditProfileAlertButtonIndex---\(buttonIndex)")
            if buttonIndex == 1{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(myVC, animated: false)
            } else{
                alertView.dismiss(withClickedButtonIndex: 0, animated: true)
            }
        }
    }
    func getNearbyPlaces(lat:String,lng:String,workingDay:String){
        let params:[String:Any] = ["lat":lat,"long":lng,"working_days":workingDay]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getPlacesNearby, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("apiResponse ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            print("results0000--- \(results)")
                            self.nearbyPlacesArray.removeAll()
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
                                let placeId = String(result["place_id"] as? Int ?? 0)
                                let twoWheelerAvailableParking = result["two_wheeler_available_parking"] as? Int ?? 0
                                let fourWheelerAvailableParking = result["four_wheeler_available_parking"] as? Int ?? 0
                                let distance = result["distance"] as? String ?? ""
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: typeOfVehicle, twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: placeId, twoWheelerAvailableParking: String(twoWheelerAvailableParking), distance: distance, fourWheelerAvailableParking: String(fourWheelerAvailableParking), endOpeningHours: endOpeningHours)
                                print("TicketDetailmodel----- \(model)")
                                self.nearbyPlacesArray.append(model)
                            }
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
    func getNearbyServices(lat:String,lng:String,workingDay:String){
        let params:[String:Any] = ["lat":lat,"long":lng,"working_days":workingDay]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.mechbrainNearByServiceProvider, method: .post, parameters: params, encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("NearbyServiceProvidersResponse--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [[String:Any]] ?? []
                            print("NearbyServiceProviders--- \(results)")
                            self.serviceArray.removeAll()
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let name = result["name"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let image = result["image"] as? String ?? ""
                                let pickup = result["pickup_available"] as? Bool ?? false
                                let vehicleType = result["vehicle_type"] as? String ?? ""
                                let mobilenumber = result["mobilenumber"] as? String ?? ""
                                let email = result["email"] as? String ?? ""
                                let workingDays = result["working_days"] as? [String] ?? []
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let distance = result["distance"] as? String ?? ""
                                let timeToReach = result["time_to_reach"] as? String ?? ""
                        
                                let model = NearbyServiceProviderModel(id: id, providerName: name, providerAddress: address, providerImage: image, providerMobile: mobilenumber, providerEmail: email, providerStartTime: startOpeningHours, providerEndTime: endOpeningHours, providerLat: lat, providerLong: long, providerDistance: distance, providerTimetoReach: timeToReach, vehicleType: vehicleType, pickUpAval: pickup, workingDays: workingDays)
                                print("serviceArray--- \(model)")
                                self.serviceArray.append(model)
                            }
                            DispatchQueue.main.async {
                                self.nearbyServiceTV.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    func getServicesCategories(){
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            let params:[String: Any] = ["category_for":"mechbrain"]
            Alamofire.request(APIEndPoints.mechbrainGetCategories, method: .get, parameters: params, headers: nil).responseJSON { apiResponse in
                print("NearbyCategoriesapiResponse--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [[String:Any]] ?? []
                            print("getNearbyCategories--- \(results)")
                            self.categoryArray.removeAll()
                            for result in results{
                                let categoryActive = result["category_active"] as? Bool ?? false
                                let categoryType = String(result["category_type"] as? Int ?? 0)
                                let categoryTypeName = result["category_type_name"] as? String ?? ""
                                let _id = result["_id"] as? String ?? ""
                                let categoryName = result["category_name"] as? String ?? ""
                                let categoryImage = result["category_image"] as? String ?? ""
                                let __v = String(result["__v"] as? Int ?? 0)
                        
                                let model = CategoriesModel(categoryName: categoryName, categoryImage: categoryImage, categoryType: categoryType, categoryTypeName: categoryTypeName, id: _id, v: __v, categoryActive: categoryActive)
                                print("categoryArray--- \(model)")
                                self.categoryArray.append(model)
                            }
                            DispatchQueue.main.async {
                                self.nearbyServiceTV.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        }
    }
    func getOrderList() {
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let ticketParams:[String:Any] = ["customer_id": Int(userId) ?? 0]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.mechbrainOrderList, method: .post, parameters: ticketParams, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("OrderListApiResponse--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["order_list"] as? [[String:Any]] ?? []
                            self.OrderList.removeAll()
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let orderConfirm = result["order_confirm"] as? Bool ?? false
                                let orderPickup = result["order_pickup"] as? Bool ?? false
                                let inprogress = result["inprogress"] as? Bool ?? false
                                let completed = result["completed"] as? Bool ?? false
                                let payment = result["payment"] as? Bool ?? false
                                let orderId = result["order_id"] as? String ?? ""
                                let customerId = String(result["customer_id"] as? Int ?? 0)
                                let providerId = result["provider_id"] as? String ?? ""
                                let orderStatus = result["order_status"] as? String ?? ""
                                let orderAmount = String(result["order_amount"] as? Int ?? 0)
                                let createdAt = result["created_at"] as? String ?? ""
                                let providerAddress = result["provider_address"] as? String ?? " "
                                let providerName = result["provider_name"] as? String ?? " "
                                let providerImage = result["provider_image"] as? String ?? ""
                                let vehicleNo = result["vehicle_no"] as? String ?? ""
                                let vehicleId = String(result["vehicle_id"] as? Int ?? 0)
                                let vehicleType = result["vehicle_type"] as? String ?? ""
                                let orderItems = result["order_items"] as? [[String:Any]] ?? []
                                let model = OrderListModel(id: id, orderID: orderId, customerId: customerId, providerId: providerId, orderStatus: orderStatus, orderAmount: orderAmount, createdAt: createdAt, providerAddr: providerAddress, providerName: providerName, providerImage: providerImage, vehicleId: vehicleId, vehicleNo: vehicleNo, vehicleType: vehicleType, orderConfirm: orderConfirm, orderPickup: orderPickup, inprogress: inprogress, completed: completed, payment: payment)
                                print("OrderList---\(model)")
                                if(self.isLoggedin == true)
                                {
                                    self.OrderList.append(model)
                                }
                            }
                            DispatchQueue.main.async {
                                if self.OrderList.count > 0 {
                                    self.OrdersCVHeight.constant = 100
                                    self.OrdersCollectionView.reloadData()
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.OrdersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                } else{
                                    self.OrdersCVHeight.constant = 0
                                    self.OrdersCollectionView.reloadData()
                                }
                            }
                        }
                    }
                case .failure(_):
                    print("ApiError--- \(apiResponse.error?.localizedDescription ?? "")")
                }
            }
        }
    }
}

extension MechbrainVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ServicesRad == true{
            return categoryArray.count
        }else{
            return serviceArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if LocationRad == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyServicesTVC") as! NearbyServicesTVC
            cell.ServicesView.isHidden = false
            cell.CategoryView.isHidden = true
            cell.selectionStyle = .none
            cell.ServicesView.layer.cornerRadius = 15
            cell.ServicesView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.ServicesView.layer.shadowRadius = 3
            cell.ServicesView.layer.shadowOpacity = 0.3
            cell.ServicesView.layer.shadowColor = UIColor.black.cgColor
            cell.ServiceNameLbl.text = serviceArray[indexPath.row].providerName
            cell.ServiceTimeLbl.text = "Closes "+serviceArray[indexPath.row].providerEndTime
            cell.ServiceAddressLbl.text = serviceArray[indexPath.row].providerAddress
            cell.DistanceLbl.text = serviceArray[indexPath.row].providerDistance
            if serviceArray[indexPath.row].pickUpAval == true{
                cell.ServicePickUpLbl.text = "Pickup Available"
            } else{
                cell.ServicePickUpLbl.text = "Pickup Not Available"
            }
            if serviceArray[indexPath.row].vehicleType == "1"{
                cell.TwoWheelerImg.isHidden = false
                cell.FourWheelerImg.isHidden = true
            } else if serviceArray[indexPath.row].vehicleType == "2"{
                cell.TwoWheelerImg.isHidden = true
                cell.FourWheelerImg.isHidden = false
            } else{
                cell.TwoWheelerImg.isHidden = false
                cell.FourWheelerImg.isHidden = false
            }
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL+serviceArray[indexPath.row].providerImage)
            DispatchQueue.main.async {
                cell.ServiceImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
            }
            cell.TotalCostLbl.isHidden = true
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyServicesTVC") as! NearbyServicesTVC
            cell.ServicesView.isHidden = true
            cell.CategoryView.isHidden = false
            cell.selectionStyle = .none
            cell.ServiceCategoryName.text = categoryArray[indexPath.row].categoryName
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL+categoryArray[indexPath.row].categoryImage)
            DispatchQueue.main.async {
                cell.ServiceCategoryImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
            }
            if categoryArray[indexPath.row].categoryType == "1"{
                cell.TwoWheelerImg2.isHidden = false
                cell.FourWheelerImg2.isHidden = true
            } else if categoryArray[indexPath.row].categoryType == "2"{
                cell.TwoWheelerImg2.isHidden = true
                cell.FourWheelerImg2.isHidden = false
            } else{
                cell.TwoWheelerImg2.isHidden = false
                cell.FourWheelerImg2.isHidden = false
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LocationRad == true{
            if serviceArray.count != 0{
                MechbrainSheetVCDelegate?.MechbrainNearbyServicesClick(provider: serviceArray[indexPath.row])
            }
        } else{
            if categoryArray.count != 0{
                MechbrainSheetVCDelegate?.MechbrainServicesByCategory(Category: categoryArray[indexPath.row])
            }
        }
    }
}

//MARK:- CollectionView Delegate
extension MechbrainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OrderList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MechBrainOrdersCVC", for: indexPath) as! MechBrainOrdersCVC
        cell.orderIdLbl.text = "Order ID: \(OrderList[indexPath.row].orderID)"
        cell.dateLbl.text = OrderList[indexPath.row].createdAt.convertToDate()
        cell.timeLbl.text = ""
        cell.plateNumberLbl.text = OrderList[indexPath.row].vehicleNo
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 1.4, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MechbrainSheetVCDelegate?.MechbrainOrdersClickAction(order: OrderList[indexPath.row])
    }
}

// MARK:- TextField Delegate
extension MechbrainVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        MechbrainSheetVCDelegate?.MechbrainSearchListAction()
        textField.resignFirstResponder()
    }
}

