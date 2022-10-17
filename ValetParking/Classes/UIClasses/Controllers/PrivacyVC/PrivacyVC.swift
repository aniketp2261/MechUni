//
//  PrivacyVC.swift
//  ValetParking
//
//  Created by Khushal on 20/07/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

//If I am not logged in and try to access profile, ticket and add car, I am getting a popup "Login is required to access this feature". Just reverse the options like cancel on first position and Go To Login on second position.

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift

class PrivacyVC: UIViewController {

    @IBOutlet weak var privacyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.privacyLabel.text = ""
        privacyApi()
    }
    

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
  

    func  privacyApi()
    {
        print("Yes! internet is available.")
        SKActivityIndicator.show("Loading...")
        if Connectivity.isConnectedToInternet
        {
            Alamofire.request("\(Constants.BASEURL)about_us/policy", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                switch response.result {
                case .success:
                    SKActivityIndicator.dismiss()
                    print("Response: \(response)")
                    if let json = response.result.value {
                        if let JSON = json as? NSDictionary {
                            let message = JSON["message"] as? String
                            print(JSON["status"] as? String ?? "")
                            let status = JSON["status"] as? String
                            if status == "success"{
                                let contentArr = JSON["result"] as? NSArray
                                if let dict = contentArr?.firstObject as? NSDictionary {
                                    self.privacyLabel.text = (dict["policy"] as? String ?? "")
                                }
                                
                            }
                            else{
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
}
