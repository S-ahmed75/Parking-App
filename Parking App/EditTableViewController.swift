//
//  EditTableViewController.swift
//  
//
//  Created by Mohammad Ali Panhwar on 10/2/18.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import Firebase
import Geofirestore
import PMAlertController
class EditTableViewController: UITableViewController {

    
    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var spaceType = "Driveway"
    var ownerType = "Individual"
    var spaceWidth = "Normal"
    var spaceID = ""
    var userId = ""
    
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var City: UILabel!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var SpaceType: UISegmentedControl!
    @IBOutlet weak var numberOfSpaces: UITextField!
    @IBOutlet weak var OwnerType: UISegmentedControl!
    @IBOutlet weak var WidthSpace: UISegmentedControl!
    @IBOutlet weak var PricePerHour: UITextField!
    @IBOutlet weak var PricePerDay: UITextField!
    @IBOutlet weak var PricePerWeek: UITextField!
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
         sideMenus()
        
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
        
        
        db.collection("Users").document(uid!).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                self.spaceID = document.data()!["SpaceId"] as! String
          
        
        let geoFirestoreRef = Firestore.firestore().collection("marker")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
       
                geoFirestore.getLocation(forDocumentWithID: self.spaceID) { (location: CLLocation?, error) in
            if (error != nil) {
                print("An error occurred: \(error)")
            } else if (location != nil) {
                print("Location: [\(location!.coordinate.latitude), \(location!.coordinate.longitude)]")
                let marker = GMSMarker()
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "parking-sign"), scaledToSize: CGSize(width: 40, height: 40))
                marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                marker.map = self.MapView
                
                let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 13)
                self.MapView.camera = camera
            } else {
                print("GeoFirestore does not contain a location for this document")
            }
        }
        
           
       
                self.db.collection("ActiveParkings").document(self.userId).collection("parkingSpace").document(self.spaceID).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let spaceType = document.data()!["SpaceType"] as! String
                let ownerType = document.data()!["OwnerType"] as! String
                let spacewidth = document.data()!["SpaceWidth"] as! String
                let numberofSpaces = document.data()!["numberofSpaces"] as! String
                let address = document.data()!["address"] as! String
                if let pricePerhour = document.data()!["pricePerHour"] as? String{
                    if let pricePerday = document.data()!["pricePerDay"] as? String{
                        if let pricePerweek = document.data()!["pricePerWeek"] as? String{
                            self.PricePerHour.text = pricePerhour
                            self.PricePerDay.text = pricePerday
                            self.PricePerWeek.text = pricePerweek
                        }
                    }
                }
                
                
                
                if spaceType == "Driveway" {
                    self.SpaceType.selectedSegmentIndex = 0
                }else if spaceType == "Garage"{
                    self.SpaceType.selectedSegmentIndex = 1
                }else if spaceType == "CarPark"{
                    self.SpaceType.selectedSegmentIndex = 2
                }
                if spacewidth == "Normal" {
                    self.WidthSpace.selectedSegmentIndex = 0
                }else if spacewidth == "Narrow"{
                    self.WidthSpace.selectedSegmentIndex = 1
                }
                if ownerType == "Individual" {
                    self.OwnerType.selectedSegmentIndex = 0
                }else if ownerType == "Business"{
                    self.OwnerType.selectedSegmentIndex = 1
                }
                self.numberOfSpaces.text = numberofSpaces
                self.country.text = address
            } else {
                print("Document does not exist")
            }
        }
            }
            
        }
        MapView.settings.scrollGestures = false
        MapView.settings.zoomGestures = false
    }
    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
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
    @IBAction func TypeofSpaceButton(_ sender: UISegmentedControl) {
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
    @IBAction func widthSpaceButton(_ sender: UISegmentedControl) {
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
    
    @IBAction func OwnerType(_ sender: UISegmentedControl) {
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
    @IBAction func SaveButton(_ sender: Any) {
        if self.numberOfSpaces.text != "" && self.PricePerHour.text != "" && self.PricePerDay.text != "" && self.PricePerWeek.text != "" {
            
            let user = ["SpaceType":self.spaceType,"OwnerType":self.ownerType,"SpaceWidth":self.spaceWidth,"numberofSpaces":self.numberOfSpaces.text!,"pricePerHour":self.PricePerHour.text!,"pricePerDay":self.PricePerDay.text!,"pricePerWeek":self.PricePerWeek.text!]
            
            self.db.collection("ActiveParkings").document(userId).collection("parkingSpace").document(self.spaceID).updateData(user) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                   
                    print("Document successfully written!");
                    
                 
            _ = self.navigationController?.popViewController(animated: true)
                }}
        }else{
            let alertVC = PMAlertController(title: "Something Empty", description: "Recheck all the fields and try again.", image: #imageLiteral(resourceName: "your-logo-here"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: { () -> Void in
                print("Capture action Cancel")
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
        
        
        
    }
    
     @IBAction func DeleteButton(_ sender: Any) {

        let alertVC = PMAlertController(title: "Remove Space", description: "Do you want to delete this space?.", image: #imageLiteral(resourceName: "your-logo-here"), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () -> Void in
            let geoFirestoreRef = Firestore.firestore().collection("marker")
            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
            geoFirestore.removeLocation(forDocumentWithID: self.spaceID, completion: { (error) in
                if error != nil {
                    print("error in delete")
                }else{
                    self.db.collection("ActiveParkings").document(self.userId).collection("parkingSpace").document(self.spaceID).delete()
                      _ = self.navigationController?.popViewController(animated: true)
                    print("deleted")
                }
                
            });
        }))
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Capture action Cancel")
        }))
        
        self.present(alertVC, animated: true, completion: nil)

    }
}
