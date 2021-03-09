//
//  AlarmSettingViewController.swift
//  DodamDodam
//
//  Created by  p2noo on 2021/03/08.
//

import UIKit
import UserNotifications

class AlarmSettingViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    
    var selectTime = ""
    var alarmTime: [String] = []
    var alarmHour = ""
    var alarmMinute = ""
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        setupNotificationActions()
        
        }
    
    

    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        // 전달된 인수 저장
        let datePickerView = sender
        // DateFormatter 클래스 상수 선언
        let formatter = DateFormatter()
        
        // Locale 설정 "ko" 한국 기준
        formatter.locale = Locale(identifier: "ko")
        // formatter의 dateFormat 속성을 설정
        // 년도 - 월 - 일 요일 (오전/오후) 시간 : 분 : 초
        formatter.dateFormat = "HH:mm"
        
        selectTime = formatter.string(from: datePickerView.date)
        print(selectTime)
//        UserDefaults.standard.set(selectTime, forKey: "TimeKeeper")
        alarmTime = selectTime.components(separatedBy: [":"])
        print("alarmTime",alarmTime)
        alarmHour = alarmTime[0]
        alarmMinute = alarmTime[1]
        print("alarmHour",alarmHour)
        print("alarmminute",alarmMinute)
    }
    
    
 
    
      
      
        
    
    
    
    @objc func tick() {
        selectTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    }
    
    
    func triggerTimeIntervalNotifications(){
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "Dodam"
        content.subtitle = "Dodam에서 아기의 하루를 기록하세요."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "Dodam"
        
        var date = DateComponents()
        date.hour = Int(alarmHour)
        date.minute = Int(alarmMinute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        

        let request = UNNotificationRequest(identifier: "notice", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
            }
        }
    }

    func setupNotificationActions(){
        let center = UNUserNotificationCenter.current()
        let destructiveAction = UNNotificationAction(identifier: "DESID", title: "확인", options: UNNotificationActionOptions(rawValue: 0))

        // ios 10 +
        let category = UNNotificationCategory(
            identifier: "Dodam",
            actions: [destructiveAction],
            intentIdentifiers: [],
            options: .hiddenPreviewsShowSubtitle
            )
        
        center.setNotificationCategories([category])

        }

    // Notification 에 대한 세팅
    func getNotificationSettings(completionHandler: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            completionHandler(settings.authorizationStatus == .authorized)
        }
    
    }
    
    
    
    
}
