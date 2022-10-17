//
//  SearchMechbrainServicesVC.swift
//  MechUni
//
//  Created by Aniket Patil on 10/10/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImageWebPCoder

class SearchMechbrainServicesVC: UIViewController {
    
    @IBOutlet weak var searchShadowView: ShadowView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var backBtnImg: UIImageView!

    var searchServiceDelegate: DefaultDelegate? = nil
    private var searchServices: [SearchServiceModel] = []
    var ServiceFor = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchShadowView.shadowCornerRadius = searchShadowView.bounds.height/2
        tableView.register(UINib(nibName: "SearchServicesTVC", bundle: nil), forCellReuseIdentifier: "SearchServicesTVC")
        tfSearch.borderStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tfSearch.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        backBtnImg.isUserInteractionEnabled = true
        backBtnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction)))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //showBottomSheet()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: true)
        searchServiceDelegate?.shouldNavBack()
    }
    func searchServicesAPI(searchName:String){
        let params:[String:Any] = ["search_text":searchName]
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request(APIEndPoints.mechbrainSearchServices, method: .post,parameters: params,headers: nil).responseJSON { apiResponse in
                print("SearchApiResponse ----- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    self.searchServices.removeAll()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["search_data"] as? [[String:Any]] ?? []
                            print("SearchResultsss--- \(results)")
                            for result in results{
                                let _id = result["_id"] as? String ?? ""
                                let image = result["image"] as? String ?? ""
                                let address = result["address"] as? String ?? ""
                                let startOpeningHours = result["start_opening_hours"] as? String ?? ""
                                let endOpeningHours = result["end_opening_hours"] as? String ?? ""
                                let typeOfVehicle = String(result["vehicle_type"] as? Int ?? 0)
                                let categoryId = result["category_id"] as? String ?? ""
                                let name = result["name"] as? String ?? ""
                                let description = result["description"] as? String ?? ""
                                let type = result["type"] as? String ?? ""
                               
                                let model = SearchServiceModel(id: _id, image: image, address: address, startOpeningHours: startOpeningHours, endOpeningHours: endOpeningHours, vehicleType: typeOfVehicle, categoryId: categoryId, name: name, description: description, type: type)
                                self.searchServices.append(model)
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
extension SearchMechbrainServicesVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchServices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchServicesTVC") as! SearchServicesTVC
        cell.selectionStyle = .none
        if searchServices[indexPath.row].type == "provider"{
            cell.ProviderView.isHidden = false
            cell.ServiceView.isHidden = true
            cell.ProviderNameLbl.text = searchServices[indexPath.row].name
            cell.ProviderTimeLbl.text = "\(searchServices[indexPath.row].startOpeningHours) To \(searchServices[indexPath.row].endOpeningHours)"
            cell.ProviderAddLbl.text = searchServices[indexPath.row].address
            let webPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(webPCoder)
            let webpURL = URL(string: APIEndPoints.BaseURL+searchServices[indexPath.row].image)
            DispatchQueue.main.async {
                cell.ProviderImg.sd_setImage(with: webpURL, placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], completed: nil)
            }
            if searchServices[indexPath.row].vehicleType == "1"{
                cell.TwoWheelImg.isHidden = false
                cell.FourWheelImg.isHidden = true
            } else if searchServices[indexPath.row].vehicleType == "2"{
                cell.TwoWheelImg.isHidden = true
                cell.FourWheelImg.isHidden = false
            } else{
                cell.TwoWheelImg.isHidden = false
                cell.FourWheelImg.isHidden = false
            }
        } else{
            cell.ProviderView.isHidden = true
            cell.ServiceView.isHidden = false
            cell.ServiceNameLbl.text = searchServices[indexPath.row].name
            cell.ServiceDescrip.text = searchServices[indexPath.row].description
            cell.ServiceImg.sd_setImage(with: URL(string: APIEndPoints.BaseURL + "\(searchServices[indexPath.row].image)"), placeholderImage: #imageLiteral(resourceName: "Cleaning"), options: [], context: nil)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchServices[indexPath.row].type == "provider"{
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ProviderDetailsVC") as! ProviderDetailsVC
            vc.ProviderID = searchServices[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            let vc = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "CategoryProvidersVC") as! CategoryProvidersVC
            vc.ServiceDataServiceId = searchServices[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension SearchMechbrainServicesVC : UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchServices.removeAll()
        if textField.text != nil && textField.text != "" && textField.text!.count > 2{
            self.searchServicesAPI(searchName: textField.text!)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
