//
//  ServiceDetailsVC.swift
//  ValetParking
//
//  Created by Apple on 09/04/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import ImageSlideshow
import SDWebImageWebPCoder
import SafariServices

struct servicesByServiceModel {
    let serviceImages: [String]
    let id, serviceId, providerId, serviceCost, requiredTime, serviceDescription, serviceName, providerName, providerAdd, providerLat, providerLong, providerStartHours, ProviderEndHours, vehicleType: String
    let pickupAvailable, addedInCart: Bool
}
struct otherServicesModel {
    let serviceImages: [String]
    let id, cartId, serviceId, providerId, serviceCost, serviceName, categoryName, vehicleType: String
    let pickupAvailable, addedInCart : Bool
}

class ServiceDetailsVC: UIViewController {

    @IBOutlet weak var ServiceNameLbl: UILabel!
    @IBOutlet weak var backBtnImg: UIImageView!
    @IBOutlet weak var ServicesImages: ImageSlideshow!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var PickupLbl: UILabel!
    @IBOutlet weak var ServiceDetailLbl: UILabel!
    @IBOutlet weak var AmountLbl: UILabel!
    @IBOutlet weak var ForWheeler: UIImageView!
    @IBOutlet weak var TwoWheeler: UIImageView!
    @IBOutlet weak var ProviderNameLbl: UILabel!
    @IBOutlet weak var ProviderAddLbl: UILabel!
    @IBOutlet weak var ProviderNavImg: UIImageView!
    @IBOutlet weak var ProviderKMLbl: UILabel!
    
    @IBOutlet weak var WhatsIncludedTBV: UITableView!
    @IBOutlet weak var OtherServicesTV: UITableView!
    @IBOutlet weak var AddtoCartBtn: UIButton!
    @IBOutlet weak var ViewCartView: UIView!
    @IBOutlet weak var ViewCartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var WhatsIncludeTBVHeight: NSLayoutConstraint!
    @IBOutlet weak var ItemsDetailsLbl: UILabel!
    @IBOutlet weak var ViewCartBtn: UIButton!

