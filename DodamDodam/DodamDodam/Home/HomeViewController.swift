//
//  HomeViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import FSCalendar
import SQLite3

class HomeViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelBirth: UILabel!
    
    // 데이트 포맷 선언
    let dateFormatter = DateFormatter()
    
    var db: OpaquePointer?  // <----- db는 OpaquePointer 타입을 쓴다.
    var registerDates: [Date] = []
    var dataView:Data = Data()
    
    var imageArray = [UIImage?]()  // file name이 아닌 image들이 array로 들어간다.
    var imageFileName = ["w1.jpg","w2.jpg","w3.jpg","w4.jpg","w5.jpg","w6.jpg","w7.jpg","w8.jpg","w9.jpg","w10.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerDates.removeAll()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite") // sqlite 파일명 기입(파일명은 내가 설정할 수 있다. 다만 확장자는 sqlite를 써준다.)
                
          if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
              print("error opening database")
          }
        
        // Make a SQLite Table for Diary
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS dodamDiary (diaryNumber INTEGER PRIMARY KEY AUTOINCREMENT, diaryTitle TEXT, diaryContent TEXT, diaryImage BLOB, diaryDate TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // Make a SQLite Table for Setting
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS dodamSetting (userNo INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT, userBirth TEXT, userImage BLOB, settingTheme TEXT, settingFont Text, settingPassword INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        
        // field값을 사용할 때
        calendar.dataSource = self
        // new 개념으로 함수를 사용할 때
        calendar.delegate = self
        
        calendarSetting()
        
        // date format 설정
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        userInformationSearch()
    }
    
    // calendar setting
    func calendarSetting() {
        // header 설정 변경
        calendar.headerHeight = 50
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 24)

        // 달력의 평일 날짜 색깔
        calendar.appearance.titleDefaultColor = .black

        // 달력의 토,일 날짜 색깔
        calendar.appearance.titleWeekendColor = .red

        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .systemPink

        // 달력의 요일 글자 색깔
        calendar.appearance.weekdayTextColor = .blue
        calendar.appearance.weekdayFont = UIFont(name: "Henderson BCG Sans", size: 30)
            

        calendar.locale = Locale(identifier: "ko_KR")
        
        // 스와이프 스크롤 작동 여부 ( 활성화하면 좌측 우측 상단에 다음달 살짝 보임, 비활성화하면 사라짐 )
        calendar.scrollEnabled = true
        // 스와이프 스크롤 방향 ( 버티칼로 스와이프 설정하면 좌측 우측 상단 다음달 표시 없어짐, 호리젠탈은 보임 )
        calendar.scrollDirection = .vertical

    }
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        guard let modalPresentView = self.storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
//        modalPresentView.date = dateFormatter.string(from: date)
        self.present(modalPresentView, animated: true, completion: nil)
    }
    
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
    // 이벤트 수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.registerDates.contains(date){
            return 1
        }
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerDates.removeAll()
        dateSelectAction()
        calendar.reloadData()
    }
    
    // 사용자 기본정보
    func userInformationSearch() {

        let queryString = "SELECT userName, userBirth, userImage FROM dodamSetting"
        var stmt: OpaquePointer?
       
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // select하기 위한 셋팅, insert와 동일 (error msg만 바뀐다)
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return
            }
            
            while sqlite3_step(stmt) == SQLITE_ROW{  // 읽어올 데이터가 있는지 확인
                let userName = sqlite3_column_int(stmt, 0)
                let userBirth = String(cString: sqlite3_column_text(stmt, 1))  // db 타입은 text로 string으로 변환해야 배열에 쓸 수 있다.\
                if let userImage = sqlite3_column_blob(stmt, 2){
                    let view = Int(sqlite3_column_bytes(stmt, 2))
                    dataView = Data(bytes: userImage, count: view)
                }
                
                if userBirth.isEmpty == false {
                    let currentDate = NSDate()
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ko") // ko : 한국형 format
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    labelUserName.text = "\(userName)"
//                    imageViewUser.image = UIImage(named: "default.jpg")
                    
                    let startDate = dateFormatter.date(from: userBirth)!

                    let interval = currentDate.timeIntervalSince(startDate)
                    let days = Int(interval / 86400)
                    print("\(days)일만큼 차이납니다.")

                    
                    labelBirth.text = "+\(days)일째"
                    
                } else if dataView.isEmpty == false {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(data: dataView)
                    labelBirth.text = ""
                    
                } else {
                    labelUserName.text = "\(userName)"
//                    imageViewUser.image = UIImage(named: "default.jpg")
                    labelBirth.text = ""
                }
            }
    }
    
    // 날짜 선택 시
    func dateSelectAction(){

        let queryString = "SELECT * FROM dodamDiary"
        var stmt: OpaquePointer?
       
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // select하기 위한 셋팅, insert와 동일 (error msg만 바뀐다)
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return
            }
            
            while sqlite3_step(stmt) == SQLITE_ROW{  // 읽어올 데이터가 있는지 확인
//                let diaryNumber = sqlite3_column_int(stmt, 0)
//                let diaryTitle = String(cString: sqlite3_column_text(stmt, 1))  // db 타입은 text로 string으로 변환해야 배열에 쓸 수 있다.
//                let diaryContent = String(cString: sqlite3_column_text(stmt, 2))
                if let diaryImage = sqlite3_column_blob(stmt, 3){
                    let viewCondition = Int(sqlite3_column_bytes(stmt, 3))
                    dataView = Data(bytes: diaryImage, count: viewCondition)
                }
                
                let diaryDate = String(cString: sqlite3_column_text(stmt, 4))
                
                if diaryDate.isEmpty == false {
                    let formatter = DateFormatter()
                     formatter.locale = Locale(identifier: "ko_KR")
                     formatter.dateFormat = "yyyy-MM-dd"
                           
                    registerDates.append(formatter.date(from: diaryDate)!) // describing을 쓰는 이유는 한글때문이다.
                    print("selectAction date : ", registerDates)
                }
            }
    }

}
