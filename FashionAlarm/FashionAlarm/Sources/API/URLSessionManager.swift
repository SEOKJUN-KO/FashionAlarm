//
//  URLSessionManager.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/09/21.
//

import Foundation

final class URLSessionManager {
    
    //싱글톤 패턴 적용
    static let shared = URLSessionManager()
    
    //interceptor
    
    //로거
    
    //세션
    var session = URLSession(configuration: .default)
}
