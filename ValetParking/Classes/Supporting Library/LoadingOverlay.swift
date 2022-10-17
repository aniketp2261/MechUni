//
//  LoadingOverlay.swift
//  Umang Demo
//
//  Created by Ram Mhapasekar on 10/27/17.
//  Copyright © 2017 CCAvenue. All rights reserved.
//

/*
 This class will handle activity indicator
 
 While showing Activity indicator call as LoadingOverlay.shared.showOverlay(view: self.view)
 to hide Activity indicator just call LoadingOverlay.shared.hideOverlayView()
 */

import Foundation
import UIKit

public class LoadingOverlay{
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var isShowing = false
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView!) {
        if let window = UIApplication.shared.keyWindow{
            isShowing = true
            overlayView = UIView(frame: UIScreen.main.bounds)
            overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: (window.frame.width / 2) - 50, y: (window.frame.height / 2)-100, width: 100, height: 100))
            activityIndicator.backgroundColor = .clear
            overlayView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            view.addSubview(overlayView)
        }
    }
    
    public func hideOverlayView() {
        isShowing = false
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
    public func isShowingOverlay() -> Bool {
        return isShowing
    }
}
