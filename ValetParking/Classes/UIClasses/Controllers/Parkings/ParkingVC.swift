//
//  ParkingVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 06/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SDWebImageWebPCoder

///Parking sheet delegate
protocol ParkingVCDelegate {
    /// function to navigate to Home view controller
    func ParkingHomeClickAction()
    /// function to navigate to Services view controller
    func ParkingServicesClickAction()
    /// function to navigate to Loaction view controller
    func ParkingSearchPlaceClickAction(nearbyModel: NearbyPlaceModel)
    /// function to navigate to Parking view controller
    func ParkingMechbrainAction()
    /// function to navigate to insurance view controller
    func ParkingInsuranceAction()
    /// function to navigate to servicesCategory view controller
    func ParkingTicketClickAction(ticket:GetTicketDataModel)
    /// function is excuted when the user taps on the nearby parking stations collection view to show
    func ParkingPlaceClickAction(nearbyModel:NearbyPlaceModel)
    func ParkingSearchListAction()
}
protocol ParkingBackDelegate{
    func ParkingNavigationBack()
}
class ParkingVC: UIViewController, UIAlertViewDelegate {

    @IBOutlet weak var SearchTF: UITextField!
    @IBOutlet weak var HomeImg: UIImageView!
    @IBOutlet weak var ParkingImg: UIImageView!
    @IBOutlet weak var ServicesImg: UIImageView!
    @IBOutlet weak var MechbrainImg: UIImageView!
    @IBOutlet weak var LocationImg: UIImageView!
    @IBOutlet weak var TicketsCollectionView: UICollectionView!
    @IBOutlet weak var TicketsCVHeight: NSLayoutConstraint!
    @IBOutlet weak var ParkingPlacesTableView: UITableView!
    
    var ParkingVCDel: ParkingVCDelegate? = nil
    var parkingPlacesArray: [NearbyPlaceModel] = []
    var ticketArray: [GetTicketDataModel] = []
    var isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false

    override func viewDidLoad() {
        super.viewDidLoad()
        SearchTF.superview?.layer.cornerRadius = 20
        SearchTF.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        SearchTF.superview?.layer.shadowRadius = 3
        SearchTF.superview?.layer.shadowOpacity = 0.3
        SearchTF.superview?.layer.shadowColor = UIColor.black.cgColor
        HomeImg.image = UIImage(named: "Home")?.withColor(.lightGray)
        ParkingImg.image = UIImage(named: "PArking-1")
        ServicesImg.image = #imageLiteral(resourceName: "Gray_Services").withColor(.lightGray)
        MechbrainImg.image = #imageLiteral(resourceName: "Gray_Mechbrain")
        if #available(iOS 13.0, *) {
            LocationImg.image = UIImage(systemName: "map")?.withTintColor(.lightGray)
        } else {
            LocationImg.image = UIImage(named: "Map")?.withColor(.lightGray)
        }
        HomeImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeAction)))
        ServicesImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ServicesAction)))
        MechbrainImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MechbrainAction)))
        LocationImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocationAction)))
        SearchTF.delegate = self
        TicketsCollectionView.delegate = self
        TicketsCollectionView.dataSource = self
        TicketsCollectionView.register(UINib(nibName: "TicketsCVC", bundle: nil), forCellWithReuseIdentifier: "TicketsCVC")
        ParkingPlacesTableView.delegate = self
        ParkingPlacesTableView.dataSource = self
        ParkingPlacesTableView.register(UINib(nibName: "ParkingPlaceTVC", bundle: nil), forCellReuseIdentifier: "ParkingPlaceTVC")
        ParkingPlacesTableView.estimatedRowHeight = 120
        ParkingPlacesTableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name("AppEnterForeground"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICALLS()
    }
    @objc func appMovedToForeground() {
        APICALLS()
    }
    func APICALLS(){
        getUserTickets()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eeee"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        let CurrentDay = dayOfTheWeekString.lowercased()
        let CurrLat = UserDefaults.standard.string(forKey: "CurrentLat") ?? ""
        let CurrLong = UserDefaults.standard.string(forKey: "CurrentLong") ?? ""
        getNearbyPlaces(lat: CurrLat, lng: CurrLong,workingDay: CurrentDay)
    }
    @objc func HomeAction(){
        print("HomeAction")
        ParkingVCDel?.ParkingHomeClickAction()
    }
    @objc func LocationAction(){
        print("LocationAction")
        for nearby in parkingPlacesArray{
            ParkingVCDel?.ParkingSearchPlaceClickAction(nearbyModel: nearby)
            break
        }
    }
    @objc func ServicesAction(){
        print("ServicesAction")
        ParkingVCDel?.ParkingServicesClickAction()
    }
    @objc func MechbrainAction(){
        print("MechbrainAction")
        ParkingVCDel?.ParkingMechbrainAction()
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
                                if(self.isLoggedin == true)
                                {
                                    self.ticketArray.append(model)
                                }
                            }
                            DispatchQueue.main.async {
                                if self.ticketArray.count > 0 {
                                    self.TicketsCVHeight.constant = 100
                                    self.TicketsCollectionView.reloadData()
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.TicketsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                } else{
                                    self.TicketsCVHeight.constant = 0
                                    self.TicketsCollectionView.reloadData()
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
                            self.parkingPlacesArray.removeAll()
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
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: typeOfVehicle, twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: placeId, twoWheelerAvailableParking: String(twoWheelerAvailableParking), distance: distance,fourWheelerAvailableParking:String(fourWheelerAvailableParking), endOpeningHours: endOpeningHours)
                                print("TicketDetailmodel----- \(model)")
                                self.parkingPlacesArray.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.parkingPlacesArray.count > 0 {
                                    self.ParkingPlacesTableView.reloadData()
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.ParkingPlacesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                } else{
                                    self.ParkingPlacesTableView.reloadData()
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
}

// MARK:- CollectionView Delegate
extension ParkingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ticketArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketsCVC", for: indexPath) as! TicketsCVC
        cell.dateLbl.text = ticketArray[indexPath.row].generatedDate
        cell.plateNumberLbl.text = ticketArray[indexPath.row].plateNo
        cell.ticketIdLbl.text = "Ticket ID: \(ticketArray[indexPath.row].ticketID)"
        cell.timeLbl.text = ticketArray[indexPath.row].generatedTime
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ParkingVCDel?.ParkingTicketClickAction(ticket: ticketArray[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 1.4, height: collectionView.bounds.height)
    }
}

