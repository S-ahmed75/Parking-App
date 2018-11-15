//
//  MenuViewController.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/15/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Localize


class MenuViewController: UIViewController,userSignInDelegate {
   
    
   
   
    
    
    var kUserDefault = UserDefaults.standard
    var space1 = false
    
    @IBOutlet weak var manageSpace: UIButton!
    @IBOutlet weak var reciedBookings: UIButton!
    @IBOutlet weak var rentYourspace: UIButton!
    
    
    
    @IBOutlet weak var name: UILabel!
    let uid = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
//        db.collection("Users").document("O8Of0yfK5QeSgLAvsY00Cs9PIUF3").getDocument { (snap, error) in
//            if error != nil {
////                print(snap?.value(forKey: "firstname"))
////                print(error?.localizedDescription)
//            }else{
//                if let document = snap, document.exists {
//                    if let Fname = document.data()!["firstname"] as? String {
//                        if let lname = document.data()!["lastname"] as? String {
//                            if let space = document.data()!["Space"] as? Bool{
////                                print("butt",snap)
////                                print("haris",snap?.value(forKey: "firstname"))
//
//
//                            }
//
//                        }
//
//                    }
//
//                }
//
//            }
//        }
////        localize()
////
////        let locale = Locale.preferredLanguages.first?.components(separatedBy: "-").first?.lowercased() ?? "es"
////
////        NotificationCenter.default.addObserver(
////            self,
////            selector: #selector(localize),
////            name: NSNotification.Name(localizeChangeNotification),
////            object: nil
////        )
////
////        Localize.shared.update(language: locale)
//
////        if Auth.auth().currentUser != nil {
////            db.collection("Users").document(uid!).getDocument { (snap, error) in
////                if error != nil {
////                    print(error?.localizedDescription)
////                }else{
////                    if let document = snap, document.exists {
////                        if let Fname = document.data()!["firstname"] as? String {
////                            if let lname = document.data()!["lastname"] as? String {
////                                if let space = document.data()!["Space"] as? Bool{
////                                    self.space1 = space
////
////                                    if self.space1 == true {
////                                        self.rentYourspace.isHidden = true
////                                        self.reciedBookings.isHidden = false
////                                        self.manageSpace.isHidden = false
////                                    }
////
////                                }
////                                self.name.text = "\(Fname) \(lname)"
////
////                            }
////
////                        }
////
////                    }
////
////                }
////            }
////        }else{
////            print("nothing")
////        }
//
//
    }

    override func viewWillAppear(_ animated: Bool) {
        let dicti = kUserDefault.object(forKey: "user")  as! Dictionary<String,Any>
        var name123 = ""
        var last123 = ""
        var vidid123 = ""
        
        for value in dicti{
            if value.key == "userFirstName" {
                name123 = value.value as! String
            }
            if value.key == "userSecondName"{
                last123 = value.value as! String
            }
            if value.key == "space"{
                space1 = value.value as! Bool
                
            }
            if self.space1 == true {
                self.rentYourspace.isHidden = true
                self.reciedBookings.isHidden = false
                self.manageSpace.isHidden = false
            }else
                if self.space1 == false {
                    self.rentYourspace.isHidden = false
                    self.reciedBookings.isHidden = true
                    self.manageSpace.isHidden = true
            }
            
            print("calllll")
            self.name.text = "\(name123) \(last123)"
            
            
        }

    }
    @objc public func localize() {
//        yourLabel.text = "app.names".localize(values: "mark", "henrry", "peater")
//        otherLabel.text = "app.username".localize(value: "Your username")
    }

    @IBAction func Bookings(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "bookings", sender: self)
        } else {
            self.performSegue(withIdentifier: "log", sender: self)
        }
        
    }

    @IBAction func help(_ sender: Any) {
    }
    @IBAction func rentSapce(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "Rent", sender: self)
        } else {
            self.performSegue(withIdentifier: "log", sender: self)
        }
        
    }
    @IBAction func Home(_ sender: Any) {
        self.performSegue(withIdentifier: "mainView", sender: self)
    }
    @IBAction func profile(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "profile", sender: self)
        } else {
             self.performSegue(withIdentifier: "log", sender: self)
        }
        
    }
    
    @IBAction func langButton(_ sender: Any) {
//        let actionSheet = UIAlertController(
//            title: nil,
//            message: "app.update.language".localize(),
//            preferredStyle: UIAlertControllerStyle.actionSheet
//        )
//
//        for language in Localize.availableLanguages {
//            let displayName = Localize.displayNameForLanguage(language)
//            let languageAction = UIAlertAction(
//                title: displayName,
//                style: .default,
//                handler: { (_: UIAlertAction!) -> Void in
//
//                    Localize.update(language: language)
//            })
//            actionSheet.addAction(languageAction)
//        }
//        let cancelAction = UIAlertAction(
//            title: "Cancel",
//            style: UIAlertActionStyle.cancel,
//            handler: nil
//        )
//
//        actionSheet.addAction(cancelAction)
//        self.present(actionSheet, animated: true, completion: nil)
////
        let transition: UIViewAnimationOptions = .transitionFlipFromLeft

        if L102Language.currentAppleLanguage() == "en" {
            L102Language.setAppleLAnguageTo(lang: "es")
          //  langButt.setTitle("¿Español?", for: .normal)
            // langButt.titleLabel?.text = "English?"

            print("es")
        } else {
            L102Language.setAppleLAnguageTo(lang: "en")
           // langButt.setTitle("English", for: .normal)
            print("eniii")
        }
        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "rootNav")
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
        }) { (finished) -> Void in

        }
        loadView()
        
       
    }
    func userSignIn(userFirstName: String, userSecondName: String, space: Bool) {
        
//        self.space1 = space
//        if self.space1 == true {
//            self.rentYourspace.isHidden = true
//            self.reciedBookings.isHidden = false
//            self.manageSpace.isHidden = false
//        }else
//            if self.space1 == false {
//                self.rentYourspace.isHidden = false
//                self.reciedBookings.isHidden = true
//                self.manageSpace.isHidden = true
//            }
//        print("calllll")
//        self.name.text = "\(userFirstName) \(userSecondName)"
//
    }

}


