//
//  Connectivity.swift
//  ValetParking
//
//  Created by Sachin Patil on 05/08/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import Foundation
import Alamofire

struct NetworkConnectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}  

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var bundleIdentifier: String? {
        return infoDictionary?["CFBundleIdentifier"] as? String
    }
}
