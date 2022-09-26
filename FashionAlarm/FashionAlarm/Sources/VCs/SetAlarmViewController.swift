//
//  SetAlarmViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/14.
//

import UIKit
import AVFoundation
import UserNotifications

class SetAlarmViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var iterSwitch: UISwitch!
    @IBOutlet weak var offMusicBtn: UIButton!
    @IBOutlet weak var setLocationBtn: UIButton!
    
    // 데이트 피커 타이머 초기화가 1분이기 떄문에 60초로
    var duration = 60
//    var timerStatus: TimerStatus = .end // 타이머의 초기값
    var currentSeconds = 0 // 현재 카운트 다운되고 있는 시간을 초로 저장하는 프로퍼티
    var timer: DispatchSourceTimer? // 타이머
    var audioPlayer: AVAudioPlayer?
    var selectedTime: Date = Date()
    let calendar = Calendar.current
    var alert: Alert?
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timerLabel.alpha = 0
        self.progressView.alpha = 0
        self.datePicker.locale = Locale(identifier: "ko-KR")
        self.datePicker.date = Date()
        self.datePicker.addTarget(self, action: #selector(dateChange(datePikcer:)), for: UIControl.Event.valueChanged)
        self.offMusicBtn.isHidden = true
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.stopTimer()
    }
    
    // 시작, 재개 버튼 클릭 시
    @IBAction func tapStartButton(_ sender: UIButton) {
        // 타이머에 해당하는 시간을 초단위로 변환
        self.selectedTime = self.datePicker.date
        if ( Int(self.selectedTime.timeIntervalSinceNow - Date().timeIntervalSinceNow) <= 0 ){
            self.selectedTime = calendar.date(byAdding: .hour, value: 24, to: self.datePicker.date) ?? Date()
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 1
            self.progressView.alpha = 1
            self.datePicker.alpha = 0
        })
        self.startButton.isHidden = true
        self.cancelButton.isEnabled = true
        self.startTimer()
    }
    
    @IBAction func stopMusic(_ sender: Any) {
        self.offMusicBtn.isHidden = true
        audioPlayer?.volume = 0
        //        audioPlayer?.stop()
    }
}

extension SetAlarmViewController {
    
    @objc func dateChange(datePikcer: UIDatePicker){
        self.selectedTime = datePikcer.date
    }
    
    private func startTimer() { // 타이머 끝나고 노래 소리 커짐 o | 홈화면에서 커짐
        rightAfterTimerOn()
        // 타이머를 설정하고 시작
        if self.timer == nil {
            // 타이머 인스턴스 생성, queue: 어떤 thread queue에서 반복 동작해야하는지 -> ui 관련 작업은 main에서 하는 것이 일반적
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            // 어떤 주기로 타이머를 동작시킬 지, deadline: 언제부터 작업을 시작할건지, repeating: 몇초마다 반복될 것인지
            self.timer?.schedule(deadline: .now(), repeating: 1)
            // 타이머와 연동된 이벤트 handler 설정
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                // UI 부분 함수로 빼주기
                self.changeUIINTimer()
                if self.currentSeconds <= 0 {
                    // 시간 0초 되면 타이머 종료 -> 함수로 빼주기
                    self.doWhenTimerEnd()
                }
            })
            self.timer?.resume()
        }
    }
    
    private func changeUIINTimer() {
        self.currentSeconds = Int(self.selectedTime.timeIntervalSinceNow - Date().timeIntervalSinceNow)
        // timer label 관련
        let hour = self.currentSeconds / 3600
        let minutes = (self.currentSeconds % 3600) / 60
        let seconds = (self.currentSeconds % 3600) % 60
        self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
        
        // progress bar 관련
        self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
    }
    
    private func rightAfterTimerOn() {
        cancelButton.isHidden = false
        iterSwitch.isHidden = true
        setLocationBtn.isHidden = true
        
        playMusic()
        audioPlayer?.volume = 0
        Timer.scheduledTimer(withTimeInterval: self.selectedTime.timeIntervalSinceNow - Date().timeIntervalSinceNow, repeats: false) { (t) in
            self.audioPlayer?.volume = 100
        }
        // self.alert = Alert(date: self.datePicker.date, isOn: self.iterSwitch.isOn)
        // 타이머 시작 후 조작 UI 처리 함수로 빼주기
        // userNotificationCenter.addNotificationRequest(by: alert!) // 알림을 userNotificationCenter에 추가
    }
    
    private func doWhenTimerEnd(){
        // self.audioPlayer?.volume = 100
        // 알람소리 -> iphonedev.wiki로 확인 가능
        // self.playMusic()
        offMusicBtn.isHidden = false
        if(self.iterSwitch.isOn){
            Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { (t) in // 알람 중간에 껐을 때 노래는 없고 볼륨은 높힌다.
                self.audioPlayer?.volume = 100
            }
            self.selectedTime = self.calendar.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
            self.currentSeconds = Int(self.selectedTime.timeIntervalSinceNow)
        }
        else{
            self.stopTimer()
        }
        self.tabBarController?.selectedIndex = 1
    }
    
    private func playMusic() {
        guard let url = Bundle.main.url(forResource: "Morning Kiss", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print(error)
        }
    }
    
    private func stopTimer() {
//        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alert!.id])
        self.offMusicBtn.isHidden = true
        self.iterSwitch.isHidden = false
        self.cancelButton.isHidden = true
        self.startButton.isHidden = false
        self.setLocationBtn.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
        })
        self.startButton.isSelected = false
        audioPlayer?.stop()
        self.timer?.cancel()
        self.timer = nil
    }
    
}
