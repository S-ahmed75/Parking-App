//
//  MapViewController.swift
//  Feed Me
//
/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import GoogleMaps
import GooglePlaces
import DateTimePicker
import Geofirestore
import FirebaseFirestore
import SVProgressHUD
import Foundation
import Firebase
import PMAlertController

class MapViewController1: UIViewController, DateTimePickerDelegate {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
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
    var initLat:CLLocationDegrees? = 0.0
    var initLong:CLLocationDegrees?
  private let locationManager = CLLocationManager()
  private let dataProvider = GoogleDataProvider()
  private let searchRadius: Double = 1000
    var detailAddress = ""
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
  
    sideMenus()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        
        SVProgressHUD.show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "booking" {
            let dest = segue.destination as! detailViewController
           // dest.address.text = self.detailAddress
//            dest.Selected = self.selected
//            dest.selected1 = true
//            dest.initLat = self.initLatitude
//            dest.initLong = self.initLongitude
            
        }
        self.dismiss(animated: true, completion: nil)
    }
  
  private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
    let geocoder = GMSGeocoder()
    
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      self.addressLabel.unlock()
      
      guard let address = response?.firstResult(), let lines = address.lines else {
        return
      }
      
      self.addressLabel.text = lines.joined(separator: "\n")
        SVProgressHUD.dismiss()
      
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
    
    @IBAction func searchBar(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        
        if L102Language.currentAppleLanguage() == "en" {
            
   autocompleteController.navigationItem.searchController?.searchBar.placeholder = "Search"
         autocompleteController.delegate = self
            print("otheee",L102Language.currentAppleLanguage())
        present(autocompleteController, animated: true, completion: nil)
        } else {
        print("otheeee")
            autocompleteController.delegate = self
            autocompleteController.navigationItem.searchController?.searchBar.placeholder = "Buscar"
        present(autocompleteController, animated: true, completion: nil)
        }
        
       
        
        
    }
    
    @IBAction func ArrivingButton(_ sender: Any) {
        
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = "DONE"
        picker.doneBackgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.ArrivingLabel.text = formatter.string(from: date)
        }
        picker.delegate = self
        picker.show()
        
        
        
        
    }
    
    @IBAction func leaving(_ sender: Any) {
        
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker1 = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker1.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker1.darkColor = UIColor.darkGray
        picker1.doneButtonTitle = "Done"
        picker1.doneBackgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker1.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.LeavingLabel.text = formatter.string(from: date)
        }
        picker1.delegate = self
        picker1.show()
        
        
    }
}


// MARK: - TypesTableViewControllerDelegate
extension MapViewController1: TypesTableViewControllerDelegate {
  func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sorted()
    dismiss(animated: true)
    fetchNearbyPlaces(coordinate: mapView.camera.target)
  }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController1: CLLocationManagerDelegate {
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
    
    if initLat == 0.0 {
    
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
       
    }
        
    else{
         mapView.camera = GMSCameraPosition.camera(withLatitude: initLat!, longitude: initLong!, zoom: 15.0)
        
    }
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    
    locationManager.stopUpdatingLocation()
    fetchNearbyPlaces(coordinate: location.coordinate)
   print("loca2")
    let geoFirestoreRef = Firestore.firestore().collection("ActiveParkings")
    let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
    let geo = geoFirestore.query(withCenter: location, radius: 1000)
    geo.observe(.documentEntered, with: { (key, location) in
        let Marker = GMSMarker()
        Marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "parking-sign"), scaledToSize: CGSize(width: 40, height: 40))
        Marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        Marker.map = self.mapView
        print("loca1")
        
    })
  }
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}


// MARK: - GMSMapViewDelegate
extension MapViewController1: GMSMapViewDelegate {
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
        
        if Auth.auth().currentUser == nil {
            
            let alertVC = PMAlertController(title: "Sign In", description: "You need to SignIn for booking", image: #imageLiteral(resourceName: "your-logo-here"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: { () -> Void in
                print("Capture action Cancel")
                
            }))
             self.present(alertVC, animated: true, completion: nil)
        } else {
            detailAddress = addressLabel.text!
            self.performSegue(withIdentifier: "booking", sender: self)
            SVProgressHUD.dismiss()
           
        }
        print("nothing inrrrr2")
      return nil
    }
    guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
      print("nothing inrrrr")
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
    
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
        
        if leavingButton.isSelected == true {
            self.LeavingLabel.text = picker.selectedDateString
            
        }else if arriving.isSelected == true{
            self.ArrivingLabel.text = picker.selectedDateString
        }
    }
}

extension MapViewController1: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.Selected = true
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
        self.addressLabel.text = place.formattedAddress
        SVProgressHUD.dismiss()
        self.adres = place.formattedAddress!
        selected1 = true
        mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
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
