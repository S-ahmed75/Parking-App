//
//  RentSpaceTableViewController.swift
//
//
//  Created by Mohammad Ali Panhwar on 9/25/18.
//

import UIKit
import GoogleMaps
import SVProgressHUD
import GooglePlaces
import CountryPickerView
import FirebaseFirestore
import Firebase
import PMAlertController
import Geofirestore


class RentSpaceTableViewController: UITableViewController,setLocat{
    func setloc(location: CLLocation, forDocumentWithID: String,address:String) {
        self.savLat = location.coordinate.latitude
        self.savLon = location.coordinate.longitude
        self.selectAddress.text = address
    }
    

  

    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var adress = ""
    var initLongitude:CLLocationDegrees?
    var initLatitude:CLLocationDegrees?
    var numbe = 0;
    var savLat:CLLocationDegrees?
    var savLon:CLLocationDegrees?
    
    
    let cp = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
     let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
    
    @IBOutlet weak var selectCountry: UITextField!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var selectAddress: UITextField!
    @IBOutlet weak var SpaceType: UISegmentedControl!
    @IBOutlet weak var numberOfSpaces: UITextField!
    @IBOutlet weak var OwnerType: UISegmentedControl!
    @IBOutlet weak var SpaceWidth: UISegmentedControl!
    @IBOutlet weak var Fname: UITextField!
    @IBOutlet weak var Lname: UITextField!
    @IBOutlet weak var PhoneNumber: UITextField!
    
    let count = CountryPickerView()
    var spaceType = "Driveway"
    var ownerType = "Individual"
    var spaceWidth = "Normal"
    var spaceId = ""
    var ui:String = ""
    var userId = ""
    
    @IBOutlet weak var countryPicke: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
       
        self.SpaceType.selectedSegmentIndex = UISegmentedControlNoSegment
        self.OwnerType.selectedSegmentIndex = UISegmentedControlNoSegment
        self.SpaceWidth.selectedSegmentIndex = UISegmentedControlNoSegment
       
       self.db.collection("Users").document(self.uid!).getDocument(completion: { (snaps, errr) in
        if let doc2 =  snaps, doc2.exists{
            print(doc2.data(),"mieeee")
            for d in doc2.data()!{
                
                var numberofSpa:Int = 0
                var bookSpac:Int = 0
                
                if d.key == "userId"{
                    let  u:String = d.value as! String
                    self.userId = u
                    
                }
            }}
    })
       // let cou = count.countries
       
       
        cpv.showCountryCodeInView = false
        cpv.showCountryName = true
        
        cpv.showPhoneCodeInView = false
     

     
        selectCountry.leftView = cpv
        selectCountry.leftViewMode = .always
        
        
        
        cp.showPhoneCodeInView = true
        PhoneNumber.leftView = cp
        
          spaceId = "\(db.collection("ActiveParkings").document(uid!).collection("parkingSpace").document().documentID)"
        PhoneNumber.leftViewMode = .always
        sideMenus()
        self.tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    
    
    @IBAction func rentSpace(_ sender: Any) {
        if self.PhoneNumber.text != "" && self.Fname.text != "" && self.Lname.text != "" && self.numberOfSpaces.text != "" && self.selectAddress.text != ""{
            SVProgressHUD.show()
            let geoFirestoreRef = Firestore.firestore().collection("marker")
                    let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
                    geoFirestore.setLocation(location: CLLocation(latitude: savLat!, longitude: savLon!), forDocumentWithID: spaceId) { (error) in
                        if (error != nil) {
                            print("An error occured: \(error)")
                        } else {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
                            let secondDate = formatter.date(from: "2010-11-22 07:43:19 +0000")
                            let date = Date().addingTimeInterval(-3600*60*60*24)
                            
                            
                            let user = ["Phone":self.PhoneNumber.text!,"firstname":self.Fname.text!,"lastname":self.Lname.text!,"numberofSpaces":self.numberOfSpaces.text!,"address":self.selectAddress.text!,"SpaceType":self.spaceType,"OwnerType":self.ownerType,"SpaceWidth":self.spaceWidth,"arriveData":date,"leaveData":date] as [String : Any]
                            
                            self.db.collection("ActiveParkings").document(self.userId).collection("parkingSpace").document(self.spaceId).setData(user) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    self.db.collection("Users").document(self.uid!).updateData(["Space":true])
                                    self.db.collection("Users").document(self.uid!).updateData(["SpaceId":self.spaceId])
                                    print("Document successfully written!")
                                    
                                    self.performSegue(withIdentifier: "parking", sender: self)
                                    SVProgressHUD.dismiss()
                                }
                            }

                            print("Saved location successfully!")
                        }
            }  
            
        }else{
            let alertVC = PMAlertController(title: "Fields are Empty", description: "Please check if any field is not empty ", image: #imageLiteral(resourceName: "your-logo-here"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: { () -> Void in
                print("Capture action Cancel")
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
    }
    
    
    @IBAction func country(_ sender: Any) {
        
    }
    
    @IBAction func findAddress(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func SpaceTypeButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
           self.spaceType = "Driveway"
           
            print("1")
        case 1:
           self.spaceType = "Garage"
       
            print("2")
        case 2:
           self.spaceType = "CarPark"
           
            print("3")
        default:
            break
        }
    }
    @IBAction func OwnerTypeButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
          self.ownerType = "Individual"
          
            print("1")
        case 1:
           self.ownerType = "Business"
           
            print("2")
            
        default:
            break
        }
        
    }
    @IBAction func SpaceWidthButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
           self.spaceWidth = "Normal"
          
            print("1")
        case 1:
           self.spaceWidth = "Narrow"
        
            print("2")
        default:
            break
        }
    }
    
    
    
    
    
}
extension RentSpaceTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        
        print("Place address: \(String(describing: place.formattedAddress))")
        self.selectAddress.text = place.formattedAddress!
        
        self.adress = place.formattedAddress!
        self.initLatitude = place.coordinate.latitude
        self.initLongitude = place.coordinate.longitude
        
        print("Place attributions: \(String(describing: place.attributions))")
        
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "Map2", sender: self)
        
        
        
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Map2" {
            let dest = segue.destination as! SelectAddressViewController
            dest.address = self.adress
                        dest.initLat = self.initLatitude
                        dest.initLong = self.initLongitude
                        dest.spaceId = self.spaceId
            dest.delegate = self
        }
    }
    
    
}

