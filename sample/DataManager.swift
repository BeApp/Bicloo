//
//  DataManager.swift
//  sample
//
//  Created by Cedric G on 18/05/2016.
//  Copyright © 2016 Cedric G. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class DataManager: NSObject {

    var datas: [Bicloo] = []
    
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    //MARK: - Life
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - shared
    
    class var sharedData : DataManager {
        struct Static {
            static let instance = DataManager()
        }
        return Static.instance
    }
    
    // MARK: - Data
    
    func loadData(done callback:@escaping ()->()) {
        let params = ["contract":"Nantes","apiKey":"5dc69b6d9123fb82eb410addb1084b86299a9cd6"]
        Alamofire.request("https://api.jcdecaux.com/vls/v1/stations", parameters: params)
            .validate()
            .responseJSON { response in
                guard let datas = response.result.value as? [AnyObject] else {
                    return
                }
                var velos: [Bicloo] = []
                for data in datas {
                    let velo = Bicloo(raw: data as! Dictionary<String, AnyObject>)
                    velos.append(velo)
                }
                self.datas = velos
                Bicloo.saveBicloos(velos)
                callback()
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension DataManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
}

