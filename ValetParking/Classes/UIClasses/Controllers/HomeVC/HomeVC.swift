 //
//  HomeVC.swift
//  ValetParking
//
//  Created by Khushal on 15/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import GoogleMaps
import GooglePlaces
import FloatingPanel
import CoreLocation

 enum VersionError: Error {
     case invalidResponse, invalidBundleInfo
 }
 
class HomeVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate, UIAlertViewDelegate {
  
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var optionsStackView:UIStackView!
    @IBOutlet weak var hamBurgerMenuView:UIView!
//  @IBOutlet weak var searchView: UIView!
//  @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var nearbyParkingCollectionView:UICollectionView!
    
    @IBOutlet weak var carBtn: UIButton!
    @IBOutlet weak var bikeBtn: UIButton!
    @IBOutlet weak var relocateBtn: UIButton!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var CartBtn: UIButton!
    @IBOutlet weak var CallBtn: UIButton!
    @IBOutlet weak var carBtnShadowView: ShadowView!
    @IBOutlet weak var bikeBtnShadowView: ShadowView!
    @IBOutlet weak var relocateBtnShadowView: ShadowView!
    @IBOutlet weak var scanBtnShadowView: ShadowView!
    @IBOutlet weak var cartView: ShadowView!
    @IBOutlet weak var callShadowView: ShadowView!
    
//  @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
//  @IBOutlet weak var BackImg: UIImageView!
    
    let bottomSheetFpc = FloatingPanelController()
    
    var locationManager = CLLocationManager()
    var geocoder = GMSGeocoder()
    var locationgeocoder: CLGeocoder?
    var location: CLLocation?
   //var cirlce: GMSCircle!
    var userLatitude = ""
    var userLongitute = ""
    var nearbyPlacesArray: [NearbyPlaceModel] = []
    var serviceProvicerArray: [NearbyServiceProviderModel] = []
    var ListArray : NSArray = []
    var parkings = 0
    var commonDict : NSDictionary = NSDictionary()
    var placeID : Int?
    
    //MARK: ViewController variables
    var bottomContentVC: ParkingSheetVC? = nil
    var parkingDetailVC: ParkingPlaceVC? = nil
    var searchPlaceVC: SearchPlaceVC? = nil
    var ticketDetailVC: TicketDetailsVC? = nil
    
    var parkingVC: ParkingVC? = nil
    var servicesVC: ServicesVC? = nil
    var mechbrainVC: MechbrainVC? = nil
    
