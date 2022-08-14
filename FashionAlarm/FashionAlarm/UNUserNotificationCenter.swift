//
//  UNUserNotificationCenter.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/14.
//

import UserNotifications

extension UNUserNotificationCenter {
    func addNotificationRequest(by alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = "일어날 시간이에요!"
        content.body = "앱을 실행시켜 오늘의 날씨에 맞는 옷 카테고리를 확인하세요"
        content.sound = .default
        content.badge = 1
        
        let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date) // 테이블 셀에 해당하는 alert 객체에서 시, 분을 뽑아 컴퍼넌트 만듬
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alert.isOn) // 특정 시간에 알림 발송하는데 사용 // repeats = 반복여부
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger) // 리퀘스트 생성
        
        self.add(request, withCompletionHandler: nil) // 리퀘스트를 UNUserNotificationCenter에 추가
    }
}
