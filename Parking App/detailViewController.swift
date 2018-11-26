//
//  ModalViewController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseFirestore
import Firebase
import Geofirestore
import GeoFire
import SVProgressHUD

class detailViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var noOfSpacesAvailable: UILabel!
    var addr = ""
    var mark = GMSMarker()
    var ariveDAte:Date?
    var leavDate:Date?
    var noOfSpace = "0"
    var bookSpace = 0
    var bookingId = ""
    
    let uid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
       super.viewDidLoad()
        address.text = addr
        noOfSpacesAvailable.text = noOfSpace
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        
        let location = CLLocation(latitude: mark.position.latitude, longitude: mark.position.longitude)
        let geoFirestoreRef = Firestore.firestore().collection("marker")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        let geo = geoFirestore.query(withCenter: location, radius: 1000)
        
        geo.observe(.documentEntered, with: { (key, location) in
            
            var keyy:String = key!
            print("runnnn",keyy,location?.coordinate,self.mark.position)
            if location?.coordinate.latitude == self.mark.position.latitude && location?.coordinate.longitude == self.mark.position.longitude {
                print("this is lcc")
        self.db.collection("ActiveParkings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                
                for document in querySnapshot!.documents {
                    let doc = document.documentID
                    print(doc,"b1b",document.data())
                   
                    self.db.collection("ActiveParkings").document(doc).collection("parkingSpace").document(keyy).getDocument() { querySnapsho,errr  in
                        if let errr = errr {
                            print("Error writing document: \(errr)")
                        } else {
                           
                            let d1:String =  (querySnapsho?.documentID)!
                            
                            if keyy == d1{
        /* data is coming */
                                print(querySnapsho?.data(),"ppp")
                                
                                self.db.collection("ActiveParkings").document(doc).collection("parkingSpace").document(d1).getDocument { (snap, error) in
                                    if error != nil {
                                        print(error?.localizedDescription)
                                    }else{
                                        if let document = snap, document.exists {
                                            if let numberofSpac = document.data()!["numberofSpaces"] as? String {
//                                               self.noOfSpace = numberofSpac
//                                                print("finnnn",self.noOfSpace)
                                            }
                                            
                                            
                                        }}}
//                                if let d22 = querySnapshot, document.exists {
//                                   print("yahan to aja",d22.count)
//                                    if let Fname = document.data()["address"] as? String {
//                                        print("finnnn",Fname)
//                                    }}
                            
                            }else{print("cartoon",keyy,doc)}
                            
                        }
                       
                    }
                
                }
            }
                }
            }})
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.noOfSpace = "0"
        self.bookSpace = 0
        self.viewDidLoad()
        print(noOfSpace,"detailllll")
        
    }
    
    func add(add:String, marker:GMSMarker,ariveDate:Date, leaveDate:Date,noOfSpaces:String,sendBookSpace: Int){
        
     self.mark = marker
        self.addr = add
        self.ariveDAte = ariveDate
        self.leavDate = leaveDate
        self.noOfSpace = noOfSpaces
       self.bookSpace = sendBookSpace
        
    }
    @IBAction func paymentButtonTapped(sender: AnyObject) {
      
        if  ariveDAte != nil || leavDate != nil{
        
           
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
             let secondDate = formatter.date(from: "2018-11-22 07:43:19 +0000")
            
           print(ariveDAte)
            if ariveDAte?.compare(leavDate!) == .orderedSame {
           
            let alert = UIAlertController(title: "Error", message: "Please Confirm date", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated:true, completion: nil)
           
            ariveDAte = nil
            leavDate = nil
        }else{
                SVProgressHUD.show()
                bookingId = "\(db.collection("bookingId").document().documentID)"
                let location = CLLocation(latitude: mark.position.latitude, longitude: mark.position.longitude)
                let geoFirestoreRef = Firestore.firestore().collection("marker") 
                let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
                
                let geo = geoFirestore.query(withCenter: location, radius: 1000)
               
                geo.observe(.documentEntered, with: { (key, location) in
                    
                    if location?.coordinate.latitude == self.mark.position.latitude && location?.coordinate.longitude == self.mark.position.longitude {
                        
                        
                        
                        let key:String  = key!
                        let bookSpa:Int = self.bookSpace + 1
                        self.db.collection("ActiveParkings").getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                
                                for document in querySnapshot!.documents {
                                 let doc = document.documentID
                                    print(document,"mmmm")
                                    
                                    let user = ["arriveData":self.ariveDAte,"leaveData":self.leavDate,"bookSpace":bookSpa,"bookingId":self.bookingId] as [String : Any]
                                    self.db.collection("ActiveParkings").document(doc).collection("parkingSpace").document(key).updateData(user) { errr in
                                        if let errr = errr {
 /*add dates now nothing else*/                          print("Error writing document: \(errr)")
                                        } else {
                                           
                                            let user2 = ["arriveData":self.ariveDAte,"leaveData":self.leavDate,"bookSpace":1,"spaceId":key,"address":self.addr,"bookerId":self.uid,"bookingId":self.bookingId,"ownerId":doc,"numberofSpaces": self.noOfSpace] as [String : Any];
                                            self.db.collection("bookingId").document(self.bookingId).setData(user) { err in
                                                if let err = err {
                                                    print("Error writing document: \(err)")
                                                } else {}
                                            print(user2,"\(self.db.collection("bookingId").document(self.bookingId).setData(user2))","ttttt")
                                            }
                                            
                                        SVProgressHUD.dismiss()
                                            let alert = UIAlertController(title: "Status", message: "Space has Booked", preferredStyle: UIAlertControllerStyle.alert)
                                            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.dismiss(animated: true, completion: nil)})
                                            alert.addAction(ok)
                                            self.present(alert, animated:true, completion: nil)
                                            print("Document successfully writt")
                                            print(user.first!,"usssss")
                                        }
                                        print(self.db.collection("ActiveParkings").document("\(document)").collection("parkingSpace").document(key).updateData(user))
                                        }
                                    
                                      print("2222",self.db.collection("ActiveParkings").document("\(document)").collection("parkingSpace").document(key).updateData(user))
                                }
                                print(err,"yhshs",querySnapshot?.count,querySnapshot?.documents)
                            }
                         print("mark is gettt")
                        }
                        

                        print("mark is eqqqq")
                        
                    }else{
                        print("not foooo")
                    }
                    
                    
                }
                )
           
            }
        
        }else{
        let alert = UIAlertController(title: "Error", message: "Please Confirm date?", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
            self.present(alert, animated:true, completion: nil)
            
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
      
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToMap(sender: AnyObject) {
      print(mark.position.latitude,"kaaaaaaaaa")
        if mark.position.latitude != -180.0{
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(mark.position.latitude),\(mark.position.longitude)&directionsmode=driving")! as URL)
    
            }
         else {
            let alert = UIAlertController(title: "Error", message: "Google maps not installed", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated:true, completion: nil)
            }
            
            
        }
}

}