    var CurrentDay: String?
    var isRefresh = 0
    var AppVersion = ""
    var appId = ""
    var isLoggedin = Bool()
    var custCareNo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//      searchTF.delegate = self
        AppVersion = Bundle.main.releaseVersionNumber ?? ""
        print("AppVersion: \(AppVersion) -- \(Bundle.main.bundleIdentifier)")
        initChildVCs()
        carBtnShadowView.shadowCornerRadius = carBtnShadowView.bounds.height/2
        bikeBtnShadowView.shadowCornerRadius = bikeBtnShadowView.bounds.height/2
        scanBtnShadowView.shadowCornerRadius = scanBtnShadowView.bounds.height/2
        relocateBtnShadowView.shadowCornerRadius = relocateBtnShadowView.bounds.height/2
        cartView.shadowCornerRadius = cartView.bounds.height/2
        callShadowView.shadowCornerRadius = callShadowView.bounds.height/2
        bikeBtn.layer.cornerRadius = bikeBtn.bounds.height/2
        carBtn.layer.cornerRadius = carBtn.bounds.height/2
        relocateBtn.layer.cornerRadius = relocateBtn.bounds.height/2
        scanBtn.layer.cornerRadius = scanBtn.bounds.height/2
        CartBtn.layer.cornerRadius = CartBtn.bounds.height/2
        CallBtn.layer.cornerRadius = CallBtn.bounds.height/2
        mapView.bringSubviewToFront(optionsStackView)
        mapView.bringSubviewToFront(hamBurgerMenuView)
//        mapView.bringSubviewToFront(nearbyParkingCollectionView)
        mapView.delegate = self
        hamBurgerMenuView.isHidden = false
        hamBurgerMenuView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hamburgersMenuAction)))
        CallBtn.addTarget(self, action: #selector(callAction), for: .touchUpInside)
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eeee"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        CurrentDay = dayOfTheWeekString.lowercased()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 30
        bottomSheetFpc.surfaceView.appearance = appearance
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.didProfileDisappeared.rawValue), object: true)
        print("HomeVCDidLoad -------")
        //self.searchView.layer.cornerRadius = 20
        NotificationCenter.default.post(name: Notification.Name("load"), object: nil)
        sideMenuController?.isLeftViewSwipeGestureEnabled = true
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        relocateBtn.setImage(#imageLiteral(resourceName: "ic_gps_view"), for: .normal)
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        nearbyParkingCollectionView.delegate = self
        nearbyParkingCollectionView.dataSource = self
        setUpViews()
        APICALLS()
    }
    private func initChildVCs(){
        bottomContentVC = (storyboard?.instantiateViewController(withIdentifier: "ParkingSheetVC") as! ParkingSheetVC)
        bottomContentVC?.HomeVCDelegate = self
        parkingDetailVC = (storyboard?.instantiateViewController(withIdentifier: "ParkingPlaceVC") as! ParkingPlaceVC)
        parkingDetailVC?.parkingPlaceDelegate = self
        ticketDetailVC = (storyboard?.instantiateViewController(withIdentifier: "TicketDetailsVC") as! TicketDetailsVC)
        ticketDetailVC?.ticketDelegate = self
        searchPlaceVC = (storyboard?.instantiateViewController(withIdentifier: "SearchPlaceVC") as! SearchPlaceVC)
        searchPlaceVC?.searchDelegate = self
        parkingVC = (storyboard?.instantiateViewController(withIdentifier: "ParkingVC") as! ParkingVC)
        parkingVC?.ParkingVCDel = self
        servicesVC = (UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ServicesVC") as! ServicesVC)
        servicesVC?.ServicesSheetVCDelegate = self
        mechbrainVC = (UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainVC") as! MechbrainVC)
        mechbrainVC?.MechbrainSheetVCDelegate = self
    }
    @objc func observeNearby(_ notif:Notification){
        if(isLoggedin == true)
        {
            let obj = notif.object as? NearbyPlaceModel
            parkingDetailVC?.nearbyPlaceModel = obj
            bottomSheetFpc.contentViewController = parkingDetailVC
        } else{
            SkipLoginPopUp()
        }
    }
    private func setUpViews(){
        print("----setupViewClick----")
        if !bottomSheetFpc.isBeingPresented{
            bottomSheetFpc.set(contentViewController: bottomContentVC)
            bottomSheetFpc.delegate = self
            bottomSheetFpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
            self.present(bottomSheetFpc, animated: true, completion: nil)
        }
    }
    @objc func hamburgersMenuAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuAlertVC") as! MenuAlertVC
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
        print("isLoggedin: \(isLoggedin)")
        UserDefaults.standard.setValue("home", forKey: "SelectedTab")
        NotificationCenter.default.addObserver(self, selector: #selector(LogoutAction), name: NSNotification.Name(rawValue: "MenuScreenAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observeProfileDismissal(_:)), name: NSNotification.Name(rawValue: NotificationKeys.didProfileDisappeared.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scannerToHomeScreen), name: NSNotification.Name(rawValue: NotificationKeys.scannerToHomeScreen.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LogoutAction), name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observeNearby), name: NSNotification.Name(rawValue: NotificationKeys.notificationParkingDetails.rawValue), object: nil)
    }
    func APICALLS(){
        checkLocationPermission()
        startLocation()
        updateNow()
        GetCustCareAPI()
    }
    func updateNow(){
        DispatchQueue.global().async {
            do {
                _ = try self.isUpdateAvailable(completion: { isUpdate, error in
                    DispatchQueue.main.async {
                        print("appid:--\(self.appId)")
                        // show alert
                        if isUpdate ?? false {
                            AlertFunctions.showAlert(message: "There is a new version of the app is Available.", title: "App Update Available!", image: #imageLiteral(resourceName: "AppLogo")){
                                UIApplication.shared.openAppStore(for: "id\(self.appId)")
                            }
                        } else{
                            print("App is Upto Date")
                        }
                    }
                })
            } catch {
                print(error)
            }
        }
    }
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        debugPrint("currentVersion:--\(currentVersion)-\(identifier)")
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String, let trackId = result["trackId"] as? Int else {
                    throw VersionError.invalidResponse
                }
                self.appId = "\(trackId)"
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .denied {
                let alert = UIAlertView(title: "Location Access", message: "App Location Permission Denied.To re-enable, please go to Settings and turn on Location Service for this app.", delegate: self, cancelButtonTitle: "Allow Location")
                alert.tag = 100
                alert.show()
            } else {
                startLocation()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "LocationRefresh"), object: nil)
                print("Location Services Enabled")
            }
        }
    }
    func SkipLoginPopUp(){
        let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
        alert.tag = 50
        alert.show()
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if alertView.tag == 100 {
            if buttonIndex == 0 {
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
        } else if alertView.tag == 50{
            print("EditProfileAlertButtonIndex---\(buttonIndex)")
            if buttonIndex == 1{
                bottomSheetFpc.dismiss(animated: true){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                    UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                    let myVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(myVC, animated: false)
                }
            } else{
                alertView.dismiss(withClickedButtonIndex: 0, animated: false)
            }
        }
    }
    func startLocation()  {
         locationManager = CLLocationManager()
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestWhenInUseAuthorization()
         locationManager.showsBackgroundLocationIndicator = false
         locationManager.allowsBackgroundLocationUpdates = true
         locationManager.delegate = self
         locationManager.startUpdatingLocation()
    }
    @objc func observeProfileDismissal(_ notif:Notification){
        print("notif ----- \(notif)")
        let obj = notif.object as? Bool ?? false
        print("obj 000000------ \(obj)")
        if obj {
            setUpViews()
        }
        else{
            return
        }
    }
    @objc func scannerToHomeScreen(_ notif:Notification){
        setUpViews()
    }
    private func getNearbyParkingStations(lat:String,lng:String,workingDays:String){
        let params:[String:Any] = ["lat":lat,"long":lng,"working_days":workingDays,"parking_status":true]
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
                                let capacity = result["capacity"] as? String ?? ""
                                let placeId = String(result["place_id"] as? Int ?? 0)
                                let twoWheelerAvailableParking = String(result["two_wheeler_available_parking"] as? Int ?? 0)
                                let fourWheelerAvailableParking = String(result["four_wheeler_available_parking"] as? Int ?? 0)
                                let distance = result["distance"] as? String ?? ""
                                let timeToReach = result["time_to_reach"] as? String ?? ""
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: String(typeOfVehicle), twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: placeId, twoWheelerAvailableParking: twoWheelerAvailableParking, distance: distance, fourWheelerAvailableParking: fourWheelerAvailableParking, endOpeningHours: endOpeningHours)
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
                        }
                    }
                case .failure(_):
                    self.view.makeToast("Failure..")
                    print("failure")
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
    private func getNearbyServiceProviders(lat:String,lng:String,workingDay:String){
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
                            self.serviceProvicerArray.removeAll()
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
                        
                                let model = NearbyServiceProviderModel(id: id, providerName: name, providerAddress: address, providerImage: image, providerMobile: mobilenumber, providerEmail: email, providerStartTime: startOpeningHours, providerEndTime: endOpeningHours, providerLat: lat, providerLong: long, providerDistance: distance, providerTimetoReach: timeToReach,vehicleType: vehicleType, pickUpAval: pickup, workingDays: workingDays)
                                print("serviceArray--- \(model)")
                                self.serviceProvicerArray.append(model)
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
                        }
                    }
                case .failure(_):
                    print("failure")
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        getToken()
    }

