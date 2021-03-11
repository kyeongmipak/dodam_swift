//
//  HomeViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import FSCalendar
import SQLite3

class HomeViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelBirth: UILabel!
    
    // 데이트 포맷 선언
    let dateFormatter = DateFormatter()
    
    var db: OpaquePointer?  // <----- db는 OpaquePointer 타입을 쓴다.
    var registerDates: [Date] = []
    var dataView:Data = Data()
    var diaryDate = ""
    var selectedDate = ""
    
    var imageArray = [UIImage?]()  // file name이 아닌 image들이 array로 들어간다.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerDates.removeAll()
        
        // make a circle image
        imageViewUser.layer.cornerRadius = (imageViewUser.frame.size.width) / 2
        imageViewUser.layer.masksToBounds = true
        // profile border color
        imageViewUser.layer.borderWidth = 1.0
        imageViewUser.layer.borderColor = UIColor.lightGray.cgColor
        
        
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite") // sqlite 파일명 기입(파일명은 내가 설정할 수 있다. 다만 확장자는 sqlite를 써준다.)
                
          if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
              print("error opening database")
          }
        print(fileURL.path)
        
        // Make a SQLite Table for Diary
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS dodamDiary (diaryNumber INTEGER PRIMARY KEY AUTOINCREMENT, diaryTitle TEXT, diaryContent TEXT, diaryImage BLOB, diaryDate TEXT, diaryEmotion TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // Make a SQLite Table for Setting
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS dodamSetting (userNo INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT, userBirth TEXT, userImage BLOB, settingTheme TEXT, settingFont Text, settingPassword INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        // 지은 추가 +++++++
        readTheme()
        // +++++++++
        
        // field값을 사용할 때
        calendar.dataSource = self
        // new 개념으로 함수를 사용할 때
        calendar.delegate = self
        
        calendarSetting()
        
        // date format 설정
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        userInformationSearch()
        calendar.reloadData()
        
        
        notificationAllow()
    }
    
    
    // 지은 추가
    // 불러오기 ***********************************
    func readTheme() {
        
        let queryString = "SELECT * FROM dodamSetting"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_ROW {
            
            // 제일 처음 실행할 때 값 생성
            // TableViewController 의 tempInsert() 부분을 전체 복붙해옴
            var stmt: OpaquePointer?
            
            // 이게 있어야 한글을 입력해도 무관하다.
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self) // <-- 중요!!!!!
            let queryString = "INSERT INTO dodamSetting (settingTheme, userName, userBirth) VALUES (?, ?, ?)"
            
            // ? 있으니 prepare 해주기
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            // ? 첫번째 sname
            if sqlite3_bind_text(stmt, 1, "systemTeal", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding theme: \(errmsg)")
                return
            }
            
            // ? 첫번째 sname
            if sqlite3_bind_text(stmt, 2, "", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding theme: \(errmsg)")
                return
            }
            
            // ? 첫번째 sname
            if sqlite3_bind_text(stmt, 3, "", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding theme: \(errmsg)")
                return
            }
            // sqlite 실행
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting : \(errmsg)")
                return
            }
            
        }
        // bean 에 집어 넣어서 append 시키면 일이 끝남
        // (stmt)에 읽어올 데이터가 있는지 확인하는 과정
        while sqlite3_step(stmt) == SQLITE_ROW {
            // 제일 처음에 들어오는 값은 키값이므로 키값으로 넣는다.
            let id = sqlite3_column_int(stmt, 0)
            // 입력받을때 text 값으로 입력했으니 Bean 에 String 값으로 생성해뒀기에 Text를 String 값으로 변환한다.
            let theme = String(cString: sqlite3_column_text(stmt, 4))
            
            print(id, theme)
            
            if theme == "brown" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .brown
//                Share.customButton = "blue"
            }else if theme == "red" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .red
//                Share.customButton = "blue"
            }else if theme == "systemTeal" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .systemTeal
