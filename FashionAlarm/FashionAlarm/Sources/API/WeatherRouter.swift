//
//  WeatherRouter.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/09/21.
//

import Foundation

enum WeatherRouterInit{
    case getWeather(query: [String: String])
}

class WeatherRouter{
    
    var weatherRouterInit: WeatherRouterInit?
    init(weatherRouterInit: WeatherRouterInit){
        self.weatherRouterInit = weatherRouterInit
    }
    
    var endPoint: String {
        switch weatherRouterInit!{
        case .getWeather:
            return "weather?"
        }
    }
    
    var baseURL: URLComponents {
        return URLComponents(string: API.BASE_URL+endPoint)!
    }
    
    var method: String {
        switch weatherRouterInit!{
        case .getWeather:
            return "GET"
        }
    }

    var parameters: [String: String] {
        switch weatherRouterInit!{
        case let .getWeather(query):
            return query
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlComponents = baseURL
        for p in parameters{
            urlComponents.queryItems?.append(URLQueryItem(name: p.key, value: p.value))
        }
        let url = urlComponents.url!
//        print("WeatherUrl - asURLRequest() url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = method
        if(method == "POST"){
            let requestBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = requestBody
        }
        return request
    }
}

//extension URLRequest { // Interceptor 대체
//    init(_ url: URL) {
//        self.init(url: url)
//        self.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        self.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Accept")
//    }
//}
