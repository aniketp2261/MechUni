//
//  MyCarsVC.swift
//  ValetParking
//
//  Created by Khushal on 19/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift
import SDWebImage

// delegate to show or hide bottom sheet in home vc to make sure we don't  show the bottom sheet at wrong time
protocol DefaultDelegate {
    func shouldNavBack()
}

class MyCarsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet weak var mCarTV: UITableView!
    
    @IBOutlet weak var noData: UILabel!
    var listArray:[[String:Any]] = []
    //Exit View
    @IBOutlet var mExitView: UIView!
    @IBOutlet weak var addVehicleBtn:UIButton!
    @IBOutlet weak var backBtnImg:UIImageView!
    var nearbyModel:NearbyPlaceModel? = nil
    var myCarsDelegate:DefaultDelegate? = nil
    var isAnyCarParked = false
    var ServiceFlow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ParkingModelll --- \(nearbyModel)")
        addVehicleBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        addVehicleBtn.layer.shadowRadius = 4
        addVehicleBtn.layer.shadowOpacity = 0.4
        addVehicleBtn.layer.shadowColor = UIColor.black.cgColor
        addVehicleBtn.layer.cornerRadius = addVehicleBtn.bounds.height/2
        addVehicleBtn.layer.zPosition = 5
        view.bringSubviewToFront(addVehicleBtn)