//                Share.customButton = "blue"
            }
            else if theme == "yellow" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .yellow
//                Share.customButton = "blue"
            }
            else if theme == "systemPink" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .systemPink
//                Share.customButton = "blue"
            }
            else if theme == "blue" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .blue
//                Share.customButton = "blue"
            }
            
            
        }
        
    }
    
    
    // 불러오기 ***********************************
    func selectTheme() {
        
        let queryString = "SELECT * FROM dodamSetting"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
        
        // bean 에 집어 넣어서 append 시키면 일이 끝남
        // (stmt)에 읽어올 데이터가 있는지 확인하는 과정
        while sqlite3_step(stmt) == SQLITE_ROW {
            // 제일 처음에 들어오는 값은 키값이므로 키값으로 넣는다.
            let id = sqlite3_column_int(stmt, 0)
            // 입력받을때 text 값으로 입력했으니 Bean 에 String 값으로 생성해뒀기에 Text를 String 값으로 변환한다.
            let theme = String(cString: sqlite3_column_text(stmt, 4))
            
            print(id, theme)
            
            
            if theme == "brown" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .brown
//                Share.customButton = "blue"
            }else if theme == "red" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .red
//                Share.customButton = "blue"
            }else if theme == "systemTeal" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .systemTeal
//                Share.customButton = "blue"
            }
            else if theme == "yellow" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .yellow
//                Share.customButton = "blue"
            }
            else if theme == "systemPink" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .systemPink
//                Share.customButton = "blue"
            }
            else if theme == "blue" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