// MARK:- Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        UserDefaults.standard.setValue(String(locations[0].coordinate.latitude) , forKey: "CurrentLat")
        UserDefaults.standard.setValue(String(locations[0].coordinate.longitude) , forKey: "CurrentLong")
        if isRefresh == 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "LocationRefresh"), object: nil)
            print("LocationRefresh")
            self.isRefresh = 1
            let camera = GMSCameraPosition.camera(withLatitude: locations[0].coordinate.latitude,
                                                  longitude: locations[0].coordinate.longitude,
                                                  zoom: 12)
            mapView.camera = camera
            self.userLatitude = String(format: "%f", (locations[0].coordinate.latitude))
            self.userLongitute = String(format: "%f", (locations[0].coordinate.longitude))
            getNearbyParkingStations(lat: String(locations[0].coordinate.latitude), lng: String(locations[0].coordinate.longitude), workingDays: CurrentDay ?? "")
            getNearbyServiceProviders(lat: String(locations[0].coordinate.latitude), lng: String(locations[0].coordinate.longitude), workingDay: CurrentDay ?? "")
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
        if(isLoggedin == true)
        {
            for nearby in self.nearbyPlacesArray{
                if nearby.parkingName == marker.title{
                    print("TappedMarkerName --- \(marker.title)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.notificationParkingDetails.rawValue), object: nearby)
                    break
                }
            }
            for Service in self.serviceProvicerArray {
                if Service.providerName == marker.title{
                    print("TappedMarkerName --- \(marker.title)")
                    let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
                    vc.ProviderID = Service.id
                    vc.ProviderDetailsHomeVCDelegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        } else{
            SkipLoginPopUp()
        }
        return true
    }
    @IBAction func relocateAction(){
        relocateToCurrentPositionMapView()
    }
    //Button Actions
    @IBAction func hamburgerMenuAction(){
        bottomSheetFpc.willMove(toParent: nil)
        bottomSheetFpc.contentViewController = nil
        bottomSheetFpc.hide(animated: true) {
            self.bottomSheetFpc.view.removeFromSuperview()
            self.bottomSheetFpc.removeFromParent()
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuAlertVC") as! MenuAlertVC
        present(vc, animated: true, completion: nil)
    }
    @IBAction func bikeButtonAction(){
        bikeBtn.isSelected = !(bikeBtn.isSelected)
        if bikeBtn.isSelected {
            let image = UIImage(named: "icBikeGray")?.withRenderingMode(.alwaysTemplate)
            bikeBtn.setImage(image, for: .normal)
            bikeBtn.tintColor = UIColor.red
            carBtn.setImage(UIImage(named: "icCarGray"), for: .normal)
            self.mapView.clear()
            for station in nearbyPlacesArray{
                print("station.typeOfVehicle000----- \(station.typeOfVehicle)")
                if station.typeOfVehicle == "1"{
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName,iconStr: "parking_2Wheeler", height: 40)
                } else if station.typeOfVehicle == "3" {
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
        } else{
            let image = UIImage(named: "icBikeGray")
            bikeBtn.setImage(image, for: .normal)
            self.mapView.clear()
            for station in nearbyPlacesArray{
                if station.typeOfVehicle == "1"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_2Wheeler", height: 40)
                } else if station.typeOfVehicle == "2"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_4Wheeler", height: 40)
                } else{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
        }
    }
    @IBAction func carButtonAction(){
        carBtn.isSelected = !(carBtn.isSelected)
        if carBtn.isSelected {
            let image = UIImage(named: "icCarGray")?.withRenderingMode(.alwaysTemplate)
            carBtn.setImage(image, for: .normal)
            carBtn.tintColor = UIColor.red
            bikeBtn.setImage(UIImage(named: "icBikeGray"), for: .normal)
            self.mapView.clear()
            for station in nearbyPlacesArray{
                if station.typeOfVehicle == "2" {
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName,iconStr: "parking_4Wheeler", height: 40)
                } else if station.typeOfVehicle == "3" {
                    markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
        } else{
            let image = UIImage(named: "icCarGray")
            carBtn.setImage(image, for: .normal)
            self.mapView.clear()
            for station in nearbyPlacesArray{
                if station.typeOfVehicle == "1"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_2Wheeler", height: 40)
                } else if station.typeOfVehicle == "2"{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parking_4Wheeler", height: 40)
                } else{
                    self.markStationsOnMapView(lat: Double(station.lat) ?? 0.0, lng: Double(station.long) ?? 0.0, stationName: station.parkingName, iconStr: "parkingboth", height: 40)
                }
            }
        }
    }
    @IBAction func scannerButtonAction(){
        if (isLoggedin == true){
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParkingScannerVC") as! ParkingScannerVC
            vc.SearchPlaceVc = false
            self.navigationController?.pushViewController(vc, animated: false)
        } else{
            SkipLoginPopUp()
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bottomSheetFpc.dismiss(animated: true, completion: nil)
//        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func LogoutAction(){
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true){
            print("LogoutEvent --- DismissSheet")
        }
    }
    func markStationsOnMapView(lat:Double, lng:Double, stationName:String, iconStr:String, height:CGFloat){
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat,lng)
            let marker = GMSMarker(position: position)
            marker.title = stationName
            marker.icon = self.imageWithImage(image: UIImage(named: iconStr)!, scaledToSize: CGSize(width: 30.0, height: height))
            marker.map = self.mapView
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(marker.position)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            self.mapView.animate(with: update)
            self.mapView.animate(toZoom: 14)
            self.mapView.isMyLocationEnabled = true
        }
    }
    func relocateToCurrentPositionMapView(){
        DispatchQueue.main.async {
            let lat = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLat") ?? "") ?? 0.0
            let lng = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLong") ?? "") ?? 0.0
            let cameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14)
            self.mapView.animate(to: cameraPosition)
        }
    }
    @objc func homeViewButton(_ not:NSNotification) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeSelected"), object: nil)
        self.bottomSheetFpc.contentViewController = nil
        self.bottomSheetFpc.set(contentViewController: self.bottomContentVC)
    }
    @objc func parkViewButton(_ not:NSNotification) {
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ParkingSelected"), object: nil)
        self.bottomSheetFpc.contentViewController = parkingVC
    }
    @IBAction func searchButton(){
        print("searchButton000000-----")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
        let address = place.name
        print("lat", place.coordinate.latitude)
        print("long", place.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                              longitude: place.coordinate.longitude,
                                              zoom: 12 )
        self.mapView.camera = camera
        self.userLatitude = String(format: "%f", (place.coordinate.latitude))
        self.userLongitute = String(format: "%f", (place.coordinate.longitude))
        self.getNearbyParkingStations(lat: String(place.coordinate.latitude), lng: String(place.coordinate.longitude), workingDays: CurrentDay ?? "")
        self.getNearbyServiceProviders(lat: String(place.coordinate.latitude), lng: String(place.coordinate.longitude), workingDay: CurrentDay ?? "")
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // Handle the user's selection.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                               didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
        
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                               didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
        
// MARK:- API CALL
    func getToken()
    {
         let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
         let tokenID = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
         let parameters =
            [
                "_id": idValue as Any,
                "token_id": tokenID
            ]
        print("update token -- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)customer_table/customer_update_token", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("update token Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                if status == "failed" {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                } else{
                                    SKActivityIndicator.dismiss()
                                }
                            }
                        }
                        break
                    case .failure(let error):
                        SKActivityIndicator.dismiss()
                        print(error)
                        break
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
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.CartCount,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("CartCountAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
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
                                            vc.CartDelegate = self
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
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        }
    }
    func GetCustCareAPI(){
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.customerCareNumber,method: .get,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("CustCareRes--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
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
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        }
    }
 }
