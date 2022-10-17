//
//  AboutUsVC.swift
//  ValetParking
//
//  Created by Khushal on 22/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Alamofire
import SKActivityIndicatorView
import Toast_Swift



struct aboutUsModel {
    let id, aboutUs: String
}

class AboutUsVC: UIViewController {

    @IBOutlet weak var mAboutLabel: UILabel!
    
    var aboutUSArray:[aboutUsModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        aboutApi()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  func aboutApi()
  {
    if Connectivity.isConnectedToInternet{
        print("Yes! internet is available.")
        SKActivityIndicator.show("Loading...")
        Alamofire.request("\(APIEndPoints.BaseURL)about_us/about_us", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                switch response.result {
                case .success:
                    SKActivityIndicator.dismiss()
                    print("AboutUsResponse: \(response)")
                    if let apiDict = response.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        if status == "success" {
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            print("AboutUsResults--- \(results)")
                            for result in results{
                                let id = String(result["_id"] as? Int ?? 0)
                                let aboutUs = result["about_us"] as? String ?? ""
                                
                                let Model = aboutUsModel(id: id, aboutUs: aboutUs)
                                print("AboutUSModell ---- \(Model)")
                                self.aboutUSArray.append(Model)
                                for aboutUsData in self.aboutUSArray{
                                    self.mAboutLabel.text = "     \(aboutUsData.aboutUs)"
                                }
                            }
                        }
                        else{
                            self.view.makeToast("Failure..")
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
