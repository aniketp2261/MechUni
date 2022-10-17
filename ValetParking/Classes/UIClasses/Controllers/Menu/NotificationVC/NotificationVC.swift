//
//  NotificationVC.swift
//  ValetParking
//
//  Created by Khushal on 23/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift


struct NotificationModel: Codable {
    let dateTime, id, firstmsg, ticketId, idCustomerTable : String
    let isSeen: Bool
}

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var mNotificationTV: UITableView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var BackImg: UIImageView!
   
    var notificationArray : [NotificationModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.mDeleteAllBtn.layer.borderWidth = 1
//        self.mDeleteAllBtn.layer.borderColor = UIColor.white.cgColor
//        self.mDeleteAllBtn.isHidden = true
         self.mNotificationTV.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        BackImg.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        BackImg.addGestureRecognizer(backTap)
        displayNotification()
    }
    @objc func back() {
        self.navigationController?.popViewController(animated: false)
    }
    // Table View
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView.estimatedRowHeight = 120 // standard tableViewCell height
//        tableView.rowHeight = UITableViewAutomaticDimension
//        return UITableViewAutomaticDimension
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.selectionStyle = .none
        let maindict = self.notificationArray[indexPath.row]
        cell.mDescriptionLabel.text = maindict.firstmsg
        cell.mTimeLabel.text = String(format: "%@ %@", SingletonClass.sharedInstances.GetDateTime(mDate: maindict.dateTime, type: "time"), SingletonClass.sharedInstances.GetDateTime(mDate: maindict.dateTime, type: "date"))
//        cell.mTimeLabel.text = (maindict["datetime"] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let maindict = self.notificationArray[indexPath.row]
            let parameters: Parameters =
            [
                "_id": maindict.id as Any,
                "is_seen": true as Bool
            ]
            self.updateNotificationStatus(parameters)
            if maindict.ticketId != "" && maindict.ticketId != nil {

                let VC = storyboard?.instantiateViewController(withIdentifier: "TicketDetailsVC") as! TicketDetailsVC
                UserDefaults.standard.setValue(maindict.ticketId, forKey: "TicketId")
                self.navigationController?.pushViewController(VC, animated: true)
//            self.getTicketStatus(parameters)
            }
//        let strType = maindict["firstMsg"] as? String ?? ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //API CAll
    func displayNotification()
    {
        let idValue = UserDefaults.standard.string(forKey: "userID") ?? ""
        let parameters: Parameters =
            [
                "_id_customer_table": idValue as Any
        ]
        print(parameters)
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)car_details/getnotify", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("getnotifyResponse: \(response)")
                        if let json = response.value {
                            if let JSON = json as? [String: Any]{
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String ?? ""
                                if status == "success" {
                                    SKActivityIndicator.dismiss()
                                    let NotificationArray = JSON["notification"] as! [[String:Any]]
                                    self.notificationArray.removeAll()
                                    for notification in NotificationArray{
                                        let isseen = notification["is_seen"] as? Bool ?? false
                                        let datetime = notification["datetime"] as? String ?? ""
                                        let id = notification["_id"] as? String ?? ""
                                        let firstmsg = notification["firstMsg"] as? String ?? ""
                                        let ticketId = notification["ticket_id"] as? String ?? ""
                                        let idCustomerTable = String(notification["_id_customer_table"] as? Int ?? 0)
                                        let Model = NotificationModel(dateTime: datetime, id: id, firstmsg: firstmsg, ticketId: ticketId, idCustomerTable: idCustomerTable, isSeen: isseen)
                                        print("getNotificationData0000 ---- \(Model)")
                                        if isseen == false{
                                            self.notificationArray.append(Model)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        if self.notificationArray.count != 0
                                        {
                                            self.NoDataLbl.isHidden = true
                                            self.mNotificationTV.reloadData()
                                        } else{
                                            self.NoDataLbl.isHidden = false
                                        }
                                    }
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
                        SKActivityIndicator.dismiss()
                        print(error)
                        
                        break
                    }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
    func updateNotificationStatus(_ param: Parameters){
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)ticket_management/update_status_of_notifications", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("update_statusResponse: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                
                                let status = JSON["status"] as? String
                                if status == "Success" {
                                    SKActivityIndicator.dismiss()
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
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
                        SKActivityIndicator.dismiss()
                        print(error)
                        break
                    }
            }
        }
    }

    func getTicketStatus(_ param: Parameters) {
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)ticket_management/confirm_status", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("confirm_statusResponse: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                
                                let status = JSON["status"] as? String
                                if status == "success" {
                                    SKActivityIndicator.dismiss()
                                    if let data = JSON["data"] as? [String: Any] {
                                        self.pushToTicket(data["status"] as! String)
                                    }
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
                        SKActivityIndicator.dismiss()
                        print(error)
                        break
                    }
            }
        }
    }
    
    func pushToTicket(_ strType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TicketsVC") as! TicketsVC
        if strType.lowercased() == "completed" || strType.lowercased() == "complete" {
            vc.mSelectedType = "completed"
        } else {
            vc.mSelectedType = "progress"
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
