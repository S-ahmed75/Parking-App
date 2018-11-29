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
    
    private var searchedTypes = [String]()
    var initLat:CLLocationDegrees? = 0.0
    var initLong:CLLocationDegrees?
  private let locationManager = CLLocationManager()
  private let dataProvider = GoogleDataProvider()
  private let searchRadius: Double = 1000
    var tappedMarker = GMSMarker()
    var detailAddress = ""
    var selected1 = false
    var sendAddress = ""
    var sendNoOfSpace = ""
    var sendMarker = GMSMarker()
    var sendARive: Date?
    var sendLeav: Date?
    var sendBookSpace = 0
    
    
    
    var adres:String! {
        didSet{
            print(self.adres)
        }
    }
    var Selected:Bool? = nil
    let uid = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    var ariveDAt:Date?
    var leavDat:Date?
    
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
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        mapView.delegate = self
        SVProgressHUD.show()
        SVProgressHUD.dismiss(withDelay: 3.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       self.mapView.clear()
        
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
            let dest = segue.destination as!  detailViewController
          
            dest.add(add: self.sendAddress, marker: self.sendMarker, ariveDate: self.sendARive!, leaveDate: self.sendLeav!, noOfSpaces: self.sendNoOfSpace , sendBookSpace: self.sendBookSpace)
            // dest.address.text = self.detailAddress
//            dest.Selected = self.selected
//            dest.selected1 = true
//            dest.initLat = self.initLatitude
//            dest.initLong = self.initLongitude
           
            
        }
        self.sendAddress = ""
        self.sendNoOfSpace = ""
        self.sendLeav = nil
        self.sendARive = nil
        
       
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
  
 
    
    @IBAction func searchBar(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        if L102Language.currentAppleLanguage() == "en" {
            
   autocompleteController.navigationItem.searchController?.searchBar.placeholder = "Search"
       
            print("otheee",L102Language.currentAppleLanguage())
      
        } else {
        print("otheeee")
            
            autocompleteController.navigationItem.searchController?.searchBar.placeholder = "Buscar"
       
        }
        
       
          present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func ArrivingButton(_ sender: Any) {
        
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 0)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 7)
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = "DONE"
        picker.doneBackgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.ArrivingLabel.text = formatter.string(from: date)
        self.ariveDAt = date
        }
        picker.delegate = self
        picker.show()
        
        
        
        
    }
    
    @IBAction func leaving(_ sender: Any) {
        
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 0)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 7)
        let picker1 = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker1.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker1.darkColor = UIColor.darkGray
        picker1.doneButtonTitle = "Done"
        picker1.doneBackgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker1.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.LeavingLabel.text = formatter.string(from: date)
       self.leavDat = date
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
  //  fetchNearbyPlaces(coordinate: mapView.camera.target)
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
   // fetchNearbyPlaces(coordinate: location.coordinate)
   print("loca2")
   
   
    
    let geoFirestoreRef = Firestore.firestore().collection("marker")

    
    
    let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
   
    
    let geo = geoFirestore.query(withCenter: location, radius: 1000)
    geo.observe(.documentEntered, with: { (key, location) in
        let Marker = GMSMarker()
        let key:String  = key!
        self.db.collection("ActiveParkings").getDocuments() { (querySnapshot1, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot1!.documents {
                    let doc = document.documentID
                   
                    print(document,"mmmm")
                    
                    
                    let g = self.db.collection("ActiveParkings").document(doc).collection("parkingSpace").document(key).getDocument { (querySnaps, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                           let date = Date()
                            if let doc2 =  querySnaps, doc2.exists{
                               print(doc2.data(),"mieeee")
                                var numberofSpa:Int = 0
                                var bookSpac:Int = 0
                                
                                    if let numberofSpaces = doc2.data()!["numberofSpaces"] as? String {
                                        let spaceVal:Int = Int(numberofSpaces)!
                                      
                                        if let leaveData = doc2.data()!["leaveData"] as? Date {
                                            if let bookid = doc2.data()!["bookingId"] as? String{
                                                    if leaveData.compare(date) == .orderedAscending{
                                                        self.db.collection("bookingId").document(bookid).delete()}}
                                            let bookSpace:Int = (doc2.data()!["bookSpace"] as? Int)!
                                            
                                            if leaveData.compare(date) == .orderedAscending{
                                                
                                                
                                                
                                                Marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "parking-sign"), scaledToSize: CGSize(width: 40, height: 40))
                                                Marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                                                Marker.map = self.mapView
                                                print("PReeeevv")
                                                let user = ["bookSpace":0] as [String : Any]
                                                self.db.collection("ActiveParkings").document(doc).collection("parkingSpace").document(key).updateData(user) { errr in
                                                    if let errr = errr {
                                                        print("Error writing document: \(errr)")
                                                    } else {
                                                        print("updatedddd")
                                                        // self.db.collection("bookingId").document().delete()
                                                    }}
                                                
                                            }else {
                                                if spaceVal > bookSpace{
                                                    Marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "parking-sign"), scaledToSize: CGSize(width: 40, height: 40))
                                                    Marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                                                    Marker.map = self.mapView
                                                   }
                                                
                                            }
                                            
                                            // let password = document.data()["password"] as? String
                                            
                                          
                                            
                                            
                                            print("thissss",numberofSpaces,leaveData,bookSpace)
                                            
                                        }
                                    }
                                    
//                                    var numberofSpa:Int = 0
//                                    var bookSpac:Int = 0
//
//                                    if d.key == "numberofSpaces"{
//                                        let spaceVal:Int = Int(d.value as! String)!
//                                        numberofSpa = spaceVal
//
//                                    }
//
//                                    if d.key == "bookSpace"{
//                                          if numberofSpa > bookSpac{
//                                        let bookVal:Int = d.value as! Int
//                                        bookSpac = bookVal
//                                    print("ye chaaal")
//                                    }
//
//
//                                    }
//                                    print(numberofSpa,bookSpac,"vicc")
                                    
//                                    if  d.key == "leaveData"{
//                                       print(d.key.count,"dkacount")
//
//                                        let d2 = d.value as! Date
//                                     // add date for compare in here
////
//                                        if d2.compare(date) == .orderedAscending{
//
//
//
//                                            Marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "parking-sign"), scaledToSize: CGSize(width: 40, height: 40))
//                                            Marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
//                                            Marker.map = self.mapView
//                                            print("PReeeevv")
//
//
//                                        }else {
//
//
//                                        }

                                //    }
                            
                            
                            
                                    
                                
                           
                            print(self.db.collection("ActiveParkings").document("\(document)").collection("parkingSpace").document(key).documentID)
                            print(doc2,"ccc")   }
                        
                    }
                        
                }
                    
                
            }
            print("mark is gettt")
            }}
        
        //
       
        
        
        
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
    
    
    if marker == tappedMarker{
        if Auth.auth().currentUser == nil {
            
            let alertVC = PMAlertController(title: "Sign In", description: "You need to SignIn for booking", image: #imageLiteral(resourceName: "your-logo-here"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: { () -> Void in
                print("Capture action Cancel")
                
            }))
            self.present(alertVC, animated: true, completion: nil)
        } else {
           
           
                let geocoder = GMSGeocoder()
                
                geocoder.reverseGeocodeCoordinate(tappedMarker.position) { response, error in
                  
                    
                    guard let address = response?.firstResult(), let lines = address.lines else {
                        return
                    }
                    
                    
                   
                    
                    DispatchQueue.main.async {
                        
                     if lines != nil {
                       let data = Firestore.firestore().collection("marker")
                        let lin = lines.first!
                      
                        self.s(adrres: lin)
                        print(address,"karachi")}
                  //  self.detailAddress = lines.first!
                 //   self.performSegue(withIdentifier: "booking", sender: self)
                    
                }
            
            }
         
        }

    }
    
    
    guard let placeMarker = marker as? PlaceMarker else {
        
        
     
        
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
    tappedMarker = marker
    
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
       self.initLat = place.coordinate.latitude
        self.initLong = place.coordinate.longitude
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
    
    func s(adrres:String){
        let geoFirestoreRef = Firestore.firestore().collection("marker")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
       // let destinationVC = storyboard.instantiateViewController(withIdentifier: "booking") as! detailViewController
       // var numberofSpa:Int = 0
   //     var bookSpac:Int = 0
        
      
        
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        let locatio = CLLocation(latitude: tappedMarker.position.latitude, longitude: tappedMarker.position.longitude)
        
        let geo = geoFirestore.query(withCenter: locatio, radius: 1000)
        geo.observe(.documentEntered, with: { (key, location) in
            let Marker = GMSMarker()
            let key:String  = key!
            self.db.collection("ActiveParkings").getDocuments() { (querySnapshot1, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if self.tappedMarker.position.latitude == location?.coordinate.latitude
                    {
                    for document in querySnapshot1!.documents {
                        let doc = document.documentID
                        
                        print(document,"mmmm")
                        
                        
                        let g = self.db.collection("ActiveParkings").document(doc).collection("parkingSpace").document(key).getDocument { (querySnaps, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                               
                               
                                    let date = Date()
                                if let doc2 =  querySnaps, doc2.exists{
                                    print(doc2.data(),"mieeee")
                                    
                                    let add = doc2.data()!["address"] as! String
                                    if doc2.documentID == key {
                                        
                                        if let numberofSpaces = doc2.data()!["numberofSpaces"] as? String {
                                    let spaceVal:Int = Int(numberofSpaces)!
                                        
                                        if let leaveData = doc2.data()!["leaveData"] as? Date {
                                            
                                            
                                            let bookSpace:Int = (doc2.data()!["bookSpace"] as! Int)
                                            
                                          
                                            
                                                  let val = "\(spaceVal - bookSpace)"
                                                    
                                                    if self.ariveDAt == nil || self.leavDat == nil {
                                                        print("lineee",adrres)
                                                        let formatter = DateFormatter()
                                                        formatter.dateFormat = "dd/MM/yyyy"
                                                        let firstDate = formatter.date(from: "10/08/1990")
                                                        let secondDate = formatter.date(from: "10/08/1990")
//                                                        destinationVC.add(add: adrres, marker:self.tappedMarker, ariveDate:firstDate!,leaveDate:secondDate!, noOfSpaces: val)
                                                        self.sendAddress = adrres
                                                        self.sendNoOfSpace = val
                                                        self.sendLeav = secondDate!
                                                        self.sendARive = firstDate!
                                                        self.sendBookSpace = bookSpace
                                                        
                                                        self.sendMarker = self.tappedMarker
                                                        if adrres == self.sendAddress{
                                                            
                                                            
                                                            self.performSegue(withIdentifier: "booking", sender: nil)}
//                                                        self.present(destinationVC, animated: false, completion: nil)
                                                    }else{
                                                       
//                                                        destinationVC.add(add: adrres, marker:self.tappedMarker, ariveDate: self.ariveDAt!,leaveDate:self.leavDat!, noOfSpaces: val)
//                                                        self.present(destinationVC, animated: false, completion: nil)
                                                        self.sendAddress = adrres
                                                        self.sendNoOfSpace = val
                                                        self.sendLeav = self.leavDat!
                                                        self.sendARive = self.ariveDAt!
                                                        self.sendMarker = self.tappedMarker
                                                        self.sendBookSpace = bookSpace
                                                        if self.tappedMarker == self.sendMarker{
                                                            self.performSegue(withIdentifier: "booking", sender: nil)}
//
                                                    }
                                             
                                                
                                           
                                            
                                           
                                            
                                        }
                                    }
                                    }
                                
                            }
                            }
                            
                        }
                        
                        
                    }
                    print("mark is gettt")
                }    }}
            
            
        })
    }
}
