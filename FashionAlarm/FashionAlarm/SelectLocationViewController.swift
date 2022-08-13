//
//  SelectLocationViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/12.
//

import UIKit
import CoreLocation

class SelectLocationViewController: UIViewController {
    
    let address = "가양"
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        geoCoding()
    }
    
    func geoCoding (){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("용담2동") { placemarks, error in
            print(placemarks)
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            print("Lat: \(lat), Lon: \(lon)")
        }
    }
}
