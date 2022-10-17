//
//  MechbrainLocPickUpVC.swift
//  ValetParking
//
//  Created by Aniket Patil on 02/09/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MechbrainLocPickUpVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var SearchTF: UITextField!
    @IBOutlet weak var SetLocation: UIButton!
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var Destinationlatitude: CLLocationDegrees?
    var Destinationlongitude: CLLocationDegrees?
    let destinationMarker = GMSMarker()
    let destinationLastMarker = GMSMarker()
    var destinationLocation = CLLocation()
    var locationmanager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        MapView.bringSubviewToFront(SearchView)
        MapView.bringSubviewToFront(SetLocation)
        SetLocation.layer.cornerRadius = SetLocation.frame.height / 2
        SetLocation.layer.borderWidth = 1
        SetLocation.layer.borderColor = UIColor.red.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationmanager.delegate = self
        self.locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationmanager.requestWhenInUseAuthorization()
        self.locationmanager.showsBackgroundLocationIndicator = false
        self.locationmanager.startUpdatingLocation()
        DispatchQueue.main.async {
            let lat = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLat") ?? "") ?? 0.0
            let lng = CLLocationDegrees(UserDefaults.standard.string(forKey: "CurrentLong") ?? "") ?? 0.0
            self.Destinationlatitude = lat
            self.Destinationlongitude = lng
            let cameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14)
            self.MapView.animate(to: cameraPosition)
        }
    }
    @IBAction func textFieldTapped(_ sender: Any) {
        SearchTF.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    @IBAction func BackAction(_ sender: UIButton){
        print("BackActionBackAction")
        SearchTF.text = ""
        navigationController?.popViewController(animated: false)
    }
    @IBAction func SetLocationAction(){
        print("SetLocationAction")
        print("SelectedAddress---\(self.destinationMarker.title ?? "")")
        let dict : [String:Any] = ["address": self.destinationMarker.title ?? "","lat":String(latitude ?? 0.0),"long":String(longitude ?? 0.0)]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationPicked"), object: dict)
    }
}
extension MechbrainLocPickUpVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Then display the name in textField
        SearchTF.text = place.name
        print("CoordinateLatitude: \(place.coordinate.latitude)")
        print("CoordinateLongitude: \(place.coordinate.longitude)")
        MapView.animate(to: GMSCameraPosition(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14))
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
          destinationMarker.position = coordinates
          destinationMarker.map = MapView
          destinationMarker.appearAnimation = .none
          latitude = coordinates.latitude
          longitude = coordinates.longitude
          let location1 = CLLocation(latitude: latitude!, longitude: longitude!)
          let position1 = location1.coordinate
          print("CurrentLocationLattitude--\(latitude)")
          print("CurrentLocationLongitude--\(longitude)")

        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(position1) { response, error in
            if let location = response?.firstResult() {
                self.destinationMarker.position = position1
                let lines = location.lines! as [String]
                if lines.count > 0{
                  self.destinationMarker.userData = lines.joined(separator: "\n")
                  self.destinationMarker.title = lines.joined(separator: "\n")
                  print("lines.joined1---\(lines.joined(separator: "\n"))")
                }
                self.destinationMarker.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
                self.destinationMarker.accessibilityLabel = "current"
                self.destinationMarker.map = self.MapView
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        MapView.clear()
        var destinationCoordinate:CLLocationCoordinate2D?
        destinationMarker.icon = #imageLiteral(resourceName: "PickupMarker")
        destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
    
        print(position.target.latitude)
        print(position.target.longitude)
        destinationCoordinate = destinationLocation.coordinate

        self.updateLocationoordinates(coordinates: destinationCoordinate!)
        print(destinationCoordinate!)
    
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude:(location?.coordinate.latitude)!,longitude: (location?.coordinate.longitude)!, zoom: 14)
        self.MapView.animate(to: camera)
        let location1 = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let position1 = location1.coordinate
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        print("latitude---\(latitude)")
        print("latitude---\(longitude)")
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(position1) { response, error in
            if let location = response?.firstResult() {
                self.destinationMarker.position = position1
                let lines = location.lines! as [String]
                if lines.count > 0{
                  self.destinationMarker.userData = lines.joined(separator: "\n")
                  self.destinationMarker.title = lines.joined(separator: "\n")
                  print("lines.joined2---\(lines.joined(separator: "\n"))")
                }
                self.destinationMarker.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
                self.destinationMarker.accessibilityLabel = "current"
            }
          self.locationmanager.stopUpdatingLocation()
        }
    }
}
