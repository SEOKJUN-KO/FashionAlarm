//
//  AlarmResult.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/09/07.
//

import Foundation

struct AlarmResult{
    let weather: String
    let maxTmp: Double
    let minTmp: Double
    let recommend: String
    let location: Location
}

struct Location{
    let address: String
    let latitude: Double
    let longitude: Double
}