    var ServicesVCDelegate: DefaultDelegate? = nil
    var ServicesImagesData: [SDWebImageSource] = []
    var WhatsIncludedData: [String] = []
    var AddCartValue = false
    var OtherService = false
    var _id = String()
    var ServiceId = String()
    var ProviderId = String()
    var ServicesData: ProviderServicesModel? = nil
    var serviceDetails: [servicesByServiceModel] = []
    var otherServices: [otherServicesModel] = []
    var ProviderLat = String()
    var ProviderLong = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
        ViewCartBtn.layer.cornerRadius = ViewCartBtn.frame.height/2
        ViewCartBtn.layer.borderColor = UIColor.red.cgColor
        AddtoCartBtn.layer.borderWidth = 1.5
        AddtoCartBtn.layer.borderColor = UIColor.red.cgColor
        AddtoCartBtn.layer.cornerRadius = AddtoCartBtn.bounds.height/2
        ViewCartView.layer.borderWidth = 1.5
        ViewCartView.layer.borderColor = UIColor.gray.cgColor
        ViewCartView.layer.cornerRadius = ViewCartView.bounds.height/2
        TimeLbl.superview?.layer.cornerRadius = 13
        TimeLbl.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        TimeLbl.superview?.layer.shadowRadius = 3
        TimeLbl.superview?.layer.shadowOpacity = 0.3
        TimeLbl.superview?.layer.shadowColor = UIColor.black.cgColor
        PickupLbl.superview?.layer.cornerRadius = 13
        PickupLbl.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
        PickupLbl.superview?.layer.shadowRadius = 3
        PickupLbl.superview?.layer.shadowOpacity = 0.3
        PickupLbl.superview?.layer.shadowColor = UIColor.black.cgColor
        ServicesImages.delegate = self
        ServicesImages.slideshowInterval = 3.0
        ServicesImages.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        ServicesImages.contentScaleMode = UIViewContentMode.scaleToFill
        ServicesImages.activityIndicator = DefaultActivityIndicator()
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
        pageIndicator.pageIndicatorTintColor = UIColor.black
        ServicesImages.pageIndicator = pageIndicator
        OtherServicesTV.delegate = self
        OtherServicesTV.dataSource = self
        OtherServicesTV.register(UINib(nibName: "OtherServicesTVC", bundle: nil), forCellReuseIdentifier: "OtherServicesTVC")
        OtherServicesTV.rowHeight = UITableView.automaticDimension
        OtherServicesTV.estimatedRowHeight = 80
        OtherServicesTV.showsVerticalScrollIndicator = false
        WhatsIncludedTBV.delegate = self
        WhatsIncludedTBV.dataSource = self
        WhatsIncludedTBV.isScrollEnabled = false
        WhatsIncludedTBV.showsVerticalScrollIndicator = false
        WhatsIncludedTBV.separatorStyle = .none
        backBtnImg.isUserInteractionEnabled = true
        backBtnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
        ViewCartBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CartAction)))
        ProviderNavImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(findRoute)))
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name("AppEnterForeground"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APICALLS()
    }
    @objc func appMovedToForeground() {
        APICALLS()
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: false)
    }
    @objc func CartAction(){
        let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CartDetailsVC") as! CartDetailsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func addToCartAction(_ sender: UIButton){
        OtherService = false
        AddtoCartAPI(ServiceId: _id, ProviderId: ProviderId)
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func APICALLS(){
        CartCountAPI()
        ServiceDetailsAPI(serviecId: ServiceId, providerId: ProviderId)
    }
    @objc func findRoute(){
        print("Lat: \(ProviderLat)\nLong: \(ProviderLong)")
        let appleURL = "http://maps.apple.com/?daddr=\(ProviderLat),\(ProviderLong)"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        present(sfVc, animated: true, completion: nil)
    }
}
class WhatsIncludedTVC: UITableViewCell {
    @IBOutlet weak var TickImg: UIImageView!
    @IBOutlet weak var WhatsIncludedLbl: UILabel!
}
extension ServiceDetailsVC : UITableViewDelegate, UITableViewDataSource{
    @objc func addtocart(_ sender: UITapGestureRecognizer){
        OtherService = true
        AddtoCartAPI(ServiceId: otherServices[sender.view?.tag ?? 0].id, ProviderId: otherServices[sender.view?.tag ?? 0].providerId)
    }
    @objc func removeCart(_ sender: UITapGestureRecognizer){
        RemoveCartAPI(cartId: otherServices[sender.view?.tag ?? 0].cartId)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == WhatsIncludedTBV{
            return WhatsIncludedData.count
        } else{
            return otherServices.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == WhatsIncludedTBV{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhatsIncludedTVC") as! WhatsIncludedTVC
            cell.WhatsIncludedLbl.text = WhatsIncludedData[indexPath.row]
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherServicesTVC") as! OtherServicesTVC
            cell.selectionStyle = .none
            cell.AddCartBtn.tag = indexPath.row
            cell.DeleteCartBtn.tag = indexPath.row
            if otherServices.count != 0{
                if otherServices[indexPath.row].serviceImages.count != 0{
                    let firstletter = otherServices[indexPath.row].serviceImages[0].first!
                    if firstletter == "/"{
                        let webpURL = URL(string: APIEndPoints.BaseURL + otherServices[indexPath.row].serviceImages[0].dropFirst())
                        DispatchQueue.main.async {
                            cell.ServiceImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
                        }
                    } else{
                        let webpURL = URL(string: APIEndPoints.BaseURL + otherServices[indexPath.row].serviceImages[0])
                        DispatchQueue.main.async {
                            cell.ServiceImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
                        }
                    }
                } else{
                    cell.ServiceImg.image = #imageLiteral(resourceName: "Cleaning")
                }
                cell.ServiceName.text = otherServices[indexPath.row].serviceName
                if otherServices[indexPath.row].categoryName == ""{
                    cell.ServiceDetail.text = " "
                } else{
                    cell.ServiceDetail.text = otherServices[indexPath.row].categoryName
                }
                cell.ServiceCost.text = "Rs.\(otherServices[indexPath.row].serviceCost)"
                if otherServices[indexPath.row].pickupAvailable == true{
                    cell.PickupImg.isHidden = false
                } else{
                    cell.PickupImg.isHidden = true
                }
                if otherServices[indexPath.row].vehicleType == "1"{
                    cell.CarImg.isHidden = true
                    cell.BikeImg.isHidden = false
                } else if otherServices[indexPath.row].vehicleType == "2"{
                    cell.CarImg.isHidden = false
                    cell.BikeImg.isHidden = true
                } else{
                    cell.CarImg.isHidden = false
                    cell.BikeImg.isHidden = false
                }
                if otherServices[indexPath.row].addedInCart == true{
                    cell.AddCartBtn.isHidden = true
                    cell.DeleteCartBtn.isHidden = false
                    cell.DeleteCartBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeCart(_:))))
                } else{
                    cell.AddCartBtn.isHidden = false
                    cell.DeleteCartBtn.isHidden = true
                    cell.AddCartBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addtocart(_:))))
                }
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == OtherServicesTV{
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailsVC") as! ServiceDetailsVC
            vc._id = otherServices[indexPath.row].id
            vc.ServiceId = otherServices[indexPath.row].serviceId
            vc.ProviderId = otherServices[indexPath.row].providerId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == OtherServicesTV{
            return UITableView.automaticDimension
        }
        return 35
    }
}
extension ServiceDetailsVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
extension ServiceDetailsVC{
    func ServiceDetailsAPI(serviecId: String, providerId: String){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["provider_id":providerId,"service_id":serviecId,"customer_id":Int(userId) ?? 0]
        print("ServiceDetailsParams--- \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.getServicesbyServiceID,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("ServiceDetailsAPIResponse ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    self.serviceDetails.removeAll()
                    self.otherServices.removeAll()
                    self.ServicesImagesData.removeAll()
                    self.WhatsIncludedData.removeAll()
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [[String: Any]] ?? []
                            print("ServiceDetails--- \(results)")
                            for result in results{
                                let id = result["_id"] as? String ?? ""
                                let serviceImages = result["service_images"] as? [String] ?? []
                                let whatsIncluded = result["whats_included"] as? [String] ?? []
                                for whats in whatsIncluded{
                                    self.WhatsIncludedData.append(whats)
                                }
                                let providerName = result["provider_name"] as? String ?? ""
                                let providerAdd = result["address"] as? String ?? ""
                                let lat = result["lat"] as? String ?? ""
                                let long = result["long"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let serviceId = result["service_id"] as? String ?? ""
                                let providerId = result["provider_id"] as? String ?? ""
                                let serviceCost = String(result["service_cost"] as? Int ?? 0)
                                let requiredTime = String(result["required_time"] as? Int ?? 0)
                                let vehicleType = String(result["vehicle_type"] as? Int ?? 0)
                                let serviceDescription = result["service_description"] as? String ?? ""
                                let serviceName = result["service_name"] as? String ?? ""
                                let pickupAvailable = result["pickupAvailable"] as? Bool ?? false
                                let addedInCart = result["added_in_cart"] as? Bool ?? false
                                let model = servicesByServiceModel(serviceImages: serviceImages, id: id, serviceId: serviceId, providerId: providerId, serviceCost: serviceCost, requiredTime: requiredTime, serviceDescription: serviceDescription, serviceName: serviceName,providerName: providerName, providerAdd: providerAdd, providerLat: lat, providerLong: long, providerStartHours: startOpeningHours, ProviderEndHours: endOpeningHours, vehicleType: vehicleType, pickupAvailable: pickupAvailable, addedInCart: addedInCart)
                                self.serviceDetails.append(model)
                            }
                            let otherServices = apiDict["other_services"] as? [[String: Any]] ?? []
                            for other in otherServices{
                                let id = other["_id"] as? String ?? ""
                                let cartId = other["cart_id"] as? String ?? ""
                                let serviceImages = other["service_images"] as? [String] ?? []
                                let providerId = other["provider_id"] as? String ?? ""
                                let serviceId = other["service_id"] as? String ?? ""
                                let serviceCost = String(other["service_cost"] as? Int ?? 0)
                                let categoryName = other["category_name"] as? String ?? ""
                                let serviceName = other["service_name"] as? String ?? ""
                                let pickupAvailable = other["pickupAvailable"] as? Bool ?? false
                                let addedInCart = other["added_in_cart"] as? Bool ?? false
                                let vehicleType = String(other["vehicle_type"] as? Int ?? 0)
                                let model = otherServicesModel(serviceImages: serviceImages, id: id, cartId: cartId, serviceId: serviceId, providerId: providerId, serviceCost: serviceCost, serviceName: serviceName, categoryName: categoryName, vehicleType: vehicleType, pickupAvailable: pickupAvailable, addedInCart: addedInCart)
                                self.otherServices.append(model)
                            }
                            DispatchQueue.main.async {
                                self.CartCountAPI()
                                for data in self.serviceDetails{
                                    for images in data.serviceImages{
                                        if images.count != 0{
                                            let firstLetter = images.first!
                                            if firstLetter == "/" {
                                                self.ServicesImagesData.append(contentsOf: [SDWebImageSource(urlString: APIEndPoints.BaseURL + images.dropFirst(), placeholder: #imageLiteral(resourceName: "Cleaning"))!])
                                            }else{
                                                self.ServicesImagesData.append(contentsOf: [SDWebImageSource(urlString: APIEndPoints.BaseURL + images.removeWhitespaces(), placeholder: #imageLiteral(resourceName: "Cleaning"))!])
                                            }
                                        } else{
                                            self.ServicesImagesData.append(contentsOf: [SDWebImageSource(urlString: "https://conti-engineering.com/wp-content/uploads/2020/03/VehicleIntegration_Header-1024x423.jpg", placeholder: #imageLiteral(resourceName: "Cleaning"))!])
                                        }
                                    }
                                    print("Imagessss---\(self.ServicesImagesData)")
                                    self.ServicesImages.setImageInputs(self.ServicesImagesData)
                                    self.ProviderLat = data.providerLat
                                    self.ProviderLong = data.providerLong
                                    self.ServiceNameLbl.text = data.serviceName
                                    self.ProviderNameLbl.text = data.providerName
                                    self.ProviderAddLbl.text = data.providerAdd
                                    self.TimeLbl.text = "Takes \(data.requiredTime) hrs"
                                    if data.pickupAvailable == true{
                                        self.PickupLbl.text = "Pickup Available"
                                    }else{
                                        self.PickupLbl.text = "Pickup Not Available"
                                    }
                                    self.ServiceDetailLbl.text = data.serviceDescription
                                    self.AmountLbl.text = "Rs.\(data.serviceCost)"
                                    self.AddCartValue = data.addedInCart
                                    if data.addedInCart == false{
                                        self.AddtoCartBtn.backgroundColor = UIColor.white
                                        self.AddtoCartBtn.setTitle("Add to Cart", for: .normal)
                                        self.AddtoCartBtn.setTitleColor(UIColor.red, for: .normal)
                                        self.AddtoCartBtn.isEnabled = true
                                    } else{
                                        self.AddtoCartBtn.backgroundColor = UIColor.red
                                        self.AddtoCartBtn.setTitle("Item Added to Cart", for: .normal)
                                        self.AddtoCartBtn.setTitleColor(UIColor.white, for: .normal)
                                        self.AddtoCartBtn.isEnabled = false
                                    }
                                    if data.vehicleType == "1"{
                                        self.ForWheeler.isHidden = true
                                        self.TwoWheeler.isHidden = false
                                    }else if data.vehicleType == "2"{
                                        self.ForWheeler.isHidden = false
                                        self.TwoWheeler.isHidden = true
                                    } else{
                                        self.ForWheeler.isHidden = false
                                        self.TwoWheeler.isHidden = false
                                    }
                                }
                                let count = self.WhatsIncludedData.count
                                self.WhatsIncludeTBVHeight.constant = CGFloat(count * 35)
                                self.OtherServicesTV.reloadData()
                                self.WhatsIncludedTBV.reloadData()
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
        if Connectivity.isConnectedToInternet
        {
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
                                self.AddCartValue = true
                                if self.OtherService == true{
                                    print("OtherService")
                                } else{
                                    self.AddtoCartBtn.backgroundColor = UIColor.red
                                    self.AddtoCartBtn.setTitle("Item Added to Cart", for: .normal)
                                    self.AddtoCartBtn.setTitleColor(UIColor.white, for: .normal)
                                    self.AddtoCartBtn.isEnabled = false
                                }
                                self.ServiceDetailsAPI(serviecId: ServiceId, providerId: ProviderId)
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
                                self.ServiceDetailsAPI(serviecId: self.ServiceId, providerId: self.ProviderId)
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
                                if count == "0"{
                                    self.ViewCartView.isHidden = true
                                    self.ViewCartViewHeight.constant = 50
                                } else{
                                    let isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
                                    if(isLoggedin == true)
                                    {
                                        self.ViewCartView.isHidden = false
                                        self.ViewCartViewHeight.constant = 110
                                    } else{
                                        self.ViewCartView.isHidden = true
                                        self.ViewCartViewHeight.constant = 50
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.ItemsDetailsLbl.text = "\(count) item | Rs.\(totalAmount)"
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
extension ServiceDetailsVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
