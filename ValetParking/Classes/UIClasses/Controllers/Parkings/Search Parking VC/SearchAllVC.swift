//
//  SearchAllVC.swift
//  MechUni
//
//  Created by Aniket Patil on 10/10/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import FloatingPanel
import Alamofire
import SDWebImage
import SDWebImageWebPCoder

struct AllSearchModel{
    let id, parkingName, categoryId, vehicleType, typeOfVehicle, userName, name, description, image, startOpeningHours, endOpeningHours, address, type, twoWpCost, fourWpCost, lat, long, twoWheelerAvailableParking, fourWheelerAvailableParking: String
}

class SearchAllVC: UIViewController {

    @IBOutlet weak var searchShadowView: ShadowView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var backBtnImg: UIImageView!
    
    var searchData:[AllSearchModel] = []
    var parkingModel: NearbyPlaceModel? = nil
    var searchedText = ""
    
    var searchParkingDelegate:DefaultDelegate? = nil
    let fpc = FloatingPanelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Constants.kMainViewController?.isLeftViewDisabled = true
        searchShadowView.shadowCornerRadius = searchShadowView.bounds.height/2
        tableView.register(UINib(nibName: "AllSearchTVC", bundle: nil), forCellReuseIdentifier: "AllSearchTVC")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tfSearch.borderStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tfSearch.delegate = self
        tableView.separatorStyle = .none
        backBtnImg.isUserInteractionEnabled = true
        backBtnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //showBottomSheet()
//        searchAll(searchName: "")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fpc.dismiss(animated: true, completion: nil)
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
    @objc func backAction(){
        navigationController?.popViewController(animated: true)
        searchParkingDelegate?.shouldNavBack()
    }
    func searchAll(searchName:String){
        let params = ["search_text":searchName]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getAllSearch,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("SearchAllRes ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    self.searchData.removeAll()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["search_data"] as? [[String:Any]] ?? []
                            print("SearchResultssssssss--- \(results)")
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let parkingName = result["parking_name"] as? String ?? ""
                                let categoryId = result["category_id"] as? String ?? ""
                                let vehicleType = String(result["vehicle_type"] as? Int ?? 0)
                                let typeOfVehicle = String(result["type_of_vehicle"] as? Int ?? 0)
                                let userName = result["user_name"] as? String ?? ""
                                let name = result["name"] as? String ?? ""
                                let description = result["description"] as? String ?? ""
                                let image = result["image"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let twoWpCost = String(result["two_wp_cost"] as? Int ?? 0)
                                let fourWpCost = String(result["four_wp_cost"] as? Int ?? 0)
                                let address = result["address"] as? String ?? ""
                                let type = result["type"] as? String ?? ""
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let twoWheelerAvailableParking = String(result["two_wheeler_available_parking"] as? Int ?? 0)
                                let fourWheelerAvailableParking = String(result["four_wheeler_available_parking"] as? Int ?? 0)
                                let model = AllSearchModel(id: id, parkingName: parkingName, categoryId: categoryId, vehicleType: vehicleType, typeOfVehicle: typeOfVehicle, userName: userName, name: name, description: description, image: image, startOpeningHours: startOpeningHours, endOpeningHours: endOpeningHours, address: address, type: type,twoWpCost: twoWpCost, fourWpCost:fourWpCost, lat:lat, long:long, twoWheelerAvailableParking: twoWheelerAvailableParking, fourWheelerAvailableParking:fourWheelerAvailableParking)
                                self.searchData.append(model)
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
extension SearchAllVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllSearchTVC", for: indexPath) as! AllSearchTVC
        cell.selectionStyle = .none
        if searchData[indexPath.row].type == "service" || searchData[indexPath.row].type == "mechbrainservice"{
            cell.ServiceView.isHidden = false
            cell.ProviderView.isHidden = true
            cell.ParkingView.isHidden = true
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL + searchData[indexPath.row].image)
            DispatchQueue.main.async {
                cell.ServiceImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], completed: nil)
            }
            cell.ServiceNameLbl.text = searchData[indexPath.row].name
            cell.ServiceDescLbl.text = searchData[indexPath.row].description
        } else if searchData[indexPath.row].type == "provider" || searchData[indexPath.row].type == "mechbrainprovider"{
            cell.ServiceView.isHidden = true
            cell.ProviderView.isHidden = false
            cell.ParkingView.isHidden = true
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL + searchData[indexPath.row].image)
            DispatchQueue.main.async {
                cell.ProviderImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], completed: nil)
            }
            cell.ProviderNameLbl.text = searchData[indexPath.row].name
            cell.ProviderDisLbl.text = "2 km"
            cell.ProviderTimeLbl.text = searchData[indexPath.row].startOpeningHours+" To "+searchData[indexPath.row].endOpeningHours
            cell.ProviderPickUpLbl.text = "Pickup Available"
            if searchData[indexPath.row].vehicleType == "1"{
                cell.ProviderCarImg.isHidden = true
                cell.ProviderBikeImg.isHidden = false
            } else if searchData[indexPath.row].vehicleType == "2"{
                cell.ProviderCarImg.isHidden = false
                cell.ProviderBikeImg.isHidden = true
            } else{
                cell.ProviderCarImg.isHidden = false
                cell.ProviderBikeImg.isHidden = false
            }
            cell.ProviderAddLbl.text = searchData[indexPath.row].address
        } else{
            cell.ServiceView.isHidden = true
            cell.ProviderView.isHidden = true
            cell.ParkingView.isHidden = false
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BASE_PARKING_URL + searchData[indexPath.row].image)
            DispatchQueue.main.async {
                cell.ParkingImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "parkingPlaceholderImg"), options: [], completed: nil)
            }
            cell.ParkingNameLbl.text = searchData[indexPath.row].name
            cell.ParkingDisLbl.text = "2 km"
            cell.ParkingTimeLbl.text = "Closes "+searchData[indexPath.row].endOpeningHours
            let CarHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            CarHrs.append(NSAttributedString(string: " \(searchData[indexPath.row].fourWpCost)/Hr", attributes: [.foregroundColor:UIColor.darkGray]))
            let BikeHrs = NSMutableAttributedString(string: "₹", attributes: [.foregroundColor:UIColor.green])
            BikeHrs.append(NSAttributedString(string: " \(searchData[indexPath.row].twoWpCost)/Hr", attributes: [.foregroundColor:UIColor.darkGray]))
            cell.ParkingCarHrsLbl.attributedText = CarHrs
            cell.ParkingBikeHrsLbl.attributedText = BikeHrs
            if searchData[indexPath.row].typeOfVehicle == "1"{
                cell.ParkingCarImg.isHidden = true
                cell.ParkingCarHrsLbl.isHidden = true
                cell.ParkingBikeImg.isHidden = false
                cell.ParkingBikeHrsLbl.isHidden = false
            } else if searchData[indexPath.row].typeOfVehicle == "2"{
                cell.ParkingCarImg.isHidden = false
                cell.ParkingCarHrsLbl.isHidden = false
                cell.ParkingBikeImg.isHidden = true
                cell.ParkingBikeHrsLbl.isHidden = true
            } else{
                cell.ParkingCarImg.isHidden = false
                cell.ParkingCarHrsLbl.isHidden = false
                cell.ParkingBikeImg.isHidden = false
                cell.ParkingBikeHrsLbl.isHidden = false
            }
            cell.ParkingAddLbl.text = searchData[indexPath.row].address
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchData[indexPath.row].type == "service"{
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CategoryProvidersVC") as! CategoryProvidersVC
            vc.ServiceDataServiceId = searchData[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else if searchData[indexPath.row].type == "provider"{
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
            vc.ProviderID = searchData[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else if searchData[indexPath.row].type == "mechbrainservice"{
            let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainCategoryProviderVC") as! MechbrainCategoryProviderVC
            vc.ServiceDataServiceId = searchData[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else if searchData[indexPath.row].type == "mechbrainprovider"{
            let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainProviderDetailsVC") as! MechbrainProviderDetailsVC
            vc.ProviderID = searchData[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            self.parkingModel = NearbyPlaceModel(image: searchData[indexPath.row].image, parkingName: searchData[indexPath.row].name, address: searchData[indexPath.row].address, mobileNumber: "", startOpeningHours: searchData[indexPath.row].startOpeningHours, typeOfVehicle: searchData[indexPath.row].typeOfVehicle, twoWheelerCost: searchData[indexPath.row].twoWpCost, fourWheelerCost: searchData[indexPath.row].fourWpCost, lat: searchData[indexPath.row].lat, long: searchData[indexPath.row].long, placeId: searchData[indexPath.row].id, twoWheelerAvailableParking: searchData[indexPath.row].twoWheelerAvailableParking, distance: "", fourWheelerAvailableParking: searchData[indexPath.row].fourWheelerAvailableParking, endOpeningHours: searchData[indexPath.row].endOpeningHours)
            self.showBottomSheet(model: self.parkingModel!)
        }
    }
}
extension SearchAllVC : UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchedText = textField.text ?? ""
        searchData.removeAll()
        if textField.text != nil && textField.text != "" && textField.text!.count > 1{
            self.searchAll(searchName: textField.text!)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
// MARK:- ParkingPlaceVCDelegate extension
extension SearchAllVC: ParkingPlaceVCDelegate {
    func sliderReachedToEnd(model: NearbyPlaceModel?) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
        vc.nearbyModel = model
        vc.myCarsDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK:- DefaultDelegate for my cars
extension SearchAllVC: DefaultDelegate{
    func shouldNavBack() {
        
    }
}
// MARK: FPC Delegate
extension SearchAllVC:FloatingPanelControllerDelegate {
    
}
