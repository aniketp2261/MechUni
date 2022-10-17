//
//  SearchParkingVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 12/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import FloatingPanel
import Alamofire
import SDWebImage
import SDWebImageWebPCoder

class SearchParkingVC: UIViewController {
    
    @IBOutlet weak var searchShadowView: ShadowView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var backBtnImg: UIImageView!
    @IBOutlet weak var sortImg: UIImageView!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var closeSortImg: UIImageView!
    @IBOutlet weak var sortTableView: UITableView!
    
    var nearbyPlacesArray:[NearbyPlaceModel] = []
    var searchParking:[NearbyPlaceModel] = []
    var sortArray = ["Distance -- Low to High","Distance -- High to Low"]
    var searchedText = ""
    var selectedRows = [IndexPath()]
    
    var searchParkingDelegate:DefaultDelegate? = nil
    let fpc = FloatingPanelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortTableView.delegate = self
        sortTableView.dataSource = self
        sortTableView.reloadData()
        sortTableView.superview?.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        searchParking = nearbyPlacesArray
        searchShadowView.shadowCornerRadius = searchShadowView.bounds.height/2
        tableView.register(UINib(nibName: "ParkingPlaceTVC", bundle: nil), forCellReuseIdentifier: "ParkingPlaceTVC")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tfSearch.borderStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tfSearch.delegate = self
        tableView.separatorStyle = .none
        backBtnImg.isUserInteractionEnabled = true
        backBtnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
        sortImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortAction)))
        closeSortImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortCloseAction)))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //showBottomSheet()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
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
        self.present(fpc, animated: true, completion: nil)
        fpc.surfaceView.appearance = appearance
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: true)
        searchParkingDelegate?.shouldNavBack()
    }
    @objc func sortAction(){
        sortView.isHidden = false
    }
    @objc func sortCloseAction(){
        sortView.isHidden = true
    }
    func searchNearbyPlaces(searchParkingName:String,sortBy:Int){
        let params:[String:Any] = ["parking_name":searchParkingName,"lat":UserDefaults.standard.string(forKey: "CurrentLat") ?? "","long":UserDefaults.standard.string(forKey: "CurrentLong") ?? "","sort_by":sortBy]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request("\(APIEndPoints.BaseURL)ticket_management/find_parking_places",method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("SearchApiResponse ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    self.searchParking.removeAll()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            print("SearchResultssssssss--- \(results)")
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
                                let capacity = result["capacity"] as? String ?? ""
                                let placeId = String(result["place_id"] as? Int ?? 0)
                                let twoWheelerAvailableParking = result["two_wheeler_available_parking"] as? Int ?? 0
                                let fourWheelerAvailableParking = result["four_wheeler_available_parking"] as? Int ?? 0
                                let distance = result["distance"] as? String ?? ""
                                let timeToReach = result["time_to_reach"] as? String ?? ""
                                let model = NearbyPlaceModel(image: img, parkingName: parkingName, address: address, mobileNumber: mobileNumber, startOpeningHours: startOpeningHours, typeOfVehicle: typeOfVehicle, twoWheelerCost: String(twoWheelerCost), fourWheelerCost: String(fourWheelerCost), lat: lat, long: long, placeId: placeId, twoWheelerAvailableParking: String(twoWheelerAvailableParking), distance: distance,fourWheelerAvailableParking:String(fourWheelerAvailableParking), endOpeningHours: endOpeningHours)
                                self.searchParking.append(model)
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
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
}
class SearchParkingSortTVC: UITableViewCell{
    @IBOutlet weak var radImg: UIImageView!
    @IBOutlet weak var sortLbl: UILabel!
}
extension SearchParkingVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sortTableView{
            return sortArray.count
        } else{
            return searchParking.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       if tableView == sortTableView{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchParkingSortTVC", for: indexPath) as! SearchParkingSortTVC
        cell.sortLbl.text = sortArray[indexPath.row]
        if selectedRows.contains(indexPath){
            cell.radImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill").withColor(.black)
        } else{
            cell.radImg.image = #imageLiteral(resourceName: "ic_red_radio_circle").withColor(.black)
        }
        return cell
       } else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingPlaceTVC", for: indexPath) as! ParkingPlaceTVC
        cell.selectionStyle = .none
        cell.shadowView.layer.cornerRadius = 15
        cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.shadowView.layer.shadowRadius = 3
        cell.shadowView.layer.shadowOpacity = 0.3
        cell.shadowView.layer.shadowColor = UIColor.black.cgColor
        cell.minuteAwayLbl.text = "Closes \(searchParking[indexPath.row].endOpeningHours)"
        cell.placeTitlLbl.text = searchParking[indexPath.row].parkingName
        cell.placeAddressLbl.text = searchParking[indexPath.row].address
        cell.DistanceLbl.text = "\(searchParking[indexPath.row].distance)"
        let CarHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
        CarHrs.append(NSAttributedString(string: " \(searchParking[indexPath.row].fourWheelerCost)/hr", attributes: [.foregroundColor:UIColor.darkGray]))
        let BikeHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
        BikeHrs.append(NSAttributedString(string: " \(searchParking[indexPath.row].twoWheelerCost)/hr", attributes: [.foregroundColor:UIColor.darkGray]))
        cell.CarPrice.attributedText = CarHrs
        cell.BikePrice.attributedText = BikeHrs
        if searchParking[indexPath.row].image != ""{
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BASE_PARKING_URL + searchParking[indexPath.row].image)
            DispatchQueue.main.async {
                cell.placeImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], completed: nil)
            }
        }
        if searchParking[indexPath.row].typeOfVehicle == "1"{
            cell.BikePrice.isHidden = false
            cell.bikeImg.isHidden = false
            cell.CarPrice.isHidden = true
            cell.carImg.isHidden = true
        } else if searchParking[indexPath.row].typeOfVehicle == "2"{
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
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == sortTableView{
            return 35
        } else{
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sortTableView{
            self.sortCloseAction()
            self.searchNearbyPlaces(searchParkingName: self.searchedText, sortBy: indexPath.row+1)
        } else{
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            self.showBottomSheet(model: searchParking[indexPath.row])
        }
    }
}
extension SearchParkingVC : UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchedText = textField.text ?? ""
        searchParking.removeAll()
        if textField.text != nil && textField.text != "" && textField.text!.count > 2{
            self.searchNearbyPlaces(searchParkingName: textField.text!, sortBy: 0)
        }
        else {
            print("Array duplication")
            searchParking = nearbyPlacesArray
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
// MARK:- ParkingPlaceVCDelegate extension
extension SearchParkingVC: ParkingPlaceVCDelegate {
    func sliderReachedToEnd(model: NearbyPlaceModel?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
        vc.nearbyModel = model
        vc.myCarsDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK:- DefaultDelegate for my cars
extension SearchParkingVC: DefaultDelegate{
    func shouldNavBack() {
        
    }
}
// MARK: FPC Delegate
extension SearchParkingVC:FloatingPanelControllerDelegate {
    
}
