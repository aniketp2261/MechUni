//
//  ConnectionCheckVC.swift
//  ValetParking
//
//  Created by Sachin Patil on 08/08/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Lottie

class ConnectionCheckVC: UIViewController {
    
    @IBOutlet weak var ClickEnableLbl: UILabel!
    @IBOutlet weak var TryBtn: UIButton!
    
    private var lottieAnimation: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lottieAnimation = AnimationView(name: "MechUniLottie")
        self.lottieAnimation?.frame = view.bounds
        self.lottieAnimation?.contentMode = .scaleAspectFit
        self.lottieAnimation?.center = self.view.center
        self.view.insertSubview(self.lottieAnimation!, at: 0)
        self.lottieAnimation?.loopMode = .loop
        self.lottieAnimation?.play()
        playAnimation()
        TryBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        ClickEnableLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClickEnableData)))
        TryBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RefreshAction)))
        checkNet()
    }
    @objc func ClickEnableData(){
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
    func playAnimation() {
        self.lottieAnimation?.play(completion: { played in
            if played == true {
                print("Navigate here")
                self.checkNet()
            }else {
                self.playAnimation()
            }
        })
    }
    @objc func checkNet(){
        if Connectivity.isConnectedToInternet{
            print("Connected")
            let isLoggedin = UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
            if(isLoggedin == true) {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else{
            print("Not Connected")
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConnectionCheckVC") as! ConnectionCheckVC
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
