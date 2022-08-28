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
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Morning-Kiss.mp3") )
        
        let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date) // 테이블 셀에 해당하는 alert 객체에서 시, 분을 뽑아 컴퍼넌트 만듬
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false) // 특정 시간에 알림 발송하는데 사용 // repeats = 반복여부
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger) // 리퀘스트 생성
        
        self.add(request, withCompletionHandler: nil) // 리퀘스트를 UNUserNotificationCenter에 추가
    }
    
    func addInfiniteNotificationRequest() {
        self.removePendingNotificationRequests(withIdentifiers: ["FashionAlarmInfiniteAlarmOne", "FashionAlarmInfiniteAlarmTwo"])
        let content = UNMutableNotificationContent()
        content.title = "일어날 시간이에요!"
        content.body = "앱을 실행시켜 오늘의 날씨에 맞는 옷 카테고리를 확인하세요"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Morning-Kiss.mp3") )
        
        let triggerOne = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: true)
        let triggerTwo = UNTimeIntervalNotificationTrigger.init(timeInterval: 67, repeats: true)
        let requestOne = UNNotificationRequest(identifier: "FashionAlarmInfiniteAlarmOne", content: content, trigger: triggerOne) // 리퀘스트 생성
        let requestTwo = UNNotificationRequest(identifier: "FashionAlarmInfiniteAlarmTwo", content: content, trigger: triggerTwo) // 리퀘스트 생성
        self.add(requestOne, withCompletionHandler: nil) // 리퀘스트를 UNUserNotificationCenter에 추가
        self.add(requestTwo, withCompletionHandler: nil) // 리퀘스트를 UNUserNotificationCenter에 추가
    }
}
