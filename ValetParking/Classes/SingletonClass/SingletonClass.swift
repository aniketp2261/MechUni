//
//  SingletonClass.swift
//  FreshBasket
//
//  Created by admin fugenx on 11/23/18.
//  Copyright © 2018 Fugenx. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


protocol SingletonClassDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

class SingletonClass: NSObject, CLLocationManagerDelegate {
   
    
    var mSessionId : String = ""
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: SingletonClassDelegate?
    var mUser_longitude: CLLocationDegrees = 0
    var mUser_latitude: CLLocationDegrees = 0
    static let sharedInstances:SingletonClass = {
        let instance = SingletonClass()
        return instance
    } ()
    override init(){
        super.init()
        guard let locationManagers=self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManagers.requestWhenInUseAuthorization()
        }
        if #available(iOS 9.0, *) {
            //            locationManagers.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        locationManagers.desiredAccuracy = kCLLocationAccuracyBest
        locationManagers.pausesLocationUpdatesAutomatically = false
        locationManagers.distanceFilter = 0.1
        locationManagers.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.lastLocation = location
        
        mUser_longitude = (manager.location?.coordinate.longitude)!
        mUser_latitude = (manager.location?.coordinate.latitude)!
        updateLocation(currentLocation: location)
        
    }
    
    @nonobjc func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation: currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager = CLLocationManager()
        guard let locationManagers=self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // locationManagers.requestAlwaysAuthorization()
            locationManagers.requestWhenInUseAuthorization()
        }
        if #available(iOS 9.0, *) {
            //            locationManagers.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        locationManagers.desiredAccuracy = kCLLocationAccuracyBest
        locationManagers.pausesLocationUpdatesAutomatically = false
        locationManagers.distanceFilter = 0.1
        locationManagers.delegate = self
        
        self.locationManager?.startUpdatingLocation()
        //   self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    func hello(){
        print("hello")
    }
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func  GetDateTime(mDate : String, type : String) -> String {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: mDate)
        
        if type == "date"{
           dateFormatter.dateFormat = "dd MMM yyyy" ; //"dd-MM-yyyy HH:mm:ss"
        }else{
            dateFormatter.dateFormat = "h:mm a"
        }
        
        dateFormatter.locale = tempLocale // reset the locale --> but no need here
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }

    
    func generateSessionId(){
        
        let randstr = randomString(withLength: 24)
        let formatter = DateFormatter()
        let formatString = "yyyyMMddHHmmssSSS"
        formatter.dateFormat = formatString
        var datestr = formatter.string(from: Date())
        
        mSessionId = "\(randstr ?? "")_\(datestr)"
        print("self.mSessionId = \(mSessionId)")
        UserDefaults.standard.setValue(mSessionId as? String, forKey: "SessionId")
    }
    
    func randomString(withLength len: Int) -> String? {
    
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< len {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
