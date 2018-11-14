//
//  File.swift
//  youTube2
//
//  Created by sunny on 21/10/2018.
//  Copyright © 2018 sunny. All rights reserved.
//

import Foundation
import Reachability
import APESuperHUD

class ReachabilityManager {
    
    static let shared = ReachabilityManager()
     let image = UIImage(named: "networkError")!
    // 3. Boolean to track network reachability
    var networkStatus:Bool = false
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.Connection = .none
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!
  
   @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            
          APESuperHUD.show(style: .icon(image: image, duration: 4.0), title: "Network Error", message: "No Netowrk!")
          networkStatus = false
          debugPrint("Network became unreachable")
        case .wifi:
            
            networkStatus = true
            debugPrint("Network reachable through WiFi")
        case .cellular:
            
            networkStatus = true
            debugPrint("Network reachable through Cellular Data")
        }
    }
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged,object: reachability)
        
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: reachability)
    }
}
