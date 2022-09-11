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
    
    let storage = Storage()
    
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
        storage.setLocation(key: "FashionAlarmCoordinates", data: data)
        storage.setAddress(key: "FashionAlarmAddress", data: address)
    }
    
    private func loadCoordinates(){
        let address = storage.getAddress(key: "FashionAlarmAddress")
        if( address == "") { return }
        let coordinates = storage.getLocation(key: "FashionAlarmCoordinates")
        detailResult.isHidden = false
        self.detailResult.text = address
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates["latitude"]!, longitude: coordinates["longitude"]!), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.001)), animated: false)
    }
}