extension HomeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyPlacesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyParkingPlaceCVC", for: indexPath) as! NearbyParkingPlaceCVC
            cell.shadowView.layer.cornerRadius = 15
            cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowOpacity = 0.3
            cell.shadowView.layer.shadowColor = UIColor.black.cgColor
            cell.minuteAwayLbl.text = "Closes \(nearbyPlacesArray[indexPath.row].endOpeningHours)"
            cell.DistanceLbl.text = nearbyPlacesArray[indexPath.row].distance
            cell.placeTitlLbl.text = nearbyPlacesArray[indexPath.row].parkingName
            cell.placeAddressLbl.text = nearbyPlacesArray[indexPath.row].address
            let CarHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            CarHrs.append(NSAttributedString(string: "\(nearbyPlacesArray[indexPath.row].fourWheelerCost)hr", attributes: [.foregroundColor:UIColor.darkGray]))
            let BikeHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            BikeHrs.append(NSAttributedString(string: "\(nearbyPlacesArray[indexPath.row].twoWheelerCost)hr", attributes: [.foregroundColor:UIColor.darkGray]))
            cell.CarPrice.attributedText = CarHrs
            cell.BikePrice.attributedText = BikeHrs
            cell.placeImg.sd_setImage(with: URL(string: APIEndPoints.BASE_PARKING_URL + "\(nearbyPlacesArray[indexPath.row].image)"), placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], context: nil)
            // show or hide the vehicle image based on the vehicle type
            if nearbyPlacesArray[indexPath.row].typeOfVehicle == "1"{
                cell.bikeImg.isHidden = false
                cell.carImg.isHidden = true
            } else if nearbyPlacesArray[indexPath.row].typeOfVehicle == "2"{
                cell.bikeImg.isHidden = true
                cell.carImg.isHidden = false
            } else {
                cell.bikeImg.isHidden = false
                cell.carImg.isHidden = false
            }
            return cell
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.bounds.width-8, height: collectionView.bounds.height)
        }
     }
 extension UIView{
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
 }
