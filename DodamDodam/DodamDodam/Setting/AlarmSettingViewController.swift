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
        // Save passed argument
        let datePickerView = sender
        // DateFormatter 
        let formatter = DateFormatter()
        
        // Locale Settings "ko" korea
        formatter.locale = Locale(identifier: "ko")

        formatter.dateFormat = "HH:mm"
        
        selectTime = formatter.string(from: datePickerView.date)
        print(selectTime)

        alarmTime = selectTime.components(separatedBy: [":"])
        print("alarmTime",alarmTime)
        alarmHour = alarmTime[0]
        alarmMinute = alarmTime[1]
        print("alarmHour",alarmHour)
        print("alarmminute",alarmMinute)
    }
    
   
    
      
    @IBAction func alarmSetting(_ sender: UIButton) {
        triggerTimeIntervalNotifications()
        self.navigationController?.popViewController(animated: true)
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

       
        let category = UNNotificationCategory(
            identifier: "Dodam",
            actions: [destructiveAction],
            intentIdentifiers: [],
            options: .hiddenPreviewsShowSubtitle
            )
        
        center.setNotificationCategories([category])

        }

    // Notification Settings
    func getNotificationSettings(completionHandler: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            completionHandler(settings.authorizationStatus == .authorized)
        }
    
    }
    
    
    
    
}
