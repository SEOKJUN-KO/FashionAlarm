//
//  SetLocationViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/14.
//

import UIKit
import CoreLocation
import MapKit

class SetLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var detailResult: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    let storage = Storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isScrollEnabled = false
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCoordinates()
    }
    
    @IBAction func setLocation(_ sender: Any) {
        forwardGeocoding()
    }
}

extension SetLocationViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        forwardGeocoding()
        return false
    }
    
    private func forwardGeocoding(){
        guard let address = locationTextField.text else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first else {
                self.detailResult.text = "지역 검색 결과가 없습니다."
                self.locationTextField.text = ""
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    } // 유저가 빈 화면을 터치하면 키보드나 피커가 다시 내려감
    
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