//        let nc = NotificationCenter.default
//        nc.post(name: Notification.Name("load"), object: nil)
//        sideMenuController?.isLeftViewSwipeGestureEnabled = true
      self.mCarTV.register(UINib(nibName: "CarCell", bundle: nil), forCellReuseIdentifier: "CarCell")
      let backTap = UITapGestureRecognizer(target: self, action: #selector(backBtnAction))
        backBtnImg.addGestureRecognizer(backTap)
//        NotificationCenter.default.addObserver(self, selector: #selector(observeForNav), name: NSNotification.Name(rawValue: NotificationKeys.navFromMyCarsToHomeScreen.rawValue), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ViewDisplay()
    }
    @objc func observeForNav(){
        navigationController?.popViewController(animated: true)
        myCarsDelegate?.shouldNavBack()
    }
    @objc func backBtnAction(){
        navigationController?.popViewController(animated: true)
        if !isAnyCarParked{
            myCarsDelegate?.shouldNavBack()
        }
    }
    func ViewDisplay(){
        UserDefaults.standard.setValue("myCars", forKey: "SelectedTab")
        let isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
        if(isLoggedin == true)
        {
          listCarApi()
            self.mCarTV.isHidden = false
        } else{
             self.mCarTV.isHidden = true
            let alert = UIAlertView(title: "", message: "Login is required to access this feature", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
            alert.tag = 100
            alert.show()
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 100 {
            if buttonIndex == 1 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        cell.selectionStyle = .none
        if nearbyModel != nil || ServiceFlow == true{
            cell.EditDeleteStackView.isHidden = true
            cell.selectBtn.isHidden = false
        }
        else{
            cell.EditDeleteStackView.isHidden = false
            cell.selectBtn.isHidden = true
        }
        cell.mEditBtn.tag = indexPath.row
        cell.mDelete.tag = indexPath.row
        cell.selectBtn.tag = indexPath.row
        let editTap = UITapGestureRecognizer(target: self, action: #selector(editAction(_:)))
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteAction(_:)))
        let selectTap = UITapGestureRecognizer(target: self, action: #selector(selectAction))
        cell.mEditBtn.addGestureRecognizer(editTap)
        cell.mDelete.addGestureRecognizer(deleteTap)
        cell.selectBtn.addGestureRecognizer(selectTap)
        let plateNumber = listArray[indexPath.row]["plate_no"] as! String
        let vehicleType = listArray[indexPath.row]["vehicle_type"] as? String ?? ""
        let carImg = listArray[indexPath.row]["car_image"] as? String ?? ""
        cell.carNumberLbl.text = "\(plateNumber)"
        if vehicleType == "1"{
            cell.vehicleTypeLbl.text = "Two Wheeler"
            cell.VehicleTypeImg.image = #imageLiteral(resourceName: "icBikeGray")
        }
        else{
            cell.vehicleTypeLbl.text = "Four Wheeler"
            cell.VehicleTypeImg.image = #imageLiteral(resourceName: "icCarGray")
        }
        cell.vehicleImg.sd_setImage(with: URL(string: APIEndPoints.BASE_IMAGE_URL + carImg), placeholderImage: #imageLiteral(resourceName: "mycars-1"), options: [], context: nil)
        return cell
    }
    @objc func selectAction(_ sender:UITapGestureRecognizer){
        let mCell = mCarTV.cellForRow(at: IndexPath(row: sender.view?.tag ?? 0, section: 0)) as? CarCell
        let maindict = self.listArray[sender.view?.tag ?? 0] as NSDictionary
        if ServiceFlow == false{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfirmAndParkVC") as! ConfirmAndParkVC
            vc.nearbyPostModel = nearbyModel
            vc.confirmAndParkDelegate = self
            vc.carId = String(maindict["_id"] as! Int)
            vc.vehicleType = listArray[sender.view?.tag ?? 0]["vehicle_type"] as? String ?? ""
            vc.plateNo = listArray[sender.view?.tag ?? 0]["plate_no"] as? String ?? ""
            vc.img = mCell?.vehicleImg.image
            present(vc, animated: true, completion: nil)
        } else{
            let dict = ["carId":String(maindict["_id"] as? Int ?? 0),"vehicleType":listArray[sender.view?.tag ?? 0]["vehicle_type"] as? String ?? "","plateNo":listArray[sender.view?.tag ?? 0]["plate_no"] as? String ?? "","vehicleImage": listArray[sender.view?.tag ?? 0]["car_image"] as? String ?? ""]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ServiceVehicle"), object: dict)
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func editAction (_ sender: UITapGestureRecognizer){
        let maindict = self.listArray[sender.view?.tag ?? 0] as! NSDictionary
        if #available(iOS 13.0, *) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddVehicleVC") as! AddVehicleVC
            vc.vehiclePlateNo = maindict["plate_no"] as! String
            vc.fileStr = maindict["car_image"] as? String ?? ""
            vc.selectedVehicleType = Int(maindict["vehicle_type"] as? String ?? "") ?? -1
            vc.shouldEditVehicle = true
            vc.selectedCarId = String(maindict["_id"] as! Int)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
//    @objc func editAction (_ sender: UIButton){
//          let maindict = self.listArray[sender.tag] as! NSDictionary
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "CarDetailsVC") as! CarDetailsVC
//        vc.saveType = "editCar"
//        vc.editCarID = (maindict["_id"] as! Int)
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    @objc func deleteAction (_ sender: UITapGestureRecognizer){
        let alert = UIAlertController(title: nil, message: "Are you sure want to delete the car?" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
            let maindict = self.listArray[sender.view?.tag ?? 0] as! NSDictionary
            print(maindict["_id"] as Any)
            let parameters: Parameters =
            [
                "_id_car_details": String(format: "%d",(maindict["_id"] as! Int))
            ]
            self.deleteCarAPI(parameters)
        }))
        self.present(alert, animated: true, completion: nil)
    }
                
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Button Actions
    @IBAction func mNotification(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func mAddCar(_ sender: Any) {
        let isLoggedin =  UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
        if(isLoggedin == true)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CarDetailsVC") as! CarDetailsVC
            vc.saveType = "addCar"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            //self.mExitView.frame = self.view.frame
            //self.view.addSubview(self.mExitView)
            self.view.makeToast("Please Login!")
        }
    }
    @IBAction func addVehicleAction(){
        print("addVehicleAction0000 ----- ")
        if #available(iOS 13.0, *) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddVehicleVC") as! AddVehicleVC
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func goToLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mClose(_ sender: Any) {
        self.mExitView.removeFromSuperview()
    }
    
    //Api
    func deleteCarAPI(_ parameters: Parameters) {
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)car_details/delete_car_Details", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "success" {
                                    SKActivityIndicator.dismiss()
                                    self.listCarApi()
                                }else{
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }
                            } else {
                                self.view.makeToast("Json Error...!!!")
                            }
                        }
                        break
                    case .failure(let error):
                        SKActivityIndicator.dismiss()
                        print(error)
                        
                        break
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
    
    func listCarApi()
    {
        
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
        [
            "_id_customer_table": idValue as Any
        ]
        print("parameters0000 ------ \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)car_details/get_all_car_details", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    print("apiResponse0000 ----- \(response)")
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "failed" {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }else{
                                    SKActivityIndicator.dismiss()
                                    self.listArray = JSON["result"] as! [[String:Any]]
                                    if self.listArray.count > 0 {
                                        self.mCarTV.isHidden = false
                                        self.noData.text = ""
                                        self.mCarTV.reloadData()
                                    }
                                    else{
                                        self.mCarTV.isHidden = true
                                        self.noData.text = "No Data Found!!"
                                    }
                                }
                            } else {
                                self.view.makeToast("Json Error...!!!")
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

    func getToken()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let tokenID =  UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        let parameters: Parameters =
        [
            "_id": idValue as Any,
            "token_id": tokenID
        ]
        print("Noty token -- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(Constants.BASEURL)customer_table/customer_update_token", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                            if status == "failed" {
                                let message = JSON["message"] as? String
                                self.view.makeToast(message);
                            }else{
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
}
extension MyCarsVC: ConfirmAndParkVCDelegate {
    func onTicketCreated() {
        print("onTicketCreated000---")
        let vcIndex = self.navigationController?.viewControllers.firstIndex(where: { (viewController) -> Bool in
            if let _ = viewController as? HomeVC {
                return true
            }
            return false
        })
        let composeVC = self.navigationController?.viewControllers[vcIndex!] as! HomeVC
        self.navigationController?.popToViewController(composeVC, animated: true)
        composeVC.shouldNavBack()
    }
}
