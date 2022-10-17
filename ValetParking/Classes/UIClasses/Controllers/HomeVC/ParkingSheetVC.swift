//
//  ParkingSheetVC.swift
//  ValetParking
//
//  Created by admin on 03/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SDWebImageWebPCoder

///Parking sheet delegate
protocol HomeVCDelegate {
    /// function is executed when the user taps on the tickets collectionview this is used to show the TicketDetailsVC
    func ticketTapped(ticket:GetTicketDataModel)
    /// function is excuted when the user taps on the nearby parking stations collection view to show
    func parkingStationTapped(nearbyModel:NearbyPlaceModel)
    /// function to navigate to search parking view controller
    func searchParkingAction()
    /// function to navigate to mechBrain view controller
    func mechBrainAction()
    /// function to navigate to insurance view controller
    func insuranceAction()
    /// function to navigate to services view controller
    func servicesAction()
    func ParkingClickAction()
    func nearbyServices(provider: NearbyServiceProviderModel)
    func myOrdersTapped(Order: OrderListModel)
    func parkingBtnAction(nearbyModel: NearbyPlaceModel)
    func ParkingPlaceAction(nearbyModel:NearbyPlaceModel)
}

struct NearbyPlaceModel{
    let image,parkingName,address,mobileNumber,startOpeningHours,typeOfVehicle:String
    let twoWheelerCost,fourWheelerCost,lat,long,placeId, twoWheelerAvailableParking:String
    let distance,fourWheelerAvailableParking,endOpeningHours:String
}
struct NearbyServiceProviderModel {
    let id, providerName,providerAddress,providerImage,providerMobile,providerEmail,providerStartTime,providerEndTime,providerLat,providerLong,providerDistance,providerTimetoReach,vehicleType : String
    let pickUpAval: Bool
    let workingDays: [String]
}
struct GetTicketDataModel{
    let id: String
    let carPickUpStatus, paymentDoneStatus: Bool
    let idParkingManagement: Int
    let ticketID, generatedOn: String
    let parkingName, parkingImage: String
    let generatedDate, address, plateNo, generatedTime: String
}
class ParkingSheetVC: UIViewController, UIAlertViewDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var nearbyParkingPlaceCollectionView:UICollectionView!
    @IBOutlet weak var ticketCollectionView:UICollectionView!
    @IBOutlet weak var nearbyServicesCollectionView: UICollectionView!
    @IBOutlet weak var nearbyServicesView: UIView!
    @IBOutlet weak var MyOrdersView: UIView!
    @IBOutlet weak var MyOrdersCollectionView: UICollectionView!
    @IBOutlet weak var TicketCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var nearbyServicesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MyOrdersViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tfSearch:UITextField!
    @IBOutlet weak var searchShadowView: ShadowView!
    @IBOutlet weak var HomeView: UIImageView!
    @IBOutlet weak var ParkingView: UIImageView!
    @IBOutlet weak var servicesView: UIImageView!
    @IBOutlet weak var MechbrainView: UIImageView!
    @IBOutlet weak var LocationView: UIImageView!
    
    //MARK: Colors
    let firstGradientColor = #colorLiteral(red: 0.6196078431, green: 0.3647058824, blue: 0.7019607843, alpha: 1)
    let secondGradientColor = #colorLiteral(red: 0.7490196078, green: 0.6572274161, blue: 0.8039215686, alpha: 1)
    
    //MARK: VARAIBLES
    var nearbyPlacesArray: [NearbyPlaceModel] = []
    var ticketArray: [GetTicketDataModel] = []
    var serviceArray: [NearbyServiceProviderModel] = []
    var OrderList: [OrderListModel] = []
    var OrderItms: [OrderItemsModel] = []
    public var navVC: UINavigationController? = nil
    
    //parking sheet vc delegate is to pass the data from ParkingSheetVC to HomeVC
    var HomeVCDelegate:HomeVCDelegate? = nil
    
    var CurrentDay: String?
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"
        nearbyParkingPlaceCollectionView.showsHorizontalScrollIndicator = false
        nearbyParkingPlaceCollectionView.register(UINib(nibName: "NearbyParkingPlaceCVC", bundle: nil), forCellWithReuseIdentifier: "NearbyParkingPlaceCVC")
        ticketCollectionView.register(UINib(nibName: "TicketsCVC", bundle: nil), forCellWithReuseIdentifier: "TicketsCVC")
        nearbyServicesCollectionView.register(UINib(nibName: "NearbyServicesCVC", bundle: nil), forCellWithReuseIdentifier: "NearbyServicesCVC")
        nearbyServicesCollectionView.delegate = self
        nearbyServicesCollectionView.dataSource = self
        MyOrdersCollectionView.register(UINib(nibName: "MyOrdersCVC", bundle: nil), forCellWithReuseIdentifier: "MyOrdersCVC")
        MyOrdersCollectionView.delegate = self
        MyOrdersCollectionView.dataSource = self
        nearbyParkingPlaceCollectionView.delegate = self
        nearbyParkingPlaceCollectionView.dataSource = self
        ticketCollectionView.delegate = self
        ticketCollectionView.dataSource = self
        searchShadowView.shadowCornerRadius = searchShadowView.bounds.height/2
        tfSearch.delegate = self
        HomeView.isUserInteractionEnabled = true
        HomeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeAction)))
        ParkingView.isUserInteractionEnabled = true
        ParkingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ParkingAction)))
        servicesView.isUserInteractionEnabled = true
        servicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(servicesAction)))
        MechbrainView.isUserInteractionEnabled = true
        MechbrainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mechbrainAction)))
        LocationView.isUserInteractionEnabled = true
        LocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchParkingAction)))
        let insTap = UITapGestureRecognizer(target: self, action: #selector(insuranceAction))
//        NotificationCenter.default.addObserver(self, selector: #selector(HomeAction), name: NSNotification.Name(rawValue: "HomeSelected"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ParkingAction), name: NSNotification.Name(rawValue: "ParkingSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationRefresh), name: NSNotification.Name(rawValue: "LocationRefresh"), object: nil)
    }
    @objc func searchParkingAction(){
        print("SearchParkingAction")
        for nearby in nearbyPlacesArray{
            HomeVCDelegate?.parkingBtnAction(nearbyModel: nearby)
            break
        }
    }
    @objc func HomeAction(){
        print("HomeAction")
//        nearbyServicesViewHeight.constant = 160
//        nearbyServicesView.isHidden = false
//        MyOrdersViewHeight.constant = 160
//        MyOrdersView.isHidden = false
//        HomeView.image = UIImage(named: "Home")
//        ParkingView.image = UIImage(named: "parking")?.withColor(.lightGray)
//        servicesView.image = UIImage(named: "Services")?.withColor(.lightGray)
//        MechbrainView.image = UIImage(named: "mechbrain")?.withColor(.lightGray)
//        LocationView.image = UIImage(named: "Map")?.withColor(.lightGray)
    }
    @objc func ParkingAction(){
        print("ParkingAction")
        HomeVCDelegate?.ParkingClickAction()
//        nearbyServicesViewHeight.constant = 0
//        nearbyServicesView.isHidden = true
//        MyOrdersViewHeight.constant = 0
//        MyOrdersView.isHidden = true
//        HomeView.image = UIImage(named: "Home")?.withColor(.lightGray)
//        ParkingView.image = UIImage(named: "parking")?.withColor(.red)
//        servicesView.image = UIImage(named: "Services")?.withColor(.lightGray)
//        MechbrainView.image = UIImage(named: "mechbrain")?.withColor(.lightGray)
//        LocationView.image = UIImage(named: "Map")?.withColor(.lightGray)
    }
    @objc func LocationRefresh(){
        APICalls()
    }
    @objc func servicesAction(){
        print("servicesAction")
        HomeVCDelegate?.servicesAction()
    }
    @objc func mechbrainAction(){
        print("mechbrainAction")
        HomeVCDelegate?.mechBrainAction()
    }
    @objc func insuranceAction(){
        print("insuranceAction")
        HomeVCDelegate?.insuranceAction()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICalls()
    }
    func APICalls(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eeee"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        CurrentDay = dayOfTheWeekString.lowercased()
        print("DayofWeek--- \(dayOfTheWeekString.lowercased())")
        getUserTickets()
        getOrderList()
        let CurrLat = UserDefaults.standard.string(forKey: "CurrentLat") ?? ""
        let CurrLong = UserDefaults.standard.string(forKey: "CurrentLong") ?? ""
        getNearbyPlaces(lat: CurrLat, lng: CurrLong,workingDay: self.CurrentDay ?? "")
        getNearbyServiceProviders(lat: CurrLat, lng: CurrLong, workingDay: self.CurrentDay ?? "")
    }
    func getUserTickets() {
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let ticketParams:[String:Any] = ["_id_customer_table": Int(userId) ?? 0,"latest_tickets":"latest_tickets"]
        print("ticketParams---\(ticketParams)")
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getTicketList,method: .post,parameters: ticketParams,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("getTicketListApiResponse---- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? Bool ?? false
                        if status {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            self.ticketArray.removeAll()
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let carPickUpStatus = result["car_pick_up_status"] as? Bool ?? false
                                let paymentDoneStatus = result["payment_done_status"] as? Bool ?? false
                                let idParkingManagement = result["id_parking_management"] as? Int ?? 0
                                let ticketId = result["ticket_id"] as? String ?? ""
                                let generatedOn = result["generated_on"] as? String ?? ""
                                let parkingName = result["parking_name"] as? String ?? ""
                                let parkingImg = result["parking_image"] as? String ?? ""
                                let generatedDate = result["generated_date"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let plateNo = result["plate_no"] as? String ?? ""
                                let generatedTime = result["generated_time"] as? String ?? ""
                                let model = GetTicketDataModel(id: id, carPickUpStatus: carPickUpStatus, paymentDoneStatus: paymentDoneStatus, idParkingManagement: idParkingManagement, ticketID: ticketId, generatedOn: generatedOn, parkingName: parkingName, parkingImage: parkingImg, generatedDate: generatedDate, address: address, plateNo: plateNo, generatedTime: generatedTime)
                                print("getParkingData0000 ---- \(model)")
                                self.ticketArray.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.ticketArray.count > 0 {
                                    self.TicketCollectionHeight.constant = 120
                                    self.ticketCollectionView.reloadData()
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.ticketCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                } else{
                                    self.TicketCollectionHeight.constant = 0
                                    self.ticketCollectionView.reloadData()
                                }
                            }
                        }
                    }
                case .failure(_):
                    print("getApiError ---- \(apiResponse.error?.localizedDescription ?? "")")
                }
            }
        }
    }
    func getNearbyPlaces(lat:String,lng:String,workingDay:String){
        let params:[String:Any] = ["lat":lat,"long":lng,"working_days":workingDay]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getPlacesNearby,method: .post,parameters: params,headers: nil).responseJSON { apiResponse in
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
                                let placeId = result["place_id"] as? Int ?? 0
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
                                let twoWheelerAvailableParking = result["two_wheeler_available_parking"] as? Int ?? 0
                                let fourWheelerAvailableParking = result["four_wheeler_available_parking"] as? Int ?? 0
                                let distance = result["distance"] as? String ?? ""
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: typeOfVehicle, twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: String(placeId), twoWheelerAvailableParking: String(twoWheelerAvailableParking), distance: distance, fourWheelerAvailableParking:String(fourWheelerAvailableParking), endOpeningHours: endOpeningHours)
                                print("TicketDetailmodel----- \(model)")
                                self.nearbyPlacesArray.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.nearbyPlacesArray.count > 0 {
                                    self.nearbyParkingPlaceCollectionView.reloadData()
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.nearbyParkingPlaceCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                } else{
                                    self.nearbyParkingPlaceCollectionView.reloadData()
                                }
                            }
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    func getNearbyServiceProviders(lat:String,lng:String,workingDay:String){
        var countData = 0
        print("getNearbyServiceProviders")
        let params:[String:Any] = ["lat":lat,"long":lng,"working_days":workingDay]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getNearbyServiceProviders,method: .post,parameters: params,headers: nil).responseJSON { apiResponse in
                print("NearbyServiceProviders-Response ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [[String:Any]] ?? []
                            print("NearbyServiceProviders--- \(results)")
                            countData = results.count
                            self.serviceArray.removeAll()
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let name = result["name"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let pickup = result["pickup_available"] as? Bool ?? false
                                let vehicleType = result["vehicle_type"] as? String ?? ""
                                let image = result["image"] as? String ?? ""
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
                                if countData == self.serviceArray.count {
                                    if self.serviceArray.count > 0 {
                                        self.nearbyServicesViewHeight.constant = 160
                                        self.nearbyServicesCollectionView.reloadData()
                                        let indexPath = IndexPath(row: 0, section: 0)
                                        self.nearbyServicesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                    } else{
                                        self.nearbyServicesViewHeight.constant = 40
                                        self.nearbyServicesCollectionView.reloadData()
                                    }
                                } else{
                                    self.nearbyServicesCollectionView.reloadData()
                                }
                            }
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    func getOrderList() {
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let ticketParams:[String:Any] = ["customer_id": Int(userId) ?? 0,"latest_orders":"latest_orders"]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.OrderList, method: .post, parameters: ticketParams, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("OrderListApiResponse--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["order_list"] as? [[String:Any]] ?? []
                            self.OrderList.removeAll()
                            self.OrderItms.removeAll()
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
                                for orderData in orderItems{
                                    let id = orderData["_id"] as? String ?? ""
                                    let providerServiceId = orderData["provider_service_id"] as? String ?? ""
                                    let providerId = orderData["provider_id"] as? String ?? ""
                                    let customerId = String(orderData["customer_id"] as? Int ?? 0)
                                    let serviceId = orderData["service_id"] as? String ?? ""
                                    let serviceName = orderData["service_name"] as? String ?? ""
                                    let serviceDescription = orderData["service_description"] as? String ?? ""
                                    let serviceCost = String(orderData["service_cost"] as? Int ?? 0)
                                    let requiredTime = String(orderData["required_time"] as? Int ?? 0)
                                    let serviceImage = orderData["service_images"] as? [String] ?? []
                                    let serviceStatus = orderData["service_status"] as? String ?? ""
                                    let model = OrderItemsModel(id: id, providerServiceId: providerServiceId, providerId: providerId, customerId: customerId, serviceId: serviceId, serviceName: serviceName, serviceDescription: serviceDescription, serviceCost: serviceCost, requiredTime: requiredTime, serviceStatus: serviceStatus, serviceImages: serviceImage)
                                    print("OrderItems---\(model)")
                                    self.OrderItms.append(model)
                                }
                                let model = OrderListModel(id: id, orderID: orderId, customerId: customerId, providerId: providerId, orderStatus: orderStatus, orderAmount: orderAmount, createdAt: createdAt, providerAddr: providerAddress, providerName: providerName, providerImage: providerImage, vehicleId: vehicleId, vehicleNo: vehicleNo, vehicleType: vehicleType, orderConfirm: orderConfirm, orderPickup: orderPickup, inprogress: inprogress, completed: completed, payment: payment)
                                print("OrderList---\(model)")
                                self.OrderList.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.OrderList.count > 0 {
                                    self.MyOrdersCollectionView.reloadData()
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.MyOrdersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                } else{
                                    self.MyOrdersCollectionView.reloadData()
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
extension ParkingSheetVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isLoggedin = UserDefaults.standard.string(forKey: "isLoggedin") ?? "0"
        if collectionView == nearbyParkingPlaceCollectionView{
            return nearbyPlacesArray.count
        } else if collectionView == ticketCollectionView{
            if(isLoggedin == "1"){
                return ticketArray.count
            } else{
                return 0
            }
        } else if collectionView == MyOrdersCollectionView{
            if(isLoggedin == "1"){
                print("OrdersCount --\(OrderList.count)")
                return OrderList.count
            } else{
                return 0
            }
        } else if collectionView == nearbyServicesCollectionView{
            return serviceArray.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nearbyParkingPlaceCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyParkingPlaceCVC", for: indexPath) as! NearbyParkingPlaceCVC
            cell.shadowView.layer.cornerRadius = 15
            cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowOpacity = 0.3
            cell.shadowView.layer.shadowColor = UIColor.black.cgColor
            cell.minuteAwayLbl.text = "Closes \(nearbyPlacesArray[indexPath.row].endOpeningHours)"
            cell.placeTitlLbl.text = nearbyPlacesArray[indexPath.row].parkingName
            cell.placeAddressLbl.text = nearbyPlacesArray[indexPath.row].address
            cell.DistanceLbl.text = "\(nearbyPlacesArray[indexPath.row].distance)"
            let CarHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            CarHrs.append(NSAttributedString(string: " \(nearbyPlacesArray[indexPath.row].fourWheelerCost)/hr", attributes: [.foregroundColor:UIColor.darkGray]))
            let BikeHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            BikeHrs.append(NSAttributedString(string: " \(nearbyPlacesArray[indexPath.row].twoWheelerCost)/hr", attributes: [.foregroundColor:UIColor.darkGray]))
            cell.CarPrice.attributedText = CarHrs
            cell.BikePrice.attributedText = BikeHrs
            if nearbyPlacesArray[indexPath.row].image != ""{
                let webPCoder = SDImageWebPCoder.shared
                SDImageCodersManager.shared.addCoder(webPCoder)
                let webpURL = URL(string: APIEndPoints.BASE_PARKING_URL + nearbyPlacesArray[indexPath.row].image)
                DispatchQueue.main.async {
                    cell.placeImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], completed: nil)
                }
            }
            if nearbyPlacesArray[indexPath.row].typeOfVehicle == "1"{
                cell.BikePrice.isHidden = false
                cell.bikeImg.isHidden = false
                cell.CarPrice.isHidden = true
                cell.carImg.isHidden = true
            } else if nearbyPlacesArray[indexPath.row].typeOfVehicle == "2"{
                cell.BikePrice.isHidden = true
                cell.bikeImg.isHidden = true
                cell.CarPrice.isHidden = false
                cell.carImg.isHidden = false
            } else {
                cell.BikePrice.isHidden = false
                cell.bikeImg.isHidden = false
                cell.CarPrice.isHidden = false
                cell.carImg.isHidden = false
            }
            return cell
        } else if collectionView == ticketCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketsCVC", for: indexPath) as! TicketsCVC
            cell.dateLbl.text = ticketArray[indexPath.row].generatedDate
            cell.plateNumberLbl.text = ticketArray[indexPath.row].plateNo
            cell.ticketIdLbl.text = "Ticket ID: \(ticketArray[indexPath.row].ticketID)"
            cell.timeLbl.text = ticketArray[indexPath.row].generatedTime
            return cell
        } else if collectionView == nearbyServicesCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyServicesCVC", for: indexPath) as! NearbyServicesCVC
            cell.ServiceNameLbl.text = serviceArray[indexPath.row].providerName
            cell.ServiceTimeLbl.text = "Closes "+serviceArray[indexPath.row].providerEndTime
            cell.ServiceAddressLbl.text = serviceArray[indexPath.row].providerAddress
            cell.DistanceLbl.text = serviceArray[indexPath.row].providerDistance
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL+serviceArray[indexPath.row].providerImage)
            DispatchQueue.main.async {
                cell.ServiceImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
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
            if serviceArray[indexPath.row].pickUpAval == true{
                cell.pickUpLbl.text = "Pickup Available"
            } else{
                cell.pickUpLbl.text = "Pickup Not Available"
            }
            return cell
        } else if collectionView == MyOrdersCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyOrdersCVC", for: indexPath) as! MyOrdersCVC
            cell.orderIdLbl.text = "Order ID: \(OrderList[indexPath.row].orderID)"
            cell.dateLbl.text = OrderList[indexPath.row].createdAt.convertToDate()
            cell.timeLbl.text = ""
            cell.plateNumberLbl.text = OrderList[indexPath.row].vehicleNo
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     if collectionView == nearbyParkingPlaceCollectionView{
        return CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
     } else if collectionView == ticketCollectionView{
         return CGSize(width: collectionView.bounds.width / 1.5, height: collectionView.bounds.height)
     } else if collectionView == nearbyServicesCollectionView{
        return CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
     } else{
        return CGSize(width: collectionView.bounds.width / 1.5, height: collectionView.bounds.height)
     }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == nearbyParkingPlaceCollectionView {
            if nearbyPlacesArray.count != 0{
                HomeVCDelegate?.ParkingPlaceAction(nearbyModel: nearbyPlacesArray[indexPath.row])
            }
        } else if collectionView == ticketCollectionView {
            if ticketArray.count != 0{
                HomeVCDelegate?.ticketTapped(ticket: ticketArray[indexPath.row])
            }
        } else if collectionView == nearbyServicesCollectionView {
            if serviceArray.count != 0{
                HomeVCDelegate?.nearbyServices(provider: serviceArray[indexPath.row])
            }
        } else {
            if OrderList.count != 0{
                HomeVCDelegate?.myOrdersTapped(Order: OrderList[indexPath.row])
            }
        }
    }
}

//MARK:- Gradient extension
extension UIView{
    func setHorizontalGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    func setVerticalGradientBackground(colorLeft: UIColor, colorRight: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft.cgColor, colorRight.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK:- TextField Delegate
extension ParkingSheetVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        HomeVCDelegate?.searchParkingAction()
        textField.resignFirstResponder()
    }
}
