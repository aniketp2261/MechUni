//
//  ParkedCarVC.swift
//  ValetParking
//
//  Created by Khushal on 04/01/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import GoogleMobileAds

class ParkedCarVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mCarImage: UIImageView!
    @IBOutlet weak var mCarDetailsView: UIView!
    
    @IBOutlet weak var carMake: UILabel!
    @IBOutlet weak var mCarNo: UILabel!
    @IBOutlet weak var mCarModel: UILabel!
    @IBOutlet weak var mCarColor: UILabel!
    
    @IBOutlet weak var mTicketsView: UIView!
    @IBOutlet weak var mTicketID: UILabel!
    
    @IBOutlet weak var mTicketNo2: UILabel!
    @IBOutlet weak var getBackTime: UILabel!
    
    @IBOutlet weak var getCarBtn: UIButton!
    @IBOutlet weak var imgBack: UIImageView!

    @IBOutlet weak var mRequestAcceptedView: UIView!
    //Exit View1
    @IBOutlet var mExitView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    
    //Exit View2
    @IBOutlet weak var mNotificationView: UIView!
    @IBOutlet var mTicketExitView: UIView!
    @IBOutlet weak var mUserName: UILabel!
    @IBOutlet weak var mExitCarNo: UILabel!
    @IBOutlet weak var mExitTicketID: UILabel!
    
    
    var interstitial: GADInterstitial!
    var carDetails : NSDictionary = NSDictionary()
    var times = ["10 mins","20 mins","30 mins","40 mins","50 mins","60 mins"]
      let textCellIdentifier = "cell"
    var mType:String?
    var isBack = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mCarDetailsView.layer.cornerRadius = 5
        self.mCarDetailsView.layer.borderWidth = 1
        self.mCarDetailsView.layer.borderColor = UIColor.gray.cgColor
        self.mTicketsView.layer.cornerRadius = 5
        self.mTicketsView.layer.borderWidth = 1
        self.mTicketsView.layer.borderColor = UIColor.gray.cgColor
        self.mRequestAcceptedView.isHidden = true
        self.mRequestAcceptedView.layer.borderWidth = 1
        self.mRequestAcceptedView.layer.borderColor = UIColor.gray.cgColor
         self.mRequestAcceptedView.layer.cornerRadius = 5
        self.getCarBtn.isHidden = true
        if let value = carDetails["ticket_id"]{
            self.mTicketNo2.text = (value as! String)
        }
       
        imgBack.image = UIImage(named: isBack ? "back" : "menu")
        
//       if mType == "requestCar"
//       {
        displayCar()
