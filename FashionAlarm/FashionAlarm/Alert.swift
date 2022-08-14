//
//  Alert.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/14.
//

import Foundation

struct Alert: Codable {
    var id: String = UUID().uuidString // 알람의 아이디 값
    let date: Date // 시간
    var isOn: Bool // 알람이 켜져 있는지
}
