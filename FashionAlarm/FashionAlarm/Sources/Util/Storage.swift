//
//  Storage.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/09/10.
//

import Foundation

class Storage {
    
    private let store = UserDefaults.standard
    
    func setLocation(key: String, data: [String: Double]){
        store.set(data, forKey: key)
    }
    
    func getLocation(key: String) -> [String: Double]{
        guard let data = store.object(forKey: "FashionAlarmCoordinates") as? [String: Double] else { return [String:Double]() }
        return data
    }
    
    func setAddress(key: String, data: String){
        store.set(data, forKey: key)
    }
    
    func getAddress(key: String) -> String{
        guard let address = store.object(forKey: "FashionAlarmAddress") as? String else { return "" }
        return address
    }
}
