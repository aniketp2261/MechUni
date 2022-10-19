//
//  MechbrainCategoryProviderVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 02/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import SDWebImageWebPCoder

struct MechbrainCategoryProviderModel {
    let providerId, serviceId, providerName, address, mobilenumber, startOpeningHours, endOpeningHours, lat, long, image, serviceName, cartId, serviceCost, vehicleType, distance, timeToReach : String
    let addedInCart, pickupAvailable: Bool
}

class MechbrainCategoryProviderVC: UIViewController {

    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var sortImg: UIImageView!
    @IBOutlet weak var ProviderListTableView: UITableView!
    @IBOutlet weak var NoProviderLbl: UILabel!
    @IBOutlet weak var CartView: UIView!
    @IBOutlet weak var AddedItemLbl: UILabel!
    @IBOutlet weak var ViewCartBtn: UIButton!
    @IBOutlet weak var CartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var closeSortImg: UIImageView!
    @IBOutlet weak var sortTableView: UITableView!
    
    var Userlat = UserDefaults.standard.string(forKey: "CurrentLat") ?? ""
    var Userlng = UserDefaults.standard.string(forKey: "CurrentLong") ?? ""
    var selectedRows = [IndexPath()]
    var sortArray = ["Distance -- Low to High","Distance -- High to Low","Price -- Low to High","Price -- High to Low"]
    var ServiceDataServiceId: String = ""
    var ProviderList: [MechbrainCategoryProviderModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        CartView.layer.borderColor = UIColor.red.cgColor
        CartView.isHidden = true
        CartViewHeight.constant = 0
        ProviderListTableView.delegate = self
        ProviderListTableView.dataSource = self
        ProviderListTableView.estimatedRowHeight = 190
        ProviderListTableView.rowHeight = UITableView.automaticDimension
        ProviderListTableView.register(UINib(nibName: "CategoryProvidersTVC", bundle: nil), forCellReuseIdentifier: "CategoryProvidersTVC")
        sortTableView.delegate = self
        sortTableView.dataSource = self
        sortTableView.reloadData()
        sortTableView.superview?.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        sortImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortAction)))
        closeSortImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortCloseAction)))
        backImg.isUserInteractionEnabled = true
        backImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
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
        ProviderAPI()
    }
    func ProviderAPI(){
        self.getProviderList(ServiceId: ServiceDataServiceId, lat: Userlat, long: Userlng, sortBy: 0)
    }
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func sortAction(){
        sortView.isHidden = false
    }
    @objc func sortCloseAction(){
        sortView.isHidden = true
    }
    @IBAction func ViewCartAction(){
        let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainCartDetailsVC") as! MechbrainCartDetailsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
class MechbrainCategoryProviderSortTVC: UITableViewCell{
    @IBOutlet weak var radImg: UIImageView!
    @IBOutlet weak var sortLbl: UILabel!
}
extension MechbrainCategoryProviderVC : UITableViewDelegate, UITableViewDataSource{
    @objc func AddCartAction(_ sender: UITapGestureRecognizer){
        self.AddtoCartAPI(ServiceId: ProviderList[sender.view?.tag ?? 0].serviceId, ProviderId: ProviderList[sender.view?.tag ?? 0].providerId)
    }
    @objc func RemoveCartAction(_ sender: UITapGestureRecognizer){
        self.RemoveCartAPI(cartId: ProviderList[sender.view?.tag ?? 0].cartId)
    }
    @objc func ServiceDetails(_ sender: UITapGestureRecognizer){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FromProvider"), object: nil)
        let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainServiceDetailsVC") as! MechbrainServiceDetailsVC
        vc._id = self.ProviderList[sender.view?.tag ?? 0].serviceId
        vc.ServiceId = self.ServiceDataServiceId
        vc.ProviderId = self.ProviderList[sender.view?.tag ?? 0].providerId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ProviderListTableView{
            return ProviderList.count
        } else{
            return sortArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ProviderListTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryProvidersTVC") as! CategoryProvidersTVC
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL+ProviderList[indexPath.row].image)
            DispatchQueue.main.async {
                cell.ProviderImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
            }
            cell.ProviderName.text = ProviderList[indexPath.row].providerName
            cell.TimeLbl.text = ProviderList[indexPath.row].startOpeningHours+" To "+ProviderList[indexPath.row].endOpeningHours
            cell.ServiceName.text = ProviderList[indexPath.row].serviceName
            cell.ServiceName.isUserInteractionEnabled = true
            cell.ServiceName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ServiceDetails(_:))))
            cell.ServiceCost.text = "Rs."+ProviderList[indexPath.row].serviceCost
            cell.LocationLbl.text = ProviderList[indexPath.row].address
            cell.AddtocartBtn.tag = indexPath.row
            cell.RemovecartBtn.tag = indexPath.row
            cell.ServiceName.tag = indexPath.row
            cell.AddtocartBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddCartAction(_:))))
            cell.RemovecartBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RemoveCartAction(_:))))
            if ProviderList[indexPath.row].vehicleType == "1"{
                cell.TwoWheelerImg.isHidden = false
                cell.FourWheelerImg.isHidden = true
            }else if ProviderList[indexPath.row].vehicleType == "2"{
                cell.TwoWheelerImg.isHidden = true
                cell.FourWheelerImg.isHidden = false
            } else{
                cell.TwoWheelerImg.isHidden = false
                cell.FourWheelerImg.isHidden = false
            }
            if ProviderList[indexPath.row].pickupAvailable == true{
                cell.PickUpLbl.text = "Pickup Available."
            }else{
                cell.PickUpLbl.text = "Pickup Not Available."
            }
            if ProviderList[indexPath.row].addedInCart == true{
                cell.AddtocartBtn.isHidden = true
                cell.RemovecartBtn.isHidden = false
            }else{
                cell.AddtocartBtn.isHidden = false
                cell.RemovecartBtn.isHidden = true
            }
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MechbrainCategoryProviderSortTVC") as! MechbrainCategoryProviderSortTVC
            cell.sortLbl.text = sortArray[indexPath.row]
            if selectedRows.contains(indexPath){
                cell.radImg.image = #imageLiteral(resourceName: "ic_red_radio_circleFill").withColor(.black)
            } else{
                cell.radImg.image = #imageLiteral(resourceName: "ic_red_radio_circle").withColor(.black)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ProviderListTableView{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FromProvider"), object: nil)
            let vc = UIStoryboard(name: "Mechbrain", bundle: nil).instantiateViewController(withIdentifier: "MechbrainProviderDetailsVC") as! MechbrainProviderDetailsVC
            vc.ProviderID = ProviderList[indexPath.row].providerId
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            self.sortCloseAction()
            self.getProviderList(ServiceId: ServiceDataServiceId, lat: Userlat, long: Userlng, sortBy: indexPath.row+1)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == ProviderListTableView{
            return UITableView.automaticDimension
        } else{
            return 35
        }
    }
}
extension MechbrainCategoryProviderVC{
    func getProviderList(ServiceId:String, lat:String, long:String, sortBy: Int){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["service_id":ServiceId,"lat":lat,"long":long,"customer_id":Int(userId) ?? 0,"sort_by":sortBy]
        print("Params -- \(params)")
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.mechbrainProviderByService,method: .post,parameters: params, encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("getProviderListResponse ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [[String:Any]] ?? []
                            print("getProviderListResults--- \(results)")
                            self.ProviderList.removeAll()
                            for result in results{
                                let providerId = result["provider_id"] as? String ?? ""
                                let serviceId = result["service_id"] as? String ?? ""
                                let providerName = result["provider_name"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let mobilenumber = result["mobilenumber"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let image = result["image"] as? String ?? ""
                                let addedInCart = result["added_in_cart"] as? Bool ?? false
                                let serviceName = result["service_name"] as? String ?? ""
                                let cartId = result["cart_id"] as? String ?? ""
                                let serviceCost = String(result["service_cost"] as? Int ?? 0)
                                let pickupAvailable = result["pickupAvailable"] as? Bool ?? false
                                let vehicleType = String(result["vehicle_type"] as? Int ?? 0)
                                let distance = result["distance"] as? String ?? ""
                                let timeToReach = result["time_to_reach"] as? String ?? ""

                                let model = MechbrainCategoryProviderModel(providerId: providerId, serviceId: serviceId, providerName: providerName, address: address, mobilenumber: mobilenumber, startOpeningHours: startOpeningHours, endOpeningHours: endOpeningHours, lat: lat, long: long, image: image, serviceName: serviceName, cartId: cartId, serviceCost: serviceCost, vehicleType: vehicleType, distance: distance, timeToReach: timeToReach, addedInCart: addedInCart, pickupAvailable: pickupAvailable)
                                print("ProviderList----- \(model)")
                                self.ProviderList.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.ProviderList.count == 0{
                                    self.NoProviderLbl.isHidden = false
                                } else{
                                    self.NoProviderLbl.isHidden = true
                                }
                                self.CartCountAPI()
                                self.ProviderListTableView.reloadData()
                            }
                        }
                    }
                case .failure(_):
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
    func AddtoCartAPI(ServiceId: String, ProviderId: String){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["service_id":ServiceId,"provider_id":ProviderId,"customer_id": Int(userId) ?? 0]
        print("AddToCartParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainAddtoCart, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                print("AddtoCartAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            self.view.makeToast(message)
                            DispatchQueue.main.async {
                                self.ProviderAPI()
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
                                self.ProviderAPI()
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
    func CartCountAPI(){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["customer_id": Int(userId) ?? 0]
        print("CartCountParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.mechbrainCartCount,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
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
                                        self.CartView.isHidden = true
                                        self.CartViewHeight.constant = 0
                                    } else{
                                        let isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
                                        if(isLoggedin == true)
                                        {
                                            self.CartView.isHidden = false
                                            self.CartViewHeight.constant = 55
                                            self.AddedItemLbl.text = "\(count) item | Rs.\(totalAmount)"
                                        } else{
                                            self.CartView.isHidden = true
                                            self.CartViewHeight.constant = 0
                                        }
                                    }
                                    self.ProviderListTableView.reloadData()
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

