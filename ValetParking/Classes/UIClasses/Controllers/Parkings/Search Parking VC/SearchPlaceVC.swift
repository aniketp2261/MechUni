//
//  SearchPlaceVC.swift
//  MechUni
//
//  Created by Sachin Patil on 26/04/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import FloatingPanel


protocol SearchPlaceDelegate{
    func naviBack()
}
class SearchPlaceVC: UIViewController, GMSMapViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var SearchTF: UITextField!
    @IBOutlet weak var ParkingNameView: UIView!
    @IBOutlet weak var ProviderNameView: UIView!
    @IBOutlet weak var ParkingCollectionView: UICollectionView!
    @IBOutlet weak var ServiceCollectionView: UICollectionView!
    
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var carBtn: UIButton!
    @IBOutlet weak var bikeBtn: UIButton!
    @IBOutlet weak var relocateBtn: UIButton!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var cartBtn: UIButton!
    @IBOutlet weak var CallBtn: UIButton!
    @IBOutlet weak var carBtnShadowView: ShadowView!
    @IBOutlet weak var bikeBtnShadowView: ShadowView!
    @IBOutlet weak var scanBtnShadowView: ShadowView!
    @IBOutlet weak var relocateBtnShadowView: ShadowView!
    @IBOutlet weak var cartView: ShadowView!
    @IBOutlet weak var callShadowView: ShadowView!
    
    var nearbyPlacesArray: [NearbyPlaceModel] = []
    var serviceProviderArray: [NearbyServiceProviderModel] = []
    var searchDelegate: SearchPlaceDelegate? = nil
    let fpc = FloatingPanelController()
    var isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
    var CurrentDay = String()
    var custCareNo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        MapView.bringSubviewToFront(SearchView)
        MapView.bringSubviewToFront(StackView)
        MapView.bringSubviewToFront(ParkingCollectionView)
        MapView.bringSubviewToFront(ParkingNameView)
        MapView.bringSubviewToFront(ProviderNameView)
        MapView.bringSubviewToFront(ServiceCollectionView)
        bikeBtn.layer.cornerRadius = bikeBtn.bounds.height/2
        carBtn.layer.cornerRadius = carBtn.bounds.height/2
        relocateBtn.layer.cornerRadius = relocateBtn.bounds.height/2
        scanBtn.layer.cornerRadius = scanBtn.bounds.height/2
        cartBtn.layer.cornerRadius = cartBtn.bounds.height/2
        CallBtn.layer.cornerRadius = CallBtn.bounds.height/2
        cartView.shadowCornerRadius = cartView.bounds.height/2
        carBtnShadowView.shadowCornerRadius = carBtnShadowView.bounds.height/2
        bikeBtnShadowView.shadowCornerRadius = bikeBtnShadowView.bounds.height/2
        scanBtnShadowView.shadowCornerRadius = scanBtnShadowView.bounds.height/2
        relocateBtnShadowView.shadowCornerRadius = relocateBtnShadowView.bounds.height/2
        callShadowView.shadowCornerRadius = callShadowView.bounds.height/2
        ParkingCollectionView.delegate = self
        ParkingCollectionView.dataSource = self
        ServiceCollectionView.showsHorizontalScrollIndicator = false
        ServiceCollectionView.delegate = self
        ServiceCollectionView.dataSource = self
        ServiceCollectionView.showsHorizontalScrollIndicator = false
        CallBtn.addTarget(self, action: #selector(callAction), for: .touchUpInside)
        ParkingCollectionView.register(UINib(nibName: "NearbyParkingPlaceCVC", bundle: nil), forCellWithReuseIdentifier: "NearbyParkingPlaceCVC")
        ServiceCollectionView.register(UINib(nibName: "NearbyServicesCVC", bundle: nil), forCellWithReuseIdentifier: "NearbyServicesCVC")
        DisplayView()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eeee"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        CurrentDay = dayOfTheWeekString.lowercased()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fpc.dismiss(animated: true, completion: nil)
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
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(myVC, animated: false)
            } else{
                alertView.dismiss(withClickedButtonIndex: 0, animated: true)
            }
        }
    }
    func DisplayView(){
        DispatchQueue.main.async {
            let lat = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLat") ?? "") ?? 0.0
            let lng = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLong") ?? "") ?? 0.0
            let cameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14)
            self.MapView.animate(to: cameraPosition)
            self.getNearbyParkingStations(lat: String(lat), lng: String(lng), workingDays: self.CurrentDay)
            self.getNearbyServiceProviders(lat: "\(lat)", lng: "\(lng)", workingDay: self.CurrentDay)
            self.GetCustCareAPI()
        }
    }
    private func showBottomSheet(model:NearbyPlaceModel){
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 30
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParkingPlaceVC") as! ParkingPlaceVC
        fpc.delegate = self
        fpc.contentViewController = vc
        vc.parkingPlaceDelegate = self
        vc.nearbyPlaceModel = model
        fpc.isRemovalInteractionEnabled = true
        self.present(fpc, animated: true, completion: nil)
        fpc.surfaceView.appearance = appearance
    }
    @IBAction func textFieldTapped(_ sender: Any) {
        SearchTF.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    @IBAction func BackAction(_ sender: UIButton){
        print("BackActionBackAction")
        SearchTF.text = ""
        navigationController?.popViewController(animated: false)
        searchDelegate?.naviBack()
    }
//    StackView Buttons
    @IBAction func carButtonAction(){
        carBtn.isSelected = !(carBtn.isSelected)
        if carBtn.isSelected {
            let image = UIImage(named: "icCarGray")?.withRenderingMode(.alwaysTemplate)
            carBtn.setImage(image, for: .normal)
            carBtn.tintColor = UIColor.red
            bikeBtn.setImage(UIImage(named: "icBikeGray"), for: .normal)
            self.MapView.clear()
            for station in nearbyPlacesArray{
                if station.typeOfVehicle == "2" {
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName,iconStr: "parking_4Wheeler", height: 40)
                } else if station.typeOfVehicle == "3" {
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
            for service in serviceProviderArray{
                if service.vehicleType == "2" {
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "SErvice_4Wheeler", height: 40)
                } else if service.vehicleType == "3"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "ServicesMarker", height: 40)
                }
            }
        } else{
            let image = UIImage(named: "icCarGray")
            carBtn.setImage(image, for: .normal)
            self.MapView.clear()
            for station in nearbyPlacesArray{
                if station.typeOfVehicle == "1"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_2Wheeler", height: 40)
                } else if station.typeOfVehicle == "2"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_4Wheeler", height: 40)
                } else{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
            for service in serviceProviderArray{
                if service.vehicleType == "1"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "SErvice_2Wheeler", height: 40)
                } else if service.vehicleType == "2"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "SErvice_4Wheeler", height: 40)
                } else{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "ServicesMarker", height: 40)
                }
            }
        }
    }
    @IBAction func bikeButtonAction(){
        bikeBtn.isSelected = !(bikeBtn.isSelected)
        if bikeBtn.isSelected {
            let image = UIImage(named: "icBikeGray")?.withRenderingMode(.alwaysTemplate)
            bikeBtn.setImage(image, for: .normal)
            bikeBtn.tintColor = UIColor.red
            carBtn.setImage(UIImage(named: "icCarGray"), for: .normal)
            self.MapView.clear()
            for station in nearbyPlacesArray{
                print("station.typeOfVehicle000----- \(station.typeOfVehicle)")
                if station.typeOfVehicle == "1"{
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName,iconStr: "parking_2Wheeler", height: 40)
                } else if station.typeOfVehicle == "3" {
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
            for service in serviceProviderArray{
                if service.vehicleType == "1"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "SErvice_2Wheeler", height: 40)
                } else if service.vehicleType == "3"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "ServicesMarker", height: 40)
                }
            }
        } else{
            let image = UIImage(named: "icBikeGray")
            bikeBtn.setImage(image, for: .normal)
            self.MapView.clear()
            for station in nearbyPlacesArray {
                if station.typeOfVehicle == "1"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_2Wheeler", height: 40)
                } else if station.typeOfVehicle == "2"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_4Wheeler", height: 40)
                } else{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
            for service in serviceProviderArray{
                if service.vehicleType == "1"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "SErvice_2Wheeler", height: 40)
                } else if service.vehicleType == "2"{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "SErvice_4Wheeler", height: 40)
                } else{
                    self.markStationsOnMapView(lat: Double(service.providerLat) ?? 0.0, lng: Double(service.providerLong) ?? 0.0, stationName: service.providerName ,iconStr: "ServicesMarker", height: 40)
                }
            }
        }
    }
    @IBAction func relocateAction(){
        DispatchQueue.main.async {
            let lat = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLat") ?? "") ?? 0.0
            let lng = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLong") ?? "") ?? 0.0
            let cameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14)
            self.MapView.animate(to: cameraPosition)
        }
    }
    @IBAction func scannerButtonAction(){
        if(self.isLoggedin == true) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParkingScannerVC") as! ParkingScannerVC
            vc.SearchPlaceVc = true
            self.navigationController?.pushViewController(vc, animated: false)
        } else{
            self.SkipLoginPopUp()
        }
    }
    @IBAction func CartAction(){
        CartCountAPI()
    }
    @objc func callAction(){
        self.callNumber(phoneNumber: self.custCareNo)
    }
    private func callNumber(phoneNumber:String) {
        print("Calling......\(phoneNumber)")
        let url:NSURL = NSURL(string: "tel://\(phoneNumber)")!
        UIApplication.shared.canOpenURL(url as URL)
        if #available(iOS 12, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler:nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    func getNearbyParkingStations(lat:String,lng:String,workingDays:String){
        let params:[String:Any] = ["lat":lat,"long":lng,"working_days":workingDays,"parking_status":true]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getPlacesNearby,method: .post,parameters: params,headers: nil).responseJSON { apiResponse in
                print("apiResponse ----- \(apiResponse)")
                self.nearbyPlacesArray.removeAll()
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            print("results0000--- \(results)")
                            for result in results{
                                let img = result["image"] as? String ?? ""
                                let parkingName = result["parking_name"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let mobileNumber = result["mobilenumber"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let typeOfVehicle = result["type_of_vehicle"] as? Int ?? 0
                                let twoWheelerCost = result["two_wp_cost"] as? Int ?? 0
                                let fourWheelerCost = result["four_wp_cost"] as? Int ?? 0
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let placeId = String(result["place_id"] as? Int ?? 0)
                                let twoWheelerAvailableParking = String(result["two_wheeler_available_parking"] as? Int ?? 0)
                                let fourWheelerAvailableParking = String(result["four_wheeler_available_parking"] as? Int ?? 0)
                                let distance = result["distance"] as? String ?? ""
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: String(typeOfVehicle), twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: placeId, twoWheelerAvailableParking: twoWheelerAvailableParking, distance: distance,fourWheelerAvailableParking:fourWheelerAvailableParking, endOpeningHours: endOpeningHours)
                                print("model000001----- \(model)")
                                if model.typeOfVehicle == "1"{
                                    self.markStationsOnMapView(lat: Double(model.lat) ?? 0.0, lng: Double(model.long) ?? 0.0, stationName: model.parkingName, iconStr: "parking_2Wheeler", height: 40)
                                } else if model.typeOfVehicle == "2"{
                                    self.markStationsOnMapView(lat: Double(model.lat) ?? 0.0, lng: Double(model.long) ?? 0.0, stationName: model.parkingName, iconStr: "parking_4Wheeler", height: 40)
                                } else{
                                    self.markStationsOnMapView(lat: Double(model.lat) ?? 0.0, lng: Double(model.long) ?? 0.0, stationName: model.parkingName, iconStr: "parkingboth", height: 40)
                                }
                                self.nearbyPlacesArray.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.nearbyPlacesArray.count == 0{
                                    AlertFunctions.showAlert(message: "",title: "Parking Not Available") {
                                    }
                                }
                                self.ParkingCollectionView.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    self.view.makeToast("Failure..")
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
    func getNearbyServiceProviders(lat:String,lng:String,workingDay:String){
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
                            self.serviceProviderArray.removeAll()
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
                                self.serviceProviderArray.append(model)
                                DispatchQueue.main.async {
                                    if model.vehicleType == "1"{
                                        self.markStationsOnMapView(lat: Double(model.providerLat) ?? 0.0, lng: Double(model.providerLong) ?? 0.0, stationName: model.providerName ,iconStr: "SErvice_2Wheeler", height: 40)
                                    } else if model.vehicleType == "2"{
                                        self.markStationsOnMapView(lat: Double(model.providerLat) ?? 0.0, lng: Double(model.providerLong) ?? 0.0, stationName: model.providerName ,iconStr: "SErvice_4Wheeler", height: 40)
                                    } else{
                                        self.markStationsOnMapView(lat: Double(model.providerLat) ?? 0.0, lng: Double(model.providerLong) ?? 0.0, stationName: model.providerName ,iconStr: "ServicesMarker", height: 40)
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                self.ServiceCollectionView.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    func CartCountAPI(){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["customer_id": Int(userId) ?? 0]
        print("CartCountParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.CartCount,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("CartCountAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [String: Any]
                            print("CartCountResult--- \(results)")
                            if let result = results{
                                let totalAmount = String(result["total_amount"] as? Int ?? 0)
                                let count = String(result["cart_count"] as? Int ?? 0)
                                DispatchQueue.main.async {
                                    if count == "0"{
                                        AlertFunctions.showAlert(message: "", title: "Cart is Empty !", image: nil)
                                    } else{
                                        let isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
                                        if(isLoggedin == true)
                                        {
                                            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CartDetailsVC") as! CartDetailsVC
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        } else{
    //                                        self.cartView.isHidden = true
                                        }
                                    }
                                }
                            }
                        } else{
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    func GetCustCareAPI(){
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.customerCareNumber,method: .get,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("CustCareRes--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? Bool ?? false
                        let message = apiDict["message"] as? String ?? ""
                        if status == true {
                            let results = apiDict["response_data"] as? [String: Any]
                            print("CustCareResult2--- \(results)")
                            if let result = results{
                                let customerCareNumber = result["customer_care_number"] as? String ?? ""
                                DispatchQueue.main.async {
                                    self.custCareNo = customerCareNumber
                                }
                            }
                        } else{
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    func markStationsOnMapView(lat:Double,lng:Double,stationName:String,iconStr:String,height:CGFloat){
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat,lng)
            let marker = GMSMarker(position: position)
            marker.title = stationName
            marker.icon = self.imageWithImage(image: UIImage(named: iconStr)!, scaledToSize: CGSize(width: 30.0, height: height))
            marker.map = self.MapView
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(marker.position)

            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            self.MapView.animate(with: update)
            self.MapView.animate(toZoom: 14)
            
//     Draw Circle on Position
//            let circ = GMSCircle(position: position, radius: 2000)
//            circ.fillColor = UIColor(red: 0.0, green: 0, blue: 0.5, alpha: 0.2)
//            circ.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1)
//            circ.strokeWidth = 2.5
//            circ.map = self.MapView
        }
    }
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("didTapMarker")
        if(self.isLoggedin == true)
        {
            for nearby in self.nearbyPlacesArray{
                if nearby.parkingName == marker.title{
                    print("TappedMarkerName --- \(marker.title)")
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                    self.showBottomSheet(model: nearby)
                    break
                }
            }
            for Service in self.serviceProviderArray {
                if Service.providerName == marker.title{
                    print("serviceProviderName---\(marker.title)")
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                    let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
                    vc.ProviderID = Service.id
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        } else{
            self.SkipLoginPopUp()
        }
        
        return true
    }
}
extension SearchPlaceVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == ParkingCollectionView{
        return nearbyPlacesArray.count
    } else{
        return serviceProviderArray.count
    }
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       if collectionView == ParkingCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyParkingPlaceCVC", for: indexPath) as! NearbyParkingPlaceCVC
           cell.minuteAwayLbl.text = "Closes \(nearbyPlacesArray[indexPath.row].endOpeningHours)"
           cell.shadowView.layer.cornerRadius = 15
           cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
           cell.shadowView.layer.shadowRadius = 3
           cell.shadowView.layer.shadowOpacity = 0.3
           cell.shadowView.layer.shadowColor = UIColor.black.cgColor
           cell.placeTitlLbl.text = nearbyPlacesArray[indexPath.row].parkingName
           cell.placeAddressLbl.text = nearbyPlacesArray[indexPath.row].address
           cell.DistanceLbl.text = "\(nearbyPlacesArray[indexPath.row].distance)"
            let CarHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            CarHrs.append(NSAttributedString(string: "\(nearbyPlacesArray[indexPath.row].fourWheelerCost)hr", attributes: [.foregroundColor:UIColor.darkGray]))
            let BikeHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            BikeHrs.append(NSAttributedString(string: "\(nearbyPlacesArray[indexPath.row].twoWheelerCost)hr", attributes: [.foregroundColor:UIColor.darkGray]))
            cell.CarPrice.attributedText = CarHrs
            cell.BikePrice.attributedText = BikeHrs
            cell.placeImg.sd_setImage(with: URL(string: APIEndPoints.BASE_PARKING_URL + nearbyPlacesArray[indexPath.row].image), placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], context: nil)
           // show or hide the vehicle image based on the vehicle type
           if nearbyPlacesArray[indexPath.row].typeOfVehicle == "1"{
               cell.bikeImg.isHidden = false
               cell.carImg.isHidden = true
               cell.CarPrice.isHidden = true
               cell.BikePrice.isHidden = false
           } else if nearbyPlacesArray[indexPath.row].typeOfVehicle == "2"{
               cell.bikeImg.isHidden = true
               cell.carImg.isHidden = false
               cell.CarPrice.isHidden = false
               cell.BikePrice.isHidden = true
           } else {
               cell.bikeImg.isHidden = false
               cell.carImg.isHidden = false
               cell.CarPrice.isHidden = false
               cell.BikePrice.isHidden = false
           }
           return cell
       } else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyServicesCVC", for: indexPath) as! NearbyServicesCVC
            cell.ServiceNameLbl.text = serviceProviderArray[indexPath.row].providerName
            cell.ServiceTimeLbl.text = "Closes \(serviceProviderArray[indexPath.row].providerEndTime)"
            cell.ServiceAddressLbl.text = serviceProviderArray[indexPath.row].providerAddress
            cell.DistanceLbl.text = "\(serviceProviderArray[indexPath.row].providerDistance)"
            cell.ServiceImg.sd_setImage(with: URL(string: APIEndPoints.BaseURL+serviceProviderArray[indexPath.row].providerImage), placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], context: nil)
            if serviceProviderArray[indexPath.row].pickUpAval == true{
                cell.pickUpLbl.text = "Pickup Available"
            } else{
                cell.pickUpLbl.text = "Pickup Not Available"
            }
            if serviceProviderArray[indexPath.row].vehicleType == "1"{
                cell.TwoWheelerImg.isHidden = false
                cell.FourWheelerImg.isHidden = true
            } else if serviceProviderArray[indexPath.row].vehicleType == "2"{
                cell.TwoWheelerImg.isHidden = true
                cell.FourWheelerImg.isHidden = false
            } else{
                cell.TwoWheelerImg.isHidden = false
                cell.FourWheelerImg.isHidden = false
            }
            return cell
       }
   }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == ParkingCollectionView{
       return CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
    } else{
        return CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
    }
   }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(self.isLoggedin == true)
        {
            if collectionView == ParkingCollectionView{
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                self.showBottomSheet(model: nearbyPlacesArray[indexPath.row])
            } else{
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
                vc.ProviderID = serviceProviderArray[indexPath.row].id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else{
            self.SkipLoginPopUp()
        }
    }
}
extension SearchPlaceVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Then display the name in textField
        SearchTF.text = place.name
        print("CoordinateLatitude: \(place.coordinate.latitude)")
        print("CoordinateLongitude: \(place.coordinate.longitude)")
        MapView.animate(to: GMSCameraPosition(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14))
        self.getNearbyParkingStations(lat: String(place.coordinate.latitude), lng: String(place.coordinate.longitude), workingDays: CurrentDay)
        self.getNearbyServiceProviders(lat: String(place.coordinate.latitude), lng: String(place.coordinate.longitude), workingDay: CurrentDay)
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}
// MARK: ParkingPlaceVCDelegate extension
extension SearchPlaceVC: ParkingPlaceVCDelegate {
    func sliderReachedToEnd(model: NearbyPlaceModel?) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
        vc.nearbyModel = model
        vc.myCarsDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: DefaultDelegate for my cars
extension SearchPlaceVC: DefaultDelegate{
    func shouldNavBack() {
    }
}
// MARK: FPC Delegate
extension SearchPlaceVC: FloatingPanelControllerDelegate {
    
}
