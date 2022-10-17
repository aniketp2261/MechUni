//
//  Connectivity.swift
//  ORBIIT
//
//  Created by Suganya on 6/25/18.
//  Copyright © 2018 sidemenutest. All rights reserved.
//

//import Foundation
//import Alamofire
//
//class Connectivity {
//    static let sharedInstance = NetworkReachabilityManager()!
//    static var isConnectedToInternet:Bool {
//        return self.sharedInstance.isReachable
//    }
//}

import Foundation
import Alamofire

public class Connectivity {
    
    public class var isConnectedToInternet: Bool {
        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
        return reachabilityManager!.isReachable
    }
}