//                UIButton.appearance().backgroundColor = .blue
//                Share.customButton = "blue"
            }
            
        }
        
    }
    
    // 지은 추가 ***********************************
    
    
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
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition:
    FSCalendarMonthPosition) {
        selectedDate = dateFormatter.string(from: date)
        
        guard let modalPresentView = self.storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        modalPresentView.date = dateFormatter.string(from: date)
//        self.present(modalPresentView, animated: true, completion: nil)
        
        // --------------------------
        // 3/10 추가
        let currentDate = NSDate()
        let interval = date.timeIntervalSince(currentDate as Date)

        if interval > 0 && registerDates.contains(date) != true {
            let resultAlert = UIAlertController(title: "알림", message: "작성된 다이어리가 없습니다.\n다이어리 작성하시겠습니까?", preferredStyle: UIAlertController.Style.actionSheet)
              let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
              let okAction = UIAlertAction(title: "작성하러가기", style: UIAlertAction.Style.default, handler: {ACTION in
                let vcName = self.storyboard?.instantiateViewController(withIdentifier: "SelectEmotionViewController") as? SelectEmotionViewController
                vcName!.modalTransitionStyle = .coverVertical
                vcName!.receivedDate = dateFormatter.string(from: date)
                print("여기는?", dateFormatter.string(from: date))
                    self.navigationController?.pushViewController(vcName!, animated: true)
              })
              resultAlert.addAction(okAction)
              resultAlert.addAction(cancelAction)
              present(resultAlert, animated: true, completion: nil)
          
        } else if interval <= 0 && registerDates.contains(date) != true {
            let resultAlert = UIAlertController(title: "알림", message: "작성된 다이어리가 없습니다.\n다이어리 작성하시겠습니까?", preferredStyle: UIAlertController.Style.actionSheet)
              let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
              let okAction = UIAlertAction(title: "작성하러가기", style: UIAlertAction.Style.default, handler: {ACTION in
                    let vcName = self.storyboard?.instantiateViewController(withIdentifier: "SelectEmotionViewController") as? SelectEmotionViewController
                vcName!.modalTransitionStyle = .coverVertical
                vcName!.receivedDate = dateFormatter.string(from: date)
                print("여기는?", dateFormatter.string(from: date))
                    self.navigationController?.pushViewController(vcName!, animated: true)
              })
              resultAlert.addAction(okAction)
              resultAlert.addAction(cancelAction)
              present(resultAlert, animated: true, completion: nil)
                
        } else {
            self.present(modalPresentView, animated: true, completion: nil)
            
        }
        // --------------------------
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
    
    // 3.9
    //---------------------------
    override func viewDidDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 지은 추가----------
        selectTheme()
        // --------------
        registerDates.removeAll()
        dateSelectAction()
        calendar.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPage(_:)), name: Notification.Name(rawValue: "callDetailPage"), object: nil)
    }
    @objc func reloadPage(_ notification: Notification) { // add stuff }
        dateSelectAction()
        userInformationSearch()
        calendar.reloadData()
        print("여기 오나?")
    }
    //---------------------------
    
    // 사용자 기본정보
    func userInformationSearch() {
        var userName = ""
        var userBirth = ""
        
        let queryString = "SELECT userName, userBirth, userImage FROM dodamSetting"
        var stmt: OpaquePointer?
       
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // select하기 위한 셋팅, insert와 동일 (error msg만 바뀐다)
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return
            }
            
            while sqlite3_step(stmt) == SQLITE_ROW{  // 읽어올 데이터가 있는지 확인
                userName = String(cString: sqlite3_column_text(stmt, 0))
                userBirth = String(cString: sqlite3_column_text(stmt, 1))  // db 타입은 text로 string으로 변환해야 배열에 쓸 수 있다.\
                if let userImage = sqlite3_column_blob(stmt, 2){
                    let view = Int(sqlite3_column_bytes(stmt, 2))
                    dataView = Data(bytes: userImage, count: view)
                }
            }
        
        // 3.7 kyeongmi 입력 부분
        // 프로필 데이터 값 존재에 따른 출력
        if userBirth.isEmpty == true {
            if userName.isEmpty == true {
                if dataView.isEmpty == true {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(named: "profile.png")
                    labelBirth.text = "태어나지 않았어요!"
                } else {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(data: dataView)
                    labelBirth.text = "태어나지 않았어요!"
                }
            } else {
                if dataView.isEmpty == true {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(named: "profile.png")
                    labelBirth.text = "태어나지 않았어요!"
                } else {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(data: dataView)
                    labelBirth.text = "태어나지 않았어요!"
                }
            }
        } else {
            let currentDate = NSDate()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko") // ko : 한국형 format
            formatter.dateFormat = "yyyy-MM-dd"

            let startDate = dateFormatter.date(from: userBirth)!

            let interval = currentDate.timeIntervalSince(startDate)
            let days = Int(interval / 86400)
            print("\(days)일만큼 차이납니다.")
            labelBirth.text = "+\(days)일째"
            
            if userName.isEmpty == true {
                if dataView.isEmpty == true {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(named: "profile.png")
                   
                } else {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(data: dataView)
                    
                }
            } else {
                if dataView.isEmpty == true {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(named: "profile.png")
                    
                } else {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(data: dataView)
                   
                }
            }
        }
    
    }
    
    // 날짜 선택 시
    func dateSelectAction(){
        registerDates = []
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
                
               diaryDate = String(cString: sqlite3_column_text(stmt, 4))
                
                if diaryDate.isEmpty == false {
                    let formatter = DateFormatter()
                     formatter.locale = Locale(identifier: "ko_KR")
                     formatter.dateFormat = "yyyy-MM-dd"
                           
                    registerDates.append(formatter.date(from: diaryDate)!) // describing을 쓰는 이유는 한글때문이다.
                    print("selectAction date : ", registerDates)
                }
            }
    }

    
    
    func notificationAllow(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: {didAllow,Error in
            if didAllow {
                UserDefaults.standard.set("doAllow", forKey: "TimeKeeper")
                print("Push: 권한 허용")
            } else {
                UserDefaults.standard.set("notAllow", forKey: "TimeKeeper")
                print("Push: 권한 거부")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgSelectEmotionMove" {
            let emotionView = segue.destination as! SelectEmotionViewController
            emotionView.receivedDate = selectedDate
        }
    }
    
    
}
