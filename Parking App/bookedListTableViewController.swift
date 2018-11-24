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


class bookedListTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    @IBOutlet weak var noDataView: UIView!
    
    @IBOutlet weak var menu: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var arr:[Parkings] = []
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var userId = ""
    
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
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return    1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! bookedListCellTableViewCell
//        cell.Space3.text = "\(arr[indexPath.row].ownerType) \(arr[indexPath.row].spaceType) - (\(arr[indexPath.row].numberOfspaces) space)"
//        cell.Space3.sizeToFit()
//        cell.Edit.tag = indexPath.row
//        cell.Edit.addTarget(self, action: #selector(ManageSpaceViewController.segue(_sender:)), for: UIControlEvents.touchUpInside)
//        cell.prices.text = arr[indexPath.row].price
        //    arr.removeAll()
        return cell
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
            var spaceID = ""
            
            self.db.collection("Users").document(self.uid!).getDocument { (document, error) in
                self.arr.removeAll()
                self.tableView.reloadData()
                
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    
                    self.db.collection("ActiveParkings").document(self.userId).collection("parkingSpace").getDocuments() { (document, error) in
                        print("tiiii")
                        
                        if let errr = error {
                            print("Document Does not Exits")
                            
                        } else {
                            for document in document!.documents{
                                print(document,"Docccccc not Exits")
                                
                                let spaceType = document.data()["SpaceType"] as! String
                                let ownerType = document.data()["OwnerType"] as! String
                                let spacewidth = document.data()["SpaceWidth"] as! String
                                let phone = document.data()["Phone"] as! String
                                let numberofSpaces = document.data()["numberofSpaces"] as! String
                                
                                
                                if let price = document.data()["pricePerHour"] as? String {
                                  //  self.price1 = price
                                }
                                if let bookerId = document.data()["bookerId"] as? String {
                                    print("chal to gaya")
                                }
                                
//                                let ar = Parkings(ownerType: ownerType, Phone: phone, spaceType: spaceType, SpaceWidth: spacewidth, numberOfspaces: numberofSpaces, price: "18")
//                                self.arr.append(ar)
//
//                                self.tableView.reloadData()
                                
                                print(spaceType)
                            }
                        }
                    }}
                
            }
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
            }
        }
    }
    
}