//        }
//       else{
//        refreshUI()
//        }
        showStatus()
        createGoogleAds()
        
        if self.mType == "requestCar"
        {
            self.mTicketsView.isHidden = false
            self.getCarBtn.isHidden = false
            self.mRequestAcceptedView.isHidden = true
            
        }
        else if self.mType == "carRequested"
        {
            self.mTicketsView.isHidden = true
            self.mRequestAcceptedView.isHidden = true
        }
    }
    
    func showStatus(){
        let selectedType =  UserDefaults.standard.string(forKey: "type")
        if selectedType == "Car delivery request accepted"
        {
            let ticketID =  UserDefaults.standard.string(forKey: "ticketNo")
            self.mTicketNo2.text = ticketID
            self.mTicketsView.isHidden = true
            self.mRequestAcceptedView.isHidden = false
        }
        else
        {
            self.mTicketsView.isHidden = false
            self.mRequestAcceptedView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
//        if selectedType == "Car delivery request accepted"
//        {
//            let ticketID =  UserDefaults.standard.string(forKey: "ticketNo")
//            self.mTicketNo2.text = ticketID
//            self.mTicketsView.isHidden = true
//            self.mRequestAcceptedView.isHidden = false
//        }
        
    }

    
    func refreshUI() {
        let details =  UserDefaults.standard.dictionary(forKey: "parkedCarDetails")
        print(details)
       
      if let val = details?["car_model"]
      {
         self.mCarModel.text = (val as? String)!
        }
       if let val = details?["plate_no"]
       {
        self.mCarNo.text = (val as? String)!
        }
        
        if let val = details?["car_color"]
        {
           self.mCarColor.text = (val as? String)!
        }
        if let val = details?["plate_no"]
        {
            self.mCarNo.text = (val as? String)!
        }
        if let val = details?["car_make"]
        {
             self.carMake.text = val as? String ?? ""
        }
        if let val = details?["car_model"]
        {
           self.mCarModel.text = val as? String ?? ""
        }
       if let val = details?["ticket_id"]
       {
        self.mTicketID.text = val as? String ?? ""
        }
        
        if let actionString = details?["car_image"] as? NSString {
            // action is not nil, is a String type, and is now stored in actionString
            let url = String(format: "%@%@",APIEndPoints.BASE_IMAGE_URL ,actionString)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            self.mCarImage.sd_setImage(with: URL(string: urlString!))
        }
        else {
            
        }
       
    }
    
func displayCar()
{
    
    self.mCarModel.text = carDetails["car_model"] as? String ?? ""
    self.mCarNo.text = carDetails["plate_no"] as? String ?? ""
    self.mCarColor.text = carDetails["car_color"] as? String ?? ""
    self.mTicketID.text = carDetails["ticket_id"] as? String ?? ""
    self.carMake.text = carDetails["car_make"] as? String ?? ""

    
//            self.mTicketNo2.text = (carDetails["ticket_id"] as? String)!
//            print(mTicketNo2.text)
            if let actionString = carDetails["car_image"] as? NSString {
                // action is not nil, is a String type, and is now stored in actionString
                let url = String(format: "%@%@",APIEndPoints.BASE_IMAGE_URL ,actionString)
                
                let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                self.mCarImage.sd_setImage(with: URL(string: urlString!))
            }
            else{
                
            }
    }
    
    
    @IBAction func leftBtnAction(_ sender: Any) {
        if !isBack {
            self.sideMenuController?.showLeftView()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func getMyCar(_ sender: Any) {
//        self.mTicketsView.isHidden = true
//        self.mRequestAcceptedView.isHidden = true
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            self.getMyCar()
        }
    }
    
    @IBAction func getTime(_ sender: Any) {
        self.mExitView.frame = self.view.frame
        self.view.addSubview(self.mExitView)
    }
    
    @IBAction func exitBack(_ sender: Any) {
        self.mExitView.removeFromSuperview()
    }
    
    @IBAction func showTicketView(_ sender: Any) {
       // self.mTicketExitView.frame = self.view.frame
       // self.view.addSubview(self.mTicketExitView)
       // self.mTicketExitView.isHidden = false
    }
    
    @IBAction func notification(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func exitTicketView(_ sender: Any) {
        self.mTicketExitView.isHidden = true
    }
    
    //Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = times[indexPath.item]
        cell.textLabel?.font = UIFont(name: Constants.FONTNAME as String, size: 17)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.getBackTime.text = times[indexPath.item]
         self.mExitView.removeFromSuperview()
    }
    
    //APICALL
    func getMyCar()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let valetProviderId = (carDetails["id_valet_provider"] as? Int)!
        let parkingName = (carDetails["parking_name"] as? String)!
        let carId = (carDetails["_id_car_details"] as? Int)!
        let parkingId = (carDetails["id_parking_management"] as? Int)!

        let parameters: Parameters =
            [
                "_id_customer_table": idValue as Any,
                "id_valet_provider":valetProviderId,
                "parking_name":parkingName as Any,
                "_id_car_details": carId as Any,
                "id_parking_management": parkingId as Any,
                "ticket_id" : (carDetails["ticket_id"] as? String)!,
                "ticket_amount" : (carDetails["ticket_amount"] as! Int),
                "aed" : "AED",
                "type" : "registered",
                "_id" : (carDetails["_id"] as? Int)!,
                "status": (carDetails["status"] as? String)!,
                "generated_on" : (carDetails["generated_on"] as? String)!,
                "get_in_time": self.getBackTime.text! as Any,
        ]
  
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            //ANLoader.showLoading()
           // SKActivityIndicator.show("Loading...")
            
            let header = ["Content-Type": "application/json"]
            
            Alamofire.request("\(Constants.BASEURL)ticket_management/request_valetboy3", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                     //   SKActivityIndicator.dismiss()
                        print("Response get car: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                
                                if status == "success" {
                                   // SKActivityIndicator.dismiss()
//                                    self.view.makeToast(" Get car request has been sent. You will be notified about the acceptance shortly");
                                    self.mTicketsView.isHidden = true
                                    self.mType = "requestCar"
                                }else
                                {
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }
                            } else {
                                self.view.makeToast("Json Error...!!!")
                            }
                        }
                        break
                    case .failure(let error):
                       // SKActivityIndicator.dismiss()
                        print(error)
                        
                        break
                    }
            }
        }
    }
}

extension ParkedCarVC: GADInterstitialDelegate {
    
    func createGoogleAds() {
//        #if DEBUG
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
//        #else
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2082512516840040/3831202448")
//        #endif
        SKActivityIndicator.show("Loading...")
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2082512516840040/3831202448")
        interstitial.delegate = self
        let request = GADRequest()
        //Ad Unit: ca-app-pub-2082512516840040/3831202448
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["fbdb7cb70bf9eac9f1190191ffb3569a"]
       // a9e684d4e7f10ec8c8f5189ee8dbf6fb
        
        interstitial.load(request)
    }
    
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        SKActivityIndicator.dismiss()
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        SKActivityIndicator.dismiss()
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    
}
