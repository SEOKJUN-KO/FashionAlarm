//
//  SetLocationViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/14.
//

import UIKit
import CoreLocation
import MapKit

class SetLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var detailResult: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCoordinates()
    }
    
    @IBAction func forwardGeoCoding(_ sender: Any) {
        guard let address = locationTextField.text else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first else {
                self.detailResult.text = "지역 검색 결과가 없습니다."
                self.detailResult.isHidden = false
                return
            }
            self.detailResult.isHidden = false
            let address = "\(placemark.locality ?? "") \(placemark.name ?? "")"
            self.detailResult.text = address
            guard let lat = placemark.location?.coordinate.latitude else { return }
            guard let lon = placemark.location?.coordinate.longitude else { return }
            self.saveCoordinates(latitude: lat, longitude: lon, address: address)
            self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.001)), animated: false)
        }
    }
}

extension SetLocationViewController {
    private func saveCoordinates(latitude: Double, longitude: Double, address: String){
        let data = [ "latitude": latitude, "longitude": longitude ]
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "FashionAlarmCoordinates")
        userDefaults.set(address, forKey: "FashionAlarmAddress")
    }
    
    private func loadCoordinates(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "FashionAlarmCoordinates") as? [String: Double] else { return }
        guard let lat = data["latitude"] else { return }
        guard let lon = data["longitude"] else { return }
        latitude = lat
        longitude = lon
        guard let address = userDefaults.object(forKey: "FashionAlarmAddress") as? String else { return }
        detailResult.isHidden = false
        self.detailResult.text = address
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.001)), animated: false)
    }
}

