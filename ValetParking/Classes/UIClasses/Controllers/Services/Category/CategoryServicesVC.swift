//
//  ServicesCategoryVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 11/06/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import SDWebImageWebPCoder

struct ServicesByCategoryModel {
    let serviceType, serviceName, categoryId, serviceDescription, serviceImage, serviceId, vehicleType: String
}

class CategoryServicesVC: UIViewController {
    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var sortImg: UIImageView!
    @IBOutlet weak var backBtnImg: UIImageView!
    @IBOutlet weak var ServiceListTableView: UITableView!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var closeSortImg: UIImageView!
    @IBOutlet weak var sortTableView: UITableView!
    
    var ServicesCategoryVCDelegate: ServicesCatVCDelegate? = nil
    var CategoryId: String = ""
    var serviceArray: [ServicesByCategoryModel] = []
    var selectedRows = [IndexPath()]
    var sortArray = ["Two Wheeler","Four Wheeler"]{
        didSet{
            DispatchQueue.main.async {
                self.sortTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceListTableView.delegate = self
        ServiceListTableView.dataSource = self
        ServiceListTableView.estimatedRowHeight = 150
        ServiceListTableView.rowHeight = UITableView.automaticDimension
        sortTableView.delegate = self
        sortTableView.dataSource = self
        sortTableView.superview?.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        sortImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortAction)))
        backBtnImg.isUserInteractionEnabled = true
        backBtnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
        closeSortImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortCloseAction)))
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
        getServiceList(CategoryId: CategoryId, vehicleType: 0)
    }
    @objc func sortAction(){
        sortView.isHidden = false
    }
    @objc func sortCloseAction(){
        sortView.isHidden = true
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: false)
        ServicesCategoryVCDelegate?.ServicesNavigationBack()
    }
    func getServiceList(CategoryId: String, vehicleType: Int){
        let params:[String:Any] = ["category_id": CategoryId, "vehicle_type": vehicleType]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.getServicesByCategory,method: .post,parameters: params, encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("getServiceListCategory-Response ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["response_data"] as? [[String:Any]] ?? []
                            print("getServiceListByCategory--- \(results)")
                            self.serviceArray.removeAll()
                            for result in results{
                                let serviceType = String(result["service_type"] as? Int ?? 0)
                                let serviceName = result["service_name"] as? String ?? ""
                                let categoryId = result["category_id"] as? String ?? ""
                                let serviceDescription = result["service_description"] as? String ?? ""
                                let serviceImage = result["service_image"] as? String ?? ""
                                let serviceId = result["service_id"] as? String ?? ""
                                let vehicleType = String(result["vehicle_type"] as? Int ?? 0)
                        
                                let model = ServicesByCategoryModel(serviceType: serviceType, serviceName: serviceName, categoryId: categoryId, serviceDescription: serviceDescription, serviceImage: serviceImage, serviceId: serviceId, vehicleType: vehicleType)
                                print("servicesArray----- \(model)")
                                self.serviceArray.append(model)
                            }
                            DispatchQueue.main.async {
                                if self.serviceArray.count == 0{
                                    self.lbl.isHidden = false
                                } else{
                                    self.lbl.isHidden = true
                                }
                                self.ServiceListTableView.reloadData()
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
class ServiceCategoryTVC: UITableViewCell{
    @IBOutlet weak var ServiceImg: UIImageView!
    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var ServiceDescription: UILabel!
    @IBOutlet weak var FourWheelerImg: UIImageView!
    @IBOutlet weak var TwoWheelerImg: UIImageView!
}
extension CategoryServicesVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ServiceListTableView{
            return serviceArray.count
        } else{
            return sortArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ServiceListTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCategoryTVC", for: indexPath) as! ServiceCategoryTVC
            cell.selectionStyle = .none
            cell.ServiceName.superview?.layer.shadowColor = UIColor.black.cgColor
            cell.ServiceName.superview?.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.ServiceName.superview?.layer.shadowOpacity = 0.3
            cell.ServiceName.superview?.layer.shadowRadius = 3.0
            cell.ServiceName.superview?.layer.cornerRadius = 15
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL+serviceArray[indexPath.row].serviceImage)
            DispatchQueue.main.async {
                cell.ServiceImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
            }
            cell.ServiceName.text = serviceArray[indexPath.row].serviceName
            cell.ServiceDescription.text = serviceArray[indexPath.row].serviceDescription
            if serviceArray[indexPath.row].vehicleType == "1"{
                cell.FourWheelerImg.isHidden = true
                cell.TwoWheelerImg.isHidden = false
            } else if serviceArray[indexPath.row].vehicleType == "2"{
                cell.FourWheelerImg.isHidden = false
                cell.TwoWheelerImg.isHidden = true
            } else{
                cell.FourWheelerImg.isHidden = false
                cell.TwoWheelerImg.isHidden = false
            }
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryProvidersSortTVC") as! CategoryProvidersSortTVC
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
        if tableView == ServiceListTableView{
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CategoryProvidersVC") as! CategoryProvidersVC
            vc.ServiceDataServiceId = serviceArray[indexPath.row].serviceId
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            self.sortCloseAction()
            self.getServiceList(CategoryId: CategoryId, vehicleType: indexPath.row+1)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == ServiceListTableView{
            return UITableView.automaticDimension
        } else{
            return 35
        }
    }
}