// MARK:- TableView Delegate
extension ParkingVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingPlacesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingPlaceTVC", for: indexPath) as! ParkingPlaceTVC
        cell.selectionStyle = .none
        cell.shadowView.layer.cornerRadius = 15
        cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.shadowView.layer.shadowRadius = 3
        cell.shadowView.layer.shadowOpacity = 0.3
        cell.shadowView.layer.shadowColor = UIColor.black.cgColor
        cell.minuteAwayLbl.text = "Closes \(parkingPlacesArray[indexPath.row].endOpeningHours)"
        cell.placeTitlLbl.text = parkingPlacesArray[indexPath.row].parkingName
        cell.placeAddressLbl.text = parkingPlacesArray[indexPath.row].address
        cell.DistanceLbl.text = "\(parkingPlacesArray[indexPath.row].distance)"
        let CarHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
        CarHrs.append(NSAttributedString(string: " \(parkingPlacesArray[indexPath.row].fourWheelerCost)/hr", attributes: [.foregroundColor:UIColor.darkGray]))
        let BikeHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
        BikeHrs.append(NSAttributedString(string: " \(parkingPlacesArray[indexPath.row].twoWheelerCost)/hr", attributes: [.foregroundColor:UIColor.darkGray]))
        cell.CarPrice.attributedText = CarHrs
        cell.BikePrice.attributedText = BikeHrs
        if parkingPlacesArray[indexPath.row].image != ""{
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BASE_PARKING_URL + parkingPlacesArray[indexPath.row].image)
            DispatchQueue.main.async {
                cell.placeImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], completed: nil)
            }
        }
        if parkingPlacesArray[indexPath.row].typeOfVehicle == "1"{
            cell.BikePrice.isHidden = false
            cell.bikeImg.isHidden = false
            cell.CarPrice.isHidden = true
            cell.carImg.isHidden = true
        } else if parkingPlacesArray[indexPath.row].typeOfVehicle == "2"{
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
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ParkingVCDel?.ParkingPlaceClickAction(nearbyModel: parkingPlacesArray[indexPath.row])
    }
}
// MARK:- TextField Delegate
extension ParkingVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ParkingVCDel?.ParkingSearchListAction()
        textField.resignFirstResponder()
    }
}
