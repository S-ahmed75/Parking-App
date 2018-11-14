//
//  SelectAddressViewController.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/25/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import FirebaseFirestore
import Firebase
import Geofirestore
class SelectAddressViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {


   
    
    let uid = Auth.auth().currentUser?.uid
    
    var initLat:CLLocationDegrees?
    var initLong:CLLocationDegrees?
    
    var lat:CLLocationDegrees?
    var long:CLLocationDegrees?
    let db = Firestore.firestore()
    let marker = GMSMarker()
    var address:String! {
        didSet{
            print(self.address)
        }
    }
    var locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    @IBOutlet weak var mapView: GMSMapView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        geoCoder.geocodeAddressString(address) { (placemarks, error) in
//            guard
//                let placemarks = placemarks,
//                let location = placemarks.first?.location
//                else {
//                    // handle no location found
//                    return
//            }
//
//
//
//            let position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//            let marker = GMSMarker(position: position)
//            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 13)
//            self.MapView.camera = camera
//            self.MapView.animate(toLocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
//            marker.map = self.MapView
//
//
//        }
//
//        MapView.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startMonitoringSignificantLocationChanges()
//
//    }


    

    
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        plotMarker(AtCoordinate: coordinate, onMapView: mapView)
//    }
    
//    //MARK: Plot Marker Helper
//    private func plotMarker(AtCoordinate coordinate : CLLocationCoordinate2D, onMapView vwMap : GMSMapView) {
//        let zoom = self.MapView.camera.zoom
//        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoom)
//        self.marker.position = coordinate
//        self.MapView.camera = camera
//        marker.map = vwMap
//        self.lat = coordinate.latitude
//        self.long = coordinate.longitude
//    }
    
    @IBAction func DoneButton(_ sender: Any) {
        let geoFirestoreRef = Firestore.firestore().collection("ActiveParkings")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        geoFirestore.setLocation(location: CLLocation(latitude: lat!, longitude: long!), forDocumentWithID: uid!) { (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
            }
        }
         _ = self.navigationController?.popViewController(animated: true)
        
    }
    

    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    @IBOutlet weak var ArrivingLabel: UITextField!
    @IBOutlet weak var LeavingLabel: UITextField!
    @IBOutlet weak var leavingButton: UIButton!
    @IBOutlet weak var arriving: UIButton!
    @IBOutlet weak var SearchBarLabel: UILabel!
    @IBOutlet weak var searchBarView: UIView!
    
    private var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
   
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    
    var selected1 = false
    var adres:String! {
        didSet{
            print(self.adres)
        }
    }
    var Selected:Bool? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        mapView.delegate = self
        
        
        
    }
//    func sideMenus(){
//        if revealViewController() != nil {
//            menu.target = revealViewController()
//            menu.action = #selector(SWRevealViewController.revealToggle(_:))
//            revealViewController().rearViewRevealWidth = 275
//            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//
//        }
//    }
    
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        self.lat = coordinate.latitude
        self.long = coordinate.longitude
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            self.addressLabel.unlock()
            
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            self.addressLabel.text = lines.joined(separator: "\n")
            
            
            let labelHeight = self.addressLabel.intrinsicContentSize.height
            self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                                bottom: labelHeight, right: 0)
            
            UIView.animate(withDuration: 0.25) {
                self.pinImageVerticalConstraint.constant = ((labelHeight - self.view.safeAreaInsets.top) * 0.5)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.mapView
            }
        }
    }
    
    @IBAction func refreshPlaces(_ sender: Any) {
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
    
    
}


// MARK: - TypesTableViewControllerDelegate
extension SelectAddressViewController: TypesTableViewControllerDelegate {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        dismiss(animated: true)
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
}

// MARK: - CLLocationManagerDelegate
extension SelectAddressViewController {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: initLat!, longitude: initLong!, zoom: 15.0)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        locationManager.stopUpdatingLocation()
        fetchNearbyPlaces(coordinate: location.coordinate)
    }
}

// MARK: - GMSMapViewDelegate
extension SelectAddressViewController {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressLabel.lock()
        
        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }
        
        infoView.nameLabel.text = placeMarker.place.name
        if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "generic")
        }
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
    
//    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
//
//        if leavingButton.isSelected == true {
//            self.LeavingLabel.text = picker.selectedDateString
//
//        }else if arriving.isSelected == true{
//            self.ArrivingLabel.text = picker.selectedDateString
//        }
//    }
}

extension SelectAddressViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.Selected = true
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
        self.SearchBarLabel.text = place.formattedAddress
        self.adres = place.formattedAddress!
        selected1 = true
        print("Place attributions: \(String(describing: place.attributions))")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}