// MARK:- HomeVC
extension HomeVC: FloatingPanelControllerDelegate{
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        print("WIll Remove")
        tabBarController?.tabBar.isHidden = false
    }
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        if fpc.contentViewController == parkingDetailVC {
            print("state0000 ---- \(fpc.state)")
            if fpc.state == .tip {
                fpc.contentViewController = nil
                fpc.set(contentViewController: bottomContentVC)
                fpc.move(to: .half, animated: true)
            }
        }
    }
}
 
extension HomeVC: DefaultDelegate{
    func shouldNavBack() {
        setUpViews()
    }
}
 extension HomeVC: ParkingBackDelegate{
     func ParkingNavigationBack() {
         if !bottomSheetFpc.isBeingPresented{
             bottomSheetFpc.set(contentViewController: parkingVC)
             bottomSheetFpc.delegate = self
             bottomSheetFpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
             self.present(bottomSheetFpc, animated: true, completion: nil)
         }
     }
  }
extension HomeVC: ServicesCatVCDelegate{
    func ServicesNavigationBack() {
        if !bottomSheetFpc.isBeingPresented{
            bottomSheetFpc.set(contentViewController: servicesVC)
            bottomSheetFpc.delegate = self
            bottomSheetFpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
            self.present(bottomSheetFpc, animated: true, completion: nil)
        }
    }
 }
 extension HomeVC: MechbrainServicesCatVCDelegate{
     func MechbrainNavigationBack() {
         if !bottomSheetFpc.isBeingPresented{
             bottomSheetFpc.set(contentViewController: mechbrainVC)
             bottomSheetFpc.delegate = self
             bottomSheetFpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
             self.present(bottomSheetFpc, animated: true, completion: nil)
         }
     }
  }

