//
//  Constants.swift
//  Dhukan
//
//  Created by Suganya on 7/18/18.
//  Copyright © 2018 Suganya. All rights reserved.
//

import Foundation
import UIKit



class Constants {
    
    static let kMainViewController = UIApplication.shared.delegate?.window??.rootViewController as? MainViewController
    static let kNavigationController = (UIApplication.shared.delegate?.window??.rootViewController as? MainViewController)?.rootViewController as? NavigationController
    // https://oniapps.net:300
    // 54.89.206.102:300
   // https://vap-api.herokuapp.com
    
    //Live
    static let BASEURL                    = "http://oniapps.net:300/"
    static let IMGBASEURL                 = "http://oniapps.net:300"
    static let IMGBASEURL2                = "http://oniapps.net:300/"
    
   // Local
//    static let BASEURL                    = "http://54.89.206.102:300/"
//    static let IMGBASEURL                 = "http://54.89.206.102:300"
//    static let IMGBASEURL2                 = "http://54.89.206.102:300/"
    
//    static let redirectUrl = "http://3.221.143.28:55181/ccavResponseHandler"
//    static let cancelUrl = "http://3.221.143.28:55181/ccavResponseHandler"
//    static let rsaKeyUrl = "https://secure.ccavenue.ae/transaction/transaction.do?command=initiateTransaction"
    
    static let DEVICE_ID               = UIDevice.current.identifierForVendor!.uuidString
    
    static let FONTNAME: NSString      = "Arial"
    
    static let FONTNAME_BOLD: NSString = "Arial-BoldMT"
    
    static let OFFLINE_MESSAGE          = "The Internet connection appears to be offline"
    
    static let FEATURE_MESSAGE          = "Login to use this feature"
    
    static let SCREEN_WIDTH            = UIScreen.main.bounds.size.width
    
    static let SCREEN_HEIGHT           = UIScreen.main.bounds.size.height
    
    static let appDelegate             = UIApplication.shared.delegate as? AppDelegate
    
    
}
