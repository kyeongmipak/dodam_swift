//
//  ProfileViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit

class ProfileViewController: UIViewController {

    
    var selectDate = ""
    var currentDate = ""
    @IBOutlet weak var lblResultDay: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func birthDayPicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        
        
        let date = NSDate()
   
    
    
   
        
        // DateFormatter 클래스 상수 선언
        let formatter = DateFormatter()

        
        // Locale 설정 "ko" 한국 기준
        formatter.locale = Locale(identifier: "ko")
        // formatter의 dateFormat 속성을 설정
        // 년도 - 월 - 일 요일 (오전/오후) 시간 : 분 : 초
        formatter.dateFormat = "yyyy-MM-dd"
        
        
        selectDate = formatter.string(from: datePickerView.date)
        currentDate = formatter.string(from: date as Date)
        let startDate = formatter.date(from:selectDate)!
        let endDate = formatter.date(from:currentDate)!
        
        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        lblResultDay.text = "함께한지 \(days)일이에요."
    }
    

    
}