// MARK:- HomeVCDelegate extension
extension HomeVC: HomeVCDelegate {
    func ParkingClickAction(){
        bottomSheetFpc.contentViewController = parkingVC
    }
    func parkingBtnAction(nearbyModel: NearbyPlaceModel) {
        searchPlaceVC?.searchDelegate = self
        navigationController?.pushViewController(searchPlaceVC!, animated: false)
    }
    func ticketTapped(ticket: GetTicketDataModel) {
        ticketDetailVC!.ticketDelegate = self
        ticketDetailVC!.ticketDetailModel = ticket
        print("ticketId000---- \(ticket.ticketID)")
        UserDefaults.standard.setValue(ticket.ticketID,forKey: "TicketId")
        navigationController?.pushViewController(ticketDetailVC!, animated: false)
    }
    func parkingStationTapped(nearbyModel: NearbyPlaceModel) {
        searchPlaceVC?.searchDelegate = self
        navigationController?.pushViewController(searchPlaceVC!, animated: false)
    }
    func ParkingPlaceAction(nearbyModel: NearbyPlaceModel){
        if(isLoggedin == true)
        {
            parkingDetailVC?.nearbyPlaceModel = nearbyModel
            bottomSheetFpc.contentViewController = parkingDetailVC
        } else{
            SkipLoginPopUp()
        }
    }
    func searchParkingAction(){
        if(isLoggedin == true)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchAllVC") as! SearchAllVC
            vc.searchParkingDelegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
    func mechBrainAction(){
        bottomSheetFpc.contentViewController = mechbrainVC
    }
    func insuranceAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InsuranceVC") as! InsuranceVC
        vc.InsuranceVCDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func servicesAction(){
        bottomSheetFpc.contentViewController = servicesVC
    }
    func nearbyServices(provider: NearbyServiceProviderModel) {
        if(isLoggedin == true)
        {
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
            vc.ProviderID = provider.id
            vc.ProviderDetailsHomeVCDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
    func myOrdersTapped(Order: OrderListModel) {
        if(isLoggedin == true)
        {
            let orderId = Order.orderID
            UserDefaults.standard.setValue(orderId, forKey: "OrderID")
            let VC = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
            VC.OrderDetailsVCDelegate = self
            self.navigationController?.pushViewController(VC, animated: false)
        } else{
            SkipLoginPopUp()
        }
    }
 }
 
// MARK:- ParkingPlaceVCDelegate extension
 extension HomeVC: ParkingPlaceVCDelegate {
    func sliderReachedToEnd(model: NearbyPlaceModel?) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
        vc.nearbyModel = model
        vc.myCarsDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
 }
 
 // MARK:- SearchPlaceDelegate extension
 extension HomeVC: SearchPlaceDelegate{
    func naviBack() {
        setUpViews()
    }
 }
 
 // MARK:- ParkingVCDelegate extension
 extension HomeVC: ParkingVCDelegate{
    func ParkingHomeClickAction(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeSelected"), object: nil)
        self.bottomSheetFpc.contentViewController = nil
        self.bottomSheetFpc.set(contentViewController: self.bottomContentVC)
    }
    func ParkingServicesClickAction(){
        bottomSheetFpc.contentViewController = servicesVC
    }
    func ParkingSearchPlaceClickAction(nearbyModel: NearbyPlaceModel){
        searchPlaceVC?.searchDelegate = self
        navigationController?.pushViewController(searchPlaceVC!, animated: false)
    }
    func ParkingMechbrainAction(){
        bottomSheetFpc.contentViewController = mechbrainVC
    }
    func ParkingInsuranceAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InsuranceVC") as! InsuranceVC
        vc.InsuranceVCDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func ParkingTicketClickAction(ticket: GetTicketDataModel){
        ticketDetailVC!.ticketDelegate = self
        ticketDetailVC!.ticketDetailModel = ticket
        print("ticketId000---- \(ticket.ticketID)")
        UserDefaults.standard.setValue(ticket.ticketID,forKey: "TicketId")
        navigationController?.pushViewController(ticketDetailVC!, animated: true)
    }
    func ParkingPlaceClickAction(nearbyModel: NearbyPlaceModel){
        if(isLoggedin == true)
        {
            if nearbyPlacesArray.count != 0{
                parkingDetailVC?.nearbyPlaceModel = nearbyModel
                bottomSheetFpc.contentViewController = parkingDetailVC
            }
        } else{
            SkipLoginPopUp()
        }
    }
    func ParkingSearchListAction(){
        if(isLoggedin == true)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchParkingVC") as! SearchParkingVC
            vc.searchParkingDelegate = self
            vc.nearbyPlacesArray = nearbyPlacesArray
            navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
  }
 
// MARK:- ServicesVCDelegate extension
 extension HomeVC: ServicesVCDelegate{
    func ServicesOrdersClickAction(order: OrderListModel) {
        let orderId = order.orderID
        UserDefaults.standard.setValue(orderId, forKey: "OrderID")
        let VC = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
        VC.ServicesBackDelegate = self
        self.navigationController?.pushViewController(VC, animated: false)
    }
    func ServicesHomeClickAction(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeSelected"), object: nil)
        self.bottomSheetFpc.contentViewController = nil
        self.bottomSheetFpc.set(contentViewController: self.bottomContentVC)
    }
    func ServicesParkingClickAction(){
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ParkingSelected"), object: nil)
        bottomSheetFpc.contentViewController = parkingVC
    }
    func ServicesSearchListAction(){
        if(isLoggedin == true)
        {
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "SearchServicesVC") as! SearchServicesVC
            vc.searchServiceDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
        
    }
    func ServicesMechBrainAction(){
        bottomSheetFpc.contentViewController = mechbrainVC
    }
    func ServicesInsuranceServicesAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InsuranceVC") as! InsuranceVC
        vc.InsuranceVCDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func ServicesServicesByCategory(Category: CategoriesModel){
        if(isLoggedin == true)
        {
            bottomSheetFpc.dismiss(animated: true, completion: nil)
//            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
            vc.ServicesCategoryVCDelegate = self
            vc.CategoryId = Category.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
    func ServicesNearbyServicesClick(provider: NearbyServiceProviderModel) {
        if(isLoggedin == true)
        {
            bottomSheetFpc.dismiss(animated: true, completion: nil)
//            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
            vc.ProviderDetailsSerVCDelegate = self
            vc.ProviderID = provider.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
    func ServicesSearchPlaceAction(nearbyModel: NearbyPlaceModel){
        searchPlaceVC?.searchDelegate = self
        searchPlaceVC?.nearbyPlacesArray = nearbyPlacesArray
        navigationController?.pushViewController(searchPlaceVC!, animated: false)
    }
 }
 
// MARK:- MechbrainVCDelegate
extension HomeVC: MechbrainVCDelegate{
    func MechbrainOrdersClickAction(order: OrderListModel){
        let orderId = order.orderID
        UserDefaults.standard.setValue(orderId, forKey: "MBOrderID")
        let VC = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainOrderDatailsVC") as! MechbrainOrderDatailsVC
        VC.MechbrainSerVCDelegate = self
        self.navigationController?.pushViewController(VC, animated: false)
    }
    func MechbrainHomeClickAction(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeSelected"), object: nil)
        self.bottomSheetFpc.contentViewController = nil
        self.bottomSheetFpc.set(contentViewController: self.bottomContentVC)
    }
    func MechbrainParkingClickAction(){
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ParkingSelected"), object: nil)
        bottomSheetFpc.contentViewController = parkingVC
    }
    func MechbrainServicesClickAction(){
        self.bottomSheetFpc.contentViewController = servicesVC
    }
    func MechbrainSearchPlaceClickAction(nearbyModel: NearbyPlaceModel){
        self.searchPlaceVC?.searchDelegate = self
        self.searchPlaceVC?.nearbyPlacesArray = nearbyPlacesArray
        navigationController?.pushViewController(searchPlaceVC!, animated: false)
    }
    func MechbrainMechBrainAction(){
        print("mechBrainAction")
    }
    func MechbrainInsuranceAction(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InsuranceVC") as! InsuranceVC
        vc.InsuranceVCDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func MechbrainServicesByCategory(Category: CategoriesModel){
        if(isLoggedin == true)
        {
            bottomSheetFpc.dismiss(animated: true, completion: nil)
//            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainCategoryServiceVC") as! MechbrainCategoryServiceVC
            vc.MechbrainServicesCategoryVCDelegate = self
            vc.CategoryId = Category.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
    func MechbrainNearbyServicesClick(provider: NearbyServiceProviderModel){
        if(isLoggedin == true)
        {
            bottomSheetFpc.dismiss(animated: true, completion: nil)
            let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainProviderDetailsVC") as! MechbrainProviderDetailsVC
            vc.MechbrainProviderDetailsSerVCDelegate = self
            vc.ProviderID = provider.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
    func MechbrainSearchListAction(){
        if(isLoggedin == true)
        {
            let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "SearchMechbrainServicesVC") as! SearchMechbrainServicesVC
            vc.searchServiceDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            SkipLoginPopUp()
        }
    }
}
