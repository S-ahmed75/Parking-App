//
//  bookedListTableViewController.swift
//  Parking App
//
//  Created by sunny on 24/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SVProgressHUD
struct booker {
    var address:String
    var arriveData: Date
    var bookSpace :Int
    var  bookerId :String
    var leaveData : Date
    var spaceId: String
    var ownerId: String
    var noOfSpace : Int
    
}


class bookedListTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    @IBOutlet weak var noDataView: UIView!
    
    @IBOutlet weak var menu: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var arr:[booker] = []
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var userId = ""
    var bookingId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataView.isHidden = true
        tableView.isHidden = true
    
        tableView.dataSource = self
        tableView.delegate = self
        sideMenus()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.show()

        loaddata()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
   

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
   
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return  arr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! bookedListCellTableViewCell
        cell.bookingDate.text = "Starts:\(arr[indexPath.row].arriveData) End:\(arr[indexPath.row].leaveData) "
        cell.bookingDate.sizeToFit()
        cell.address.text = "\(arr[indexPath.row].address)"
        cell.address.sizeToFit()
        cell.cancelBookingOutlet.tag = indexPath.row
        
       
//        cell.prices.text = arr[indexPath.row].price
        //    arr.removeAll()
        return cell
    }
    func buttonPressed(_ sender: AnyObject) {
        let button = sender as? UIButton
        let cell = button?.superview?.superview as? UITableViewCell
        let indexPath = tableView.indexPath(for: cell!)
        print(arr[(indexPath?.row)!])
        
        let alert = UIAlertController(title: "Cancel Booking", message: "are you sure to cancel booking?", preferredStyle: UIAlertControllerStyle.alert)
        let  yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
          SVProgressHUD.show()
            let indexPath = self.tableView.indexPathForSelectedRow
            
            //getting the current cell from the index path
            let currentCell = self.tableView.cellForRow(at: indexPath!)! as UITableViewCell
            
            //getting the text of that cell
            let currentItem = currentCell.tag
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let firstDate = formatter.date(from: "10/08/1990")
            let bookSpa = self.arr[(indexPath?.row)!].bookSpace - self.arr[(indexPath?.row)!].noOfSpace
            let ownId = self.arr[(indexPath?.row)!].ownerId
            let spa = self.arr[(indexPath?.row)!].spaceId
            
            let user3 = ["arriveData":firstDate,"leaveData":firstDate,"bookSpace": "\(bookSpa)"] as [String : Any]
           print(user3,"yahah")
            self.db.collection("ActiveParkings").document(ownId).collection("parkingSpace").document(spa).updateData(user3) { errr in
                if let errr = errr {
            print("Error writing document: \(errr)")
                } else {
                    print("donaa")
                }}
            
//            self.db.collection("bookingId").document(self.bookingId).delete()
//
            self.dismiss(animated: true, completion: nil)})
        let Cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.dismiss(animated: true, completion: nil)})
        
        alert.addAction(yes)
        alert.addAction(Cancel)
        self.present(alert, animated:true, completion: nil)
        
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
                    let bookerId = document.data()["bookerId"] as! String
                    let leaveData = document.data()["leaveData"] as! Date
                    let spaceId = document.data()["spaceId"] as! String
                    let ownerId = document.data()["ownerId"] as! String
                    let noOfSpace = document.data()["numberofSpaces"] as! String
                    if self.uid == bookerId{
                        let noOfSpa:Int = Int(noOfSpace)! + 1
                        
                        let ar = booker(address: addre, arriveData: arriveData, bookSpace: 1, bookerId: bookerId, leaveData: leaveData, spaceId: spaceId, ownerId:ownerId, noOfSpace: noOfSpa)
                        self.arr.append(ar)
                        
                        self.tableView.reloadData()
                    }
                    
                }
            }
            if self.arr.isEmpty == false{
                self.tableView.isHidden = false
            }else{
                self.noDataView.isHidden = false
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
//                if let document = document, document.exists {
//                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                    print("Document data: \(dataDescription)")
//                    
//                    
//                    
//                    self.db.collection("ActiveParkings").document(self.userId).collection("parkingSpace").getDocuments() { (document, error) in
//                        print("tiiii")
//                        
//                        if let errr = error {
//                            print("Document Does not Exits")
//                            
//                        } else {
//                            for document in document!.documents{
//                                print(document,"Docccccc not Exits")
//                                
//                                let spaceType = document.data()["SpaceType"] as! String
//                                let ownerType = document.data()["OwnerType"] as! String
//                                let spacewidth = document.data()["SpaceWidth"] as! String
//                                let phone = document.data()["Phone"] as! String
//                                let numberofSpaces = document.data()["numberofSpaces"] as! String
//                                
//                                
//                                if let price = document.data()["pricePerHour"] as? String {
//                                  //  self.price1 = price
//                                }
//                                if let bookerId = document.data()["bookerId"] as? String {
//                                    print("chal to gaya")
//                                }
//                                
////                                let ar = Parkings(ownerType: ownerType, Phone: phone, spaceType: spaceType, SpaceWidth: spacewidth, numberOfspaces: numberofSpaces, price: "18")
////                                self.arr.append(ar)
////
////                                self.tableView.reloadData()
//                                
//                                print(spaceType)
//                            }
//                        }
//                    }}
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
