//
//  WeatherInformation.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/15.
//

import Foundation

struct WeatherInformation: Codable {
    // codable: 자신을 변환하거나 외부 표현으로 변환할 수 있는 type // 외부 표현: json과 같은 type
    
    let weather: [Weather]
    let temp: Temp
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case weather
        case temp = "main" // json에서 이름이 temp가 아닌 main이기 때문
        case name
    }
}

struct Weather: Codable {
    // json type의 data로 변환하고자 할 때, json type의 key와 사용자가 설정한 property의 이름과 type을 일치하게 해야함
    // json에서 weather안의 값들을 받기 위함
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Temp: Codable {
    // json에서 main안의 값들을 받기 위함
    let temp: Double
    let feelsLike: Double
    let minTemp: Double
    let maxTemp: Double
    
    enum CodingKeys: String, CodingKey {
        // json의 key와 다른 property의 이름을 대입
        case temp
        case feelsLike = "feels_like"
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
    }
}
