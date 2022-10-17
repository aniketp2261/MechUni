//
//  ProviderDetailsVC.swift
//  MechUni
//
//  Created by Sachin Patil on 24/05/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import SDWebImage
import ImageSlideshow
import SafariServices
import SDWebImageWebPCoder

struct GetServicesByProviderModel {
    let serviceList : [[String: Any]]
    let pickupavai : Bool
    let userName, image, email, start_opening_hours, end_opening_hours, mobilenumber, provider_id, address, lat, long, companyId : String
}
struct ProviderServicesModel {
    let id, serviceId, providerId,cartId, serviceCost, serviceName, categoryName, vehicleType: String
    let pickupAvailable, addedinCart: Bool
    let servicesImages: [String]
}

class ProviderDetailsVC: UIViewController {
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var ProviderNameLbl: UILabel!
    @IBOutlet weak var ProviderImage: ImageSlideshow!
    @IBOutlet weak var ProviderAddressLbl: UILabel!
    @IBOutlet weak var ProviderTimeLbl: UILabel!
    @IBOutlet weak var ProviderPickupLbl: UILabel!
    @IBOutlet weak var ProviderNavImg: UIImageView!
    @IBOutlet weak var ProviderKMLbl: UILabel!
    @IBOutlet weak var ServicesTableView: UITableView!
    @IBOutlet weak var CartView: UIView!
    @IBOutlet weak var AddedItemLbl: UILabel!
    @IBOutlet weak var ViewCartBtn: UIButton!
    @IBOutlet weak var CartViewHeight: NSLayoutConstraint!
    
    var ProviderDetailsSerVCDelegate: ServicesCatVCDelegate? = nil
    var ProviderDetailsHomeVCDelegate: DefaultDelegate? = nil

