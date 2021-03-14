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
    
    let dateFormatter = DateFormatter()
    
    // Use OpaquePointer type for DB
    var db: OpaquePointer?
    var registerDates: [Date] = []
    var dataViewImage:Data = Data()
    var diaryDate = ""
    var selectedDate = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init registerDates
        registerDates.removeAll()
        
        // Make a circle image
        imageViewUser.layer.cornerRadius = (imageViewUser.frame.size.width) / 2
        imageViewUser.layer.masksToBounds = true
        
        // Set profile border color
        imageViewUser.layer.borderWidth = 1.0
        imageViewUser.layer.borderColor = UIColor.lightGray.cgColor
        
        
        // Open SQLite file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
          // If there is a problem opening database
          if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
          }
        
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
        
        // Set theme
        readTheme()
        
        // Connect Calendar
        calendar.dataSource = self
        calendar.delegate = self
        
        // Set Calendar Option
        calendarSetting()
        
        // Set date format
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Set userName, userImage, userBirth
        userInformationSearch()
        
        // Checking for push permission
        notificationAllow()
    }
    
    
    // theme select
    func readTheme() {
        
        let queryString = "SELECT * FROM dodamSetting"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_ROW {
            
            var stmt: OpaquePointer?
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let queryString = "INSERT INTO dodamSetting (settingTheme, userName, userBirth) VALUES (?, ?, ?)"
            
            // Set sqlite for insert action
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
            // Set settingTheme for question mark in queryString
            if sqlite3_bind_text(stmt, 1, "Green", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
            // Set userName for question mark in queryString
            if sqlite3_bind_text(stmt, 2, "", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
            // Set userBirth for question mark in queryString
            if sqlite3_bind_text(stmt, 3, "", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
            // Excute SQL
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
        }
        
        // When selected data exists
        while sqlite3_step(stmt) == SQLITE_ROW {
            let theme = String(cString: sqlite3_column_text(stmt, 4))
                    
            if theme == "Purple" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
            }else if theme == "Pink" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
            }else if theme == "Green" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
            }
            else if theme == "Yellow" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
            }
            else if theme == "Orange" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
            }
            else if theme == "Sky" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
            }
            
            
        }
        
    }
    
    
    // selectTheme
    func selectTheme() {
        var stmt: OpaquePointer?

        let queryString = "SELECT * FROM dodamSetting"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let theme = String(cString: sqlite3_column_text(stmt, 4))
            
            if theme == "Purple" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
            }else if theme == "Pink" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
            }else if theme == "Green" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
            }
            else if theme == "Yellow" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
            }
            else if theme == "Orange" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
            }
            else if theme == "Sky" {
                self.navigationController?.navigationBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                UITabBar.appearance().barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
                self.tabBarController?.tabBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
            }
            
        }
        
    }
    
    
    
    // Set calendar
    func calendarSetting() {
        // Set calendar's header
        calendar.headerHeight = 50
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 24)

        // Set calendar's weekday color
        calendar.appearance.titleDefaultColor = .black

        // Set calendar's weekend color
        calendar.appearance.titleWeekendColor = .red

        // Set calendar's month color
        calendar.appearance.headerTitleColor = .systemPink

        // Set calendar's day of the week color
        calendar.appearance.weekdayTextColor = .blue
        // Set calendar's day of the week font and size
        calendar.appearance.weekdayFont = UIFont(name: "Henderson BCG Sans", size: 30)
            
        // Set calendar's language
        calendar.locale = Locale(identifier: "ko_KR")
        
        // Set calendar's scrollEnabled
        calendar.scrollEnabled = true
        // Set calendar's scrollDirection
        calendar.scrollDirection = .vertical

    }
    
    // Callback method when calendar's date selected
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition:
    FSCalendarMonthPosition) {
        selectedDate = dateFormatter.string(from: date)

        let currentDate = NSDate()
        let interval = date.timeIntervalSince(currentDate as Date)

        // Move SelectEmotionViewController When it is later than the current date and there is not a written diary
        if interval > 0 && registerDates.contains(date) != true {
              let resultAlert = UIAlertController(title: "알림", message: "작성된 다이어리가 없습니다.\n다이어리 작성하시겠습니까?", preferredStyle: UIAlertController.Style.actionSheet)
              let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
              let okAction = UIAlertAction(title: "작성하러가기", style: UIAlertAction.Style.default, handler: {ACTION in
                let vcName = self.storyboard?.instantiateViewController(withIdentifier: "SelectEmotionViewController") as? SelectEmotionViewController
                vcName!.modalTransitionStyle = .coverVertical
                vcName!.receivedDate = self.dateFormatter.string(from: date)
                print("여기는?", self.dateFormatter.string(from: date))
                    self.navigationController?.pushViewController(vcName!, animated: true)
              })
              resultAlert.addAction(okAction)
              resultAlert.addAction(cancelAction)
              present(resultAlert, animated: true, completion: nil)
            
          // Move SelectEmotionViewController When it is earlier than the current date and there is not a written diary
        } else if interval <= 0 && registerDates.contains(date) != true {
            let resultAlert = UIAlertController(title: "알림", message: "작성된 다이어리가 없습니다.\n다이어리 작성하시겠습니까?", preferredStyle: UIAlertController.Style.actionSheet)
              let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
              let okAction = UIAlertAction(title: "작성하러가기", style: UIAlertAction.Style.default, handler: {ACTION in
                    let selectEmotionView = self.storyboard?.instantiateViewController(withIdentifier: "SelectEmotionViewController") as? SelectEmotionViewController
                selectEmotionView!.modalTransitionStyle = .coverVertical
                selectEmotionView!.receivedDate = self.dateFormatter.string(from: date)
                self.navigationController?.pushViewController(selectEmotionView!, animated: true)
              })
              resultAlert.addAction(okAction)
              resultAlert.addAction(cancelAction)
              present(resultAlert, animated: true, completion: nil)
            
        // Move DetailViewController When there is a written diary
        } else {
            let detailView = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
            detailView!.modalTransitionStyle = .coverVertical
            detailView!.date = dateFormatter.string(from: date)
            self.navigationController?.pushViewController(detailView!, animated: true)
            
        }
    }
    
    // Set event When diaryDate of Written diary exists
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.registerDates.contains(date){
            return 1
        }
        return 0
    }
    
    // Redo HomeViewController
    override func viewWillAppear(_ animated: Bool) {
        selectTheme()
        registerDates.removeAll()
        dateSelectAction()
        calendar.reloadData()

    }
    
    // Search user's information
    func userInformationSearch() {
        var userName = ""
        var userBirth = ""
        var stmt: OpaquePointer?

        let queryString = "SELECT userName, userBirth, userImage FROM dodamSetting"
        
            // Set sqlite for select action
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
            // When selected data exists
            while sqlite3_step(stmt) == SQLITE_ROW{
                userName = String(cString: sqlite3_column_text(stmt, 0))
                userBirth = String(cString: sqlite3_column_text(stmt, 1))
                if let userImage = sqlite3_column_blob(stmt, 2){
                    let view = Int(sqlite3_column_bytes(stmt, 2))
                    dataViewImage = Data(bytes: userImage, count: view)
                }
            }
        
        // When userBirth doesn't exist
        if userBirth.isEmpty == true {
            
            // When userName doesn't exist
            if userName.isEmpty == true {
                
                // When userImage doesn't exist
                if dataViewImage.isEmpty == true {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(named: "profile.png")
                    labelBirth.text = "태어나지 않았어요!"
                    
                // When userImage exists
                } else {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(data: dataViewImage)
                    labelBirth.text = "태어나지 않았어요!"
                }
                
            // When userName exists
            } else {
                
                // When userImage doesn't exist
                if dataViewImage.isEmpty == true {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(named: "profile.png")
                    labelBirth.text = "태어나지 않았어요!"
                    
                // When userImage exists
                } else {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(data: dataViewImage)
                    labelBirth.text = "태어나지 않았어요!"
                }
            }
            
        // When userBirth exists
        } else {
            let currentDate = NSDate()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko")
            formatter.dateFormat = "yyyy-MM-dd"

            let startDate = dateFormatter.date(from: userBirth)!

            let interval = currentDate.timeIntervalSince(startDate)
            let days = Int(interval / 86400)
            labelBirth.text = "+\(days)일째"
            
            // When userName doesn't exist
            if userName.isEmpty == true {
                // When userImage doesn't exist
                if dataViewImage.isEmpty == true {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(named: "profile.png")
                    
                // When userImage exists
                } else {
                    labelUserName.text = "도담 Baby 누구?"
                    imageViewUser.image = UIImage(data: dataViewImage)
                
                }
                
            // When userName exists
            } else {
                // When userImage doesn't exist
                if dataViewImage.isEmpty == true {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(named: "profile.png")
                    
                // When userImage exists
                } else {
                    labelUserName.text = "\(userName)"
                    imageViewUser.image = UIImage(data: dataViewImage)
                   
                }
            }
        }
    
    }
    
    // Search Calendar Date for event displaying
    func dateSelectAction(){
        var stmt: OpaquePointer?
        // Init registerDates of event
        registerDates = []
        let queryString = "SELECT diaryDate FROM dodamDiary"
        
            // Set sqlite for select action
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
        
            // When selected data exists
            while sqlite3_step(stmt) == SQLITE_ROW{
               diaryDate = String(cString: sqlite3_column_text(stmt, 0))
                
                // Add data When diaryDate exists
                if diaryDate.isEmpty == false {
                    let formatter = DateFormatter()
                     formatter.locale = Locale(identifier: "ko_KR")
                     formatter.dateFormat = "yyyy-MM-dd"
                    registerDates.append(formatter.date(from: diaryDate)!)
                }
            }
    }

    // Checking for push permission
    func notificationAllow(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: {didAllow,Error in
            if didAllow {
                UserDefaults.standard.set("doAllow", forKey: "TimeKeeper")
            } else {
                UserDefaults.standard.set("notAllow", forKey: "TimeKeeper")
            }
        })
    }
    
    // Transfer date to SelectEmotionViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgSelectEmotionMove" {
            let emotionView = segue.destination as! SelectEmotionViewController
            emotionView.receivedDate = selectedDate
        }
    }
    
}
