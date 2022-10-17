//
//  LauchScreenVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 14/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import Lottie

class LauchScreenVC: UIViewController {
    
    private var lottieAnimation: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lottieAnimation = AnimationView(name: "MechUniLottie")
        self.lottieAnimation?.frame = view.bounds
        self.lottieAnimation?.contentMode = .scaleAspectFit
        self.lottieAnimation?.center = self.view.center
        self.view.addSubview(self.lottieAnimation!)
        self.lottieAnimation?.loopMode = .playOnce
        self.lottieAnimation?.play()
        playAnimation()
    }
    func playAnimation() {
        self.lottieAnimation?.play(completion: { played in
            if played == true {
                print("Navigate here")
                if Connectivity.isConnectedToInternet{
                    print("Connected")
                    let isLoggedin = UserDefaults.standard.string(forKey: "isLoggedin") ?? "0"
                    if(isLoggedin == "1") {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else{
                    print("Not Connected")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConnectionCheckVC") as! ConnectionCheckVC
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                self.playAnimation()
            }
        })
    }
}