    var ProviderID: String = ""
    var ProviderDetails: [GetServicesByProviderModel] = []
    var ServicesData: [ProviderServicesModel] = []
    var images: [SDWebImageSource] = []
    var providerID = String()
    var ProviderLat = String()
    var ProviderLong = String()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
        print("NearbyServiceProviderModel---\(ProviderDetails)")
        ServicesTableView.separatorStyle = .none
        CartView.layer.borderColor = UIColor.red.cgColor
        CartView.isHidden = true
        CartViewHeight.constant = 0
        ProviderImage.delegate = self
        ProviderImage.slideshowInterval = 5.0
        ProviderImage.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        ProviderImage.contentScaleMode = UIViewContentMode.scaleToFill
        ProviderImage.activityIndicator = DefaultActivityIndicator()
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
        pageIndicator.pageIndicatorTintColor = UIColor.black
        ProviderImage.pageIndicator = pageIndicator
        ServicesTableView.register(UINib(nibName: "ProviderServicesTVC", bundle: nil), forCellReuseIdentifier: "ProviderServicesTVC")
        ServicesTableView.dataSource = self
        ServicesTableView.delegate = self
        ServicesTableView.rowHeight = UITableView.automaticDimension
        ServicesTableView.estimatedRowHeight = 100
        ServicesTableView.showsVerticalScrollIndicator = false
        backImg.isUserInteractionEnabled = true
        backImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
        ProviderNavImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(findRoute)))
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name("AppEnterForeground"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        APICALLS()
    }
    @objc func appMovedToForeground() {
        APICALLS()
    }
    func APICALLS(){
        CartCountAPI()
        ProviderDetailsAPI(id: ProviderID)
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: false)
        ProviderDetailsSerVCDelegate?.ServicesNavigationBack()
        ProviderDetailsHomeVCDelegate?.shouldNavBack()
    }
    @IBAction func ViewCartAction(){
        let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CartDetailsVC") as! CartDetailsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func findRoute(){
        print("Lat: \(ProviderLat)\nLong: \(ProviderLong)")
        let appleURL = "http://maps.apple.com/?daddr=\(ProviderLat),\(ProviderLong)"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        present(sfVc, animated: true, completion: nil)
    }
}
extension ProviderDetailsVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
//        print("Current Page:", page)
    }
}
extension ProviderDetailsVC: UITableViewDelegate, UITableViewDataSource{
    @objc func addtocart(_ sender: UITapGestureRecognizer){
        AddtoCartAPI(ServiceId: ServicesData[sender.view?.tag ?? 0].id, ProviderId: ServicesData[sender.view?.tag ?? 0].providerId)
    }
    @objc func removecart(_ sender: UITapGestureRecognizer){
        RemoveCartAPI(cartId: ServicesData[sender.view?.tag ?? 0].cartId)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ServicesData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderServicesTVC") as! ProviderServicesTVC
        let AddCartTap = UITapGestureRecognizer(target: self, action: #selector(addtocart(_:)))
        let RemoveCartTap = UITapGestureRecognizer(target: self, action: #selector(removecart(_:)))
        cell.selectionStyle = .none
        cell.AddCartBtn.tag = indexPath.row
        cell.DeleteCartBtn.tag = indexPath.row
        if ServicesData.count != 0{
            if ServicesData[indexPath.row].servicesImages.count != 0{
                let firstletter = ServicesData[indexPath.row].servicesImages[0].first!
                if firstletter == "/"{
                    cell.ServiceImg.sd_setImage(with: URL(string: APIEndPoints.BaseURL + ServicesData[indexPath.row].servicesImages[0].dropFirst()), placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], context: nil)
                } else{
                    cell.ServiceImg.sd_setImage(with: URL(string: APIEndPoints.BaseURL + ServicesData[indexPath.row].servicesImages[0]), placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], context: nil)
                }
            } else{
                cell.ServiceImg.image = #imageLiteral(resourceName: "Cleaning")
            }
            cell.ServiceName.text = ServicesData[indexPath.row].serviceName
            if ServicesData[indexPath.row].categoryName == ""{
                cell.ServiceDetail.text = " "
            } else{
                cell.ServiceDetail.text = ServicesData[indexPath.row].categoryName
            }
            cell.ServiceCost.text = "Rs.\(ServicesData[indexPath.row].serviceCost)"
            if ServicesData[indexPath.row].vehicleType == "1"{
                cell.CarImg.isHidden = true
                cell.BikeImg.isHidden = false
            } else if ServicesData[indexPath.row].vehicleType == "2"{
                cell.CarImg.isHidden = false
                cell.BikeImg.isHidden = true
            } else{
                cell.CarImg.isHidden = false
                cell.BikeImg.isHidden = false
            }
            if ServicesData[indexPath.row].pickupAvailable == true{
                cell.PickupImg.isHidden = false
            } else{
                cell.PickupImg.isHidden = true
            }
            if ServicesData[indexPath.row].addedinCart == true{
                cell.AddCartBtn.isHidden = true
                cell.DeleteCartBtn.isHidden = false
                cell.DeleteCartBtn.addGestureRecognizer(RemoveCartTap)
                CartView.isHidden = false
                CartViewHeight.constant = 55
            } else{
                cell.AddCartBtn.isHidden = false
                cell.DeleteCartBtn.isHidden = true
                cell.AddCartBtn.addGestureRecognizer(AddCartTap)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DidSelectRowAt---\(indexPath)")
        let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailsVC") as! ServiceDetailsVC
        vc._id = self.ServicesData[indexPath.row].id
        vc.ServiceId = self.ServicesData[indexPath.row].serviceId
        vc.ProviderId = self.ServicesData[indexPath.row].providerId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension ProviderDetailsVC{
    func ProviderDetailsAPI(id: String){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["provider_id":id,"customer_id": Int(userId) ?? 0]
        print("ProviderDetailsParams--- \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.getServicesbyProviderID,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("ProviderDetailsAPIResponse--- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        self.ProviderDetails.removeAll()
                        self.images.removeAll()
                        if status == "success" {
                            let results = apiDict["response_data"] as? [String: Any]
                            print("ProviderDetails--- \(results)")
                            if let result = results{
                                self.ServicesData.removeAll()
                                let serviceList = result["service_list"] as? [[String:Any]] ?? []
                                let userName = result["user_name"] as? String ?? ""
                                let pickup = result["pickup_available"] as? Bool ?? false
                                let image = result["image"] as? String ?? ""
                                let email = result["email"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let mobileNumber = result["mobilenumber"] as? String ?? ""
                                let providerId = result["provider_id"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let companyId = String(result["company_id"] as? Int ?? 0)
                                for data2 in serviceList{
                                    let servicesImages = data2["service_images"] as? [String] ?? []
                                    let id = data2["_id"] as? String ?? ""
                                    let cartId = data2["cart_id"] as? String ?? ""
                                    let providerId = data2["provider_id"] as? String ?? ""
                                    let serviceCost = String(data2["service_cost"] as? Int ?? 0)
                                    let serviceName = data2["service_name"] as? String ?? ""
                                    let pickupAvailable = data2["pickupAvailable"] as? Bool ?? false
                                    let addedInCart = data2["added_in_cart"] as? Bool ?? false
                                    let categoryName = data2["category_name"] as? String ?? ""
                                    let serviceId = data2["service_id"] as? String ?? ""
                                    let vehicleType = String(data2["vehicle_type"] as? Int ?? 0)
                                    let model = ProviderServicesModel(id: id, serviceId: serviceId, providerId: providerId, cartId: cartId, serviceCost: serviceCost, serviceName: serviceName, categoryName: categoryName, vehicleType: vehicleType, pickupAvailable: pickupAvailable, addedinCart: addedInCart, servicesImages: servicesImages)
                                    self.ServicesData.append(model)
                                }
                                let model = GetServicesByProviderModel(serviceList: serviceList, pickupavai: pickup, userName: userName, image: image, email: email, start_opening_hours: startOpeningHours, end_opening_hours: endOpeningHours, mobilenumber: mobileNumber, provider_id: providerId, address: address, lat: lat, long: long, companyId: companyId)
                                print("ProviderDetailsModel---- \(model)")
                                self.ProviderDetails.append(model)
                            }
                            DispatchQueue.main.async {
                                self.CartCountAPI()
                                for data in self.ProviderDetails{
                                    self.ProviderLat = data.lat
                                    self.ProviderLong = data.long
                                    self.providerID = data.provider_id
                                    self.ProviderNameLbl.text = data.userName
                                    self.ProviderAddressLbl.text = data.address
                                    self.ProviderTimeLbl.text = data.start_opening_hours+" To "+data.end_opening_hours
                                    if data.pickupavai == true{
                                        self.ProviderPickupLbl.text = "Pickup Available"
                                    } else{
                                        self.ProviderPickupLbl.text = "Pickup Not Available"
                                    }
                                    if data.image.count != 0{
                                        let firstLetter = data.image.first!
                                        if firstLetter == "/" {
                                            self.images.append(contentsOf: [SDWebImageSource(urlString: APIEndPoints.BaseURL+data.image.dropFirst(), placeholder: #imageLiteral(resourceName: "Cleaning"))!])
                                        }else{
                                            self.images.append(contentsOf: [SDWebImageSource(urlString: APIEndPoints.BaseURL+data.image.removeWhitespaces(), placeholder: #imageLiteral(resourceName: "Cleaning"))!])
                                        }
                                    } else{
                                        self.images.append(contentsOf: [SDWebImageSource(urlString: "https://conti-engineering.com/wp-content/uploads/2020/03/VehicleIntegration_Header-1024x423.jpg", placeholder: #imageLiteral(resourceName: "Cleaning"))!])
                                    }
                                    break
                                }
                                self.ProviderImage.setImageInputs(self.images)
                                self.ServicesTableView.reloadData()
                            }
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
    func AddtoCartAPI(ServiceId: String, ProviderId: String){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["service_id":ServiceId,"provider_id":ProviderId,"customer_id": Int(userId) ?? 0]
        print("AddToCartParams: \(params)")
        if Connectivity.isConnectedToInternet {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.Addtocart,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
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
                                self.ProviderDetailsAPI(id: self.ProviderID)
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
            Alamofire.request(APIEndPoints.RemoveCart,method: .delete,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
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
                                self.ProviderDetailsAPI(id: self.ProviderID)
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
                                        self.CartView.isHidden = true
                                        self.CartViewHeight.constant = 0
                                    } else{
                                        let isLoggedin = UserDefaults.standard.string(forKey: "isLoggedin") ?? "0"
                                        if(isLoggedin == "1") {
                                            self.CartView.isHidden = false
                                            self.CartViewHeight.constant = 55
                                            self.AddedItemLbl.text = "\(count) item | Rs.\(totalAmount)"
                                        } else{
                                            self.CartView.isHidden = true
                                            self.CartViewHeight.constant = 0
                                        }
                                    }
                                    self.ServicesTableView.reloadData()
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
extension ProviderDetailsVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
