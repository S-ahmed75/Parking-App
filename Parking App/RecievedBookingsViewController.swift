//
//  RecievedBookingsViewController.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/28/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SVProgressHUD


class RecievedBookingsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var noData: UIView!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noData.isHidden = true
        tableView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        sideMenus()
        
    }
    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }


    
    
    var arr:[booker] = []
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var userId = ""
    var bookingId = ""
    
   
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.show()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        loaddata()
    }
 
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  arr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as! receivedBookingTableViewCell
        cell.dispDate.text = "Starts:\(arr[indexPath.row].arriveData)"
        cell.dispDate.sizeToFit()
        cell.endDate.text = "   End:\(arr[indexPath.row].leaveData) "
        cell.endDate.sizeToFit()
        
        cell.displayName.text = "\(arr[indexPath.row].bookerName)"
        cell.displayName.sizeToFit()
       
        cell.phone.text = "\(arr[indexPath.row].bookSpace)"
        cell.phone.sizeToFit()
        
       
        
        cell.cancelBookingOutline.tag = indexPath.row
        cell.cancelBookingOutline.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
//        cell.cancelBookingOutlet.tag = indexPath.row
        
        
        //        cell.prices.text = arr[indexPath.row].price
        //    arr.removeAll()
        return cell
    }
    @objc func buttonPressed(sender: UIButton!) {
print("yahooooo")
        let buttonTag = sender.tag
        print(buttonTag)
        arr.remove(at: buttonTag)
        tableView.reloadData()
        //        let button = sender as? UIButton
//        let cell = button?.superview?.superview as? UITableViewCell
//        let indexPath = tableView.indexPath(for: cell!)
//        print(arr[(indexPath?.row)!].spaceId,"deleted")
//
//        let alert = UIAlertController(title: "Cancel Booking", message: "are you sure to cancel booking?", preferredStyle: UIAlertControllerStyle.alert)
//        let  yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
//            SVProgressHUD.show()
//            let indexPath = self.tableView.indexPathForSelectedRow
//
//            //getting the current cell from the index path
//            let currentCell = self.tableView.cellForRow(at: indexPath!)! as UITableViewCell
//
//            //getting the text of that cell
//            let currentItem = currentCell.tag
//
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd/MM/yyyy"
//            let firstDate = formatter.date(from: "10/08/1990")
//            let bookSpa = self.arr[(indexPath?.row)!].bookSpace - self.arr[(indexPath?.row)!].noOfSpace
//            let ownId = self.arr[(indexPath?.row)!].ownerId
//            let spa = self.arr[(indexPath?.row)!].spaceId
//
//            let user3 = ["arriveData":firstDate,"leaveData":firstDate,"bookSpace": "\(bookSpa)"] as [String : Any]
//            print(user3,"yahah")
//            self.db.collection("ActiveParkings").document(ownId).collection("parkingSpace").document(spa).updateData(user3) { errr in
//                if let errr = errr {
//                    print("Error writing document: \(errr)")
//                } else {
//                    print("donee")
//                }}
//
//            //            self.db.collection("bookingId").document(self.bookingId).delete()
//            //
//            self.dismiss(animated: true, completion: nil)})
//        let Cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.dismiss(animated: true, completion: nil)})
//
//        alert.addAction(yes)
//        alert.addAction(Cancel)
//        self.present(alert, animated:true, completion: nil)

    }
    
    
    func loaddata(){
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
        DispatchQueue.global(qos: .background).async {
            self.db.collection("bookingId").getDocuments() { (querySnapshot, err) in
                self.arr.removeAll()
                self.tableView.reloadData()
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let addre = document.data()["address"] as! String
                        let arriveData = document.data()["arriveData"] as! Date
                        let bookingId = document.data()["bookingId"] as! String
                        
                        let bookerId = document.data()["bookerId"] as! String
                        let leaveData = document.data()["leaveData"] as! Date
                        let spaceId = document.data()["spaceId"] as! String
                        let ownerId = document.data()["ownerId"] as! String
                        let noOfSpace = document.data()["numberofSpaces"] as! String
                        let noOfBooking = document.data()["bookSpace"] as! Int
                        let curentDate = Date()
                        
                        var bookerName = ""
                        if self.userId == ownerId{
                            
                            self.db.collection("Users").document(bookerId).getDocument(completion: { (snaps2, errr) in
                                            if let doc3 =  snaps2, doc3.exists{
                                                print(doc3.data(),"mieeee222")
                                                let bkId = doc3.data()!["userId"] as! String
                                                let firstname = doc3.data()!["firstname"] as! String
                                                let lastname = doc3.data()!["lastname"] as! String
                                                
                                                if doc3.documentID == bookerId{
                                                print("kkkkk")
                                                bookerName = "\(firstname) \(lastname)"
                                                    let ar = booker(address: addre, arriveData: arriveData, bookSpace: noOfBooking, bookingID: bookingId, bookerId: bookerId, leaveData: leaveData, spaceId: spaceId, ownerId:ownerId, noOfSpace: 1, bookerName: bookerName.capitalized)
                                                    self.arr.append(ar)
                                                    print("aeses hi")
                                                    self.tableView.reloadData()
                                                }
                                                
                                                
                                                
                                }
                                if self.arr.isEmpty == false{
                                    self.tableView.isHidden = false
                                }else{
                                    self.noData.isHidden = false
                                }

                            })
                            
                            
                            
                           // let noOfSpa:Int = Int(noOfSpace)! + 1
                            
                            
                         
                        }
                        
                    }
                }
            }
            //
            //        self.db.collection("Users").document(self.uid!).getDocument(completion: { (snaps, errr) in
            //            if let doc2 =  snaps, doc2.exists{
            //                print(doc2.data(),"mieeee")
            //                for d in doc2.data()!{
            //
            //                    var numberofSpa:Int = 0
            //                    var bookSpac:Int = 0
            //
            //                    if d.key == "userId"{
            //                        let  u:String = d.value as! String
            //                        self.userId = u
            //
            //                    }
            //                }}
            //        })
            
            
            //
            //        DispatchQueue.global(qos: .background).async {
            //            var spaceID = ""
            //
            //            self.db.collection("Users").document(self.uid!).getDocument { (document, error) in
            //                self.arr.removeAll()
            //                self.tableView.reloadData()
            //
            //
            //
            //            }
            DispatchQueue.main.async {
                //
                SVProgressHUD.dismiss()
            }
            //        }
        }
    }

    
    
}
