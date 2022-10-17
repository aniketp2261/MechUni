//
//  TermsVC.swift
//  ValetParking
//
//  Created by Khushal on 20/07/19.
//  Copyright © 2019 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView

class TermsVC: UIViewController {

    @IBOutlet weak var termsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.termsLabel.text = ""
        termsApi()

    }
    

   

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //Api Call
    func  termsApi()
    {
        print("Yes! internet is available.")
        SKActivityIndicator.show("Loading...")
        Alamofire.request("\(Constants.BASEURL)about_us/termsAndcondition", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
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
                            if status == "success"{
                                let contentArr = JSON["result"] as? NSArray
                                if let dict = contentArr?.firstObject as? NSDictionary {
                                    self.termsLabel.text = (dict["termsAndconditions"] as? String ?? "")
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
