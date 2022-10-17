//
//  NetworkPopUpVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 08/08/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class NetworkPopUpVC: UIViewController {
    static let sharedInstance = NetworkPopUpVC()

    @IBOutlet weak var clickhereLbl: UILabel!
    @IBOutlet weak var RefreshImg: UIImageView!
    
    var isOnline = false
    var othervc = ProviderDetailsVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clickhereLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClickHereAction)))
        RefreshImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RefreshAction)))
        checkNet()
        showAnimate()
    }
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                NotificationCenter.default.post(name: Notification.Name("AppEnterForeground"), object: nil)
            }
        })
    }
    @objc func ClickHereAction(){
        if let url = URL(string:"App-Prefs:root=WIFI") {
          if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
              UIApplication.shared.openURL(url)
            }
          }
        }
    }
    @objc func RefreshAction(){
        checkNet()
    }
    func checkNet(){
        if Connectivity.isConnectedToInternet{
            print("Connected")
            removeAnimate()
        } else{
//            checkNet()
        }
    }
    func Popup(vc: UIViewController) {
        print("OTHERVC---\(othervc)")
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NetworkPopUpVC") as! NetworkPopUpVC
        vc.addChild(popvc)
        popvc.view.frame = vc.view.frame
        vc.view.addSubview(popvc.view)
        popvc.didMove(toParent: vc)
    }
}
