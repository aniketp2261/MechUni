//
//  ContactUsVC.swift
//  ValetParking
//
//  Created by Khushal on 22/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView

class ContactUsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mMessageView: UIView!
    
    @IBOutlet weak var mSubmitBtn: UIButton!
    
    @IBOutlet weak var messageTF: UITextField!
    
    @IBOutlet weak var helpLineNumber: UILabel!
    
    var helpNo = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.mMessageView.layer.cornerRadius = 20
        self.mMessageView.layer.borderWidth = 1
        self.mMessageView.layer.borderColor = UIColor.gray.cgColor
        self.mSubmitBtn.layer.borderWidth = 1
        self.mSubmitBtn.layer.borderColor = UIColor.red.cgColor
        self.mSubmitBtn.layer.cornerRadius = self.mSubmitBtn.bounds.height/2
        getHelplineNumber()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func mSubmitActn(_ sender: Any) {
        if(messageTF.text == "")
        {
            self.view.makeToast("Please enter your message");
            return
        }else{
            contactUsApi()
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

}
//MARK: Api calls
extension ContactUsVC {
    func getHelplineNumber(){
        if Connectivity.isConnectedToInternet {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.IPURL + "admin_helpline/get_number", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                debugPrint("gethelplineAPIResponse00 ---- \(apiResponse)")
                switch apiResponse.result {
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String: Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "Success"{
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            for result in results{
                                let helplineNo = result["helpline_number"] as? String
                                self.helpNo = helplineNo ?? ""
                            }
                            DispatchQueue.main.async {
                                print("HELPLINENUMBER ---- \(self.helpLineNumber.text)")
                                self.helpLineNumber.text = self.helpNo
                            }
                        }
                        else{
                            SKActivityIndicator.dismiss()
                            self.view.makeToast("Failure...")
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    self.view.makeToast(apiResponse.error?.localizedDescription)
                }
            }
        } else{
            NetworkPopUpVC.sharedInstance.Popup(vc: self)
        }
    }
    
    func contactUsApi(){
        if Connectivity.isConnectedToInternet {
            SKActivityIndicator.show("Loading...")
            let name = UserDefaults.standard.string(forKey: "userName") ?? ""
            let email = UserDefaults.standard.string(forKey: "email") ?? ""
            let mobilenumber = UserDefaults.standard.string(forKey: "mobileNo") ?? ""
            let message = messageTF.text ?? ""
            
            let params:[String:Any] = ["name": name,"mobilenumber": mobilenumber,"email": email,"message": message]
            Alamofire.request(APIEndPoints.IPURL + "admin_helpline/add_helpline", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { apiResponse in
                debugPrint("ContactUsAPIResponse00 ---- \(apiResponse)")
                switch apiResponse.result {
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any] {
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success"{
                            let msg = apiDict["message"] as? String
                            self.view.makeToast(msg)
                        }
                        DispatchQueue.main.async {
                            self.messageTF.text = ""
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    self.view.makeToast(apiResponse.error?.localizedDescription)
                }
            }
        }
    }
}
