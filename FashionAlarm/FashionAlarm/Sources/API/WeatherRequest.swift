//
//  WeatherRequest.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/09/21.
//

import Foundation

enum WeatherRequest: URLRequest {
    case getWeather(term: String)
    
    var baseURL: URL {
        return URL(string: API.BASE_URL + "weather?")!
    }
    
    
}

