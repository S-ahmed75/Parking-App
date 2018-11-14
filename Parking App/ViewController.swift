//
//  ViewController.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/11/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import GooglePlacePicker
import SVProgressHUD
import Firebase

protocol userSignInDelegate {
    func userSignIn(userFirstName:String,userSecondName:String,space:Bool)
    
}


class ViewController: UIViewController {
   
    
    @IBOutlet weak var langButt: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var menu: UIBarButtonItem!
    var address = ""
    var selected:Bool?
    var initLongitude:CLLocationDegrees?
    var initLatitude:CLLocationDegrees?
    let uid = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
  
    var delegate: userSignInDelegate?
     let autocompleteController = GMSAutocompleteViewController()
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
       
        
       
            autocompleteController.delegate = self
        
            present(autocompleteController, animated: true, completion: nil)
        
        
    }
    
        @objc func inputModeDidChange(_ notification: Notification) {
           
        }
    override func viewDidLoad() {
        super.viewDidLoad()
       let KuserDef = UserDefaults.standard
        KuserDef.synchronize()
        self.delegate = MenuViewController().self
        
       NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name: .UITextInputCurrentInputModeDidChange, object: nil)
        SVProgressHUD.show()
        
        if Auth.auth().currentUser != nil {
            signInButton.isHidden = true
            var spac = false
            db.collection("Users").document(uid!).getDocument { (snap, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }else{
                    if let document = snap, document.exists {
                        if let Fname = document.data()!["firstname"] as? String {
                            if let lname = document.data()!["lastname"] as? String {
                               
                                let user2 = ["userFirstName": Fname, "userSecondName": lname, "space": spac] as [String : Any]
                                KuserDef.set(user2, forKey: "user")
                                
                                if let space = document.data()!["Space"] as? Bool{
                                  spac = space
                                    
                                    let email = document.data()!["Email"] as? String
                                    let ownerType = document.data()!["OwnerType"] as? String
                                    let Phone = document.data()!["Phone"] as? String
                                    let spaceType = document.data()!["SpaceType"] as? String
                                    let spaceWidth = document.data()!["SpaceWidth"] as? String
                                    let address = document.data()!["address"] as? String
                                   
                                    let numberofSpaces = document.data()!["numberofSpaces"] as? String
                                    let password = document.data()!["password"] as? String
                                    
                                    let user = ["userFirstName": Fname, "userSecondName": lname, "space": spac, "Email": email!, "OwnerType": ownerType!, "Phone": Phone!, "SpaceType": spaceType!, "SpaceWidth": spaceWidth!, "address": address!, "numberofSpaces": numberofSpaces!, "password": password!] as [String : Any]
                                    print("uwwww")
                                    //let user2 = ["userFirstName": Fname, "userSecondName": lname, "space": spac] as [String : Any]
                                    KuserDef.set(user, forKey: "user")
                                  //  self.delegate?.userSignIn(userFirstName: Fname, userSecondName: lname, space: space)
                                    SVProgressHUD.dismiss()
                                    KuserDef.synchronize()
                                }else{
                                    SVProgressHUD.dismiss()
                                }

                            }

                        }

                    }

                }
            }
            
        } else {
            signInButton.isHidden = false
            let user2 = ["userFirstName": "Fname", "userSecondName": "lname", "space": false] as [String : Any]
            KuserDef.set(user2, forKey: "user")
         //    self.delegate?.userSignIn(userFirstName: "123", userSecondName: "123", space: false)
            SVProgressHUD.dismiss()
        }
        KuserDef.synchronize()
        sideMenus()
    }

    override func viewWillAppear(_ animated: Bool) {
        if L102Language.currentAppleLanguage() == "en" {
          autocompleteController.delegate = self
            GMSAutocompleteViewController().navigationItem.searchController?.searchBar.placeholder = "Search"
            
            print("otheee",L102Language.currentAppleLanguage())
            
        } else {
            print("otheeee",L102Language.currentAppleLanguage())
            autocompleteController.delegate = self
            GMSAutocompleteViewController().navigationItem.searchController?.searchBar.placeholder = "Buscar"

        }
    }
    
    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }



}

extension ViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {
            print("Place name: \(place.name)")
            
            print("Place address: \(String(describing: place.formattedAddress))")
            self.address = place.formattedAddress!
            self.initLatitude = place.coordinate.latitude
            self.initLongitude = place.coordinate.longitude
            self.selected = true
            print("Place attributions: \(String(describing: place.attributions))")
            
            DispatchQueue.main.async {
               
                self.performSegue(withIdentifier: "Map1", sender: nil)
                
                SVProgressHUD.dismiss()
            }
        }

        
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
        if segue.identifier == "Map1" {
            let dest = segue.destination as! MapViewController1
            dest.adres = self.address
            dest.Selected = self.selected
            dest.selected1 = true
            dest.initLat = self.initLatitude
            dest.initLong = self.initLongitude
            
        }
        self.dismiss(animated: true, completion: nil)
    }

}




