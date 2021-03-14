//
//  MonthlyListViewController.swift
//  DodamDodam
//
//  Created by Ria Song on 2021/03/13.
//

import UIKit
import SQLite3

class MonthlyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var MonthlyTableList: UITableView!
    @IBOutlet var yearsPicker: UIPickerView!
    @IBOutlet var monthPicker: UIPickerView!
    
    // Use OpaquePointer type for DB
    var db: OpaquePointer?
    // set instance variable of Diary
    var diaryList: [Diary] = []
    // Setting Global variable
    let PICKER_VIEW_COLUMN = 1
    let formatter = DateFormatter()
    let date = NSDate()
    var years : [String] = []
    var months : [String] = []
    var selectCheckYearsPicker = 0
    var selectCheckMonthsPicker = 0
    var startYear = 0
    var selectedDate = ""
    var realMonth = ""
    var selectYear = ""
    var selectMonth = ""
    var selectedYear = ""
    var selectedMonth = ""
    var selectDate = ""
    var year = ""
    var month = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting initial value of Sqlite
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        // If there is a problem opening database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
        }
        
        // Setting initial value of year picker
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy"
        startYear = Int(formatter.string(from: date as Date))! - 1
        let endYear = Int(formatter.string(from: date as Date))! + 30
        for year in  startYear ..< endYear {
            years.append("\(year)년")
        }
        
        // Setting initial value of month picker
        for month in 1..<13 {
            months.append("\(month)월")
        }
        formatter.dateFormat = "MM"
        realMonth = formatter.string(from: date as Date)
        
        // Setting initial value
        yearsPicker.selectRow(1, inComponent: 0, animated: true)
        monthPicker.selectRow((Int(realMonth)!-1), inComponent: 0, animated: true)
        
        readInitialSettingValues() // Excute function for initial value of sqlite
    }
    
    // selectTheme
    func selectTheme() {
        let queryString = "SELECT * FROM dodamSetting"
        var stmt: OpaquePointer?
        
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
    
    // for reload data
    override func viewWillAppear(_ animated: Bool) {
        selectTheme()
        
        // Setting reload value
        selectedDate = ""
        switch selectCheckYearsPicker {
        case 0: // The user not ran the YearPickerview
            switch selectCheckMonthsPicker {
            case 0: // The user did not run YearPickerview and MonthPickerview
                selectedDate = String(startYear + 1)+"-\(realMonth)"
            case 1: // The user not ran the YearPickerview, but ran the MonthPickerview
                selectedDate = String(startYear + 1)+"-\(month)"
            default:
                break
            }
        case 1:  // The user ran the YearPickerview
            switch selectCheckMonthsPicker {
            case 0: // The user ran the YearPickerview, but not ran the MonthPickerview
                selectedDate = "\(year)-\(realMonth)"
            case 1: // The user ran YearPickerview and MonthPickerview
                selectedDate = selectDate
            default:
                break
            }
        default:
            break
        }
        readMonthlyListValues()
    }
    
    // Functions executed when the magnifying glass button is pressed
    @IBAction func selectDateAction(_ sender: UIButton) {
        // Truncate year and month string for sqlite
        let subyear = selectedYear.firstIndex(of: "년") ?? selectedYear.endIndex
        year = String(selectedYear[..<subyear])
        let submonth = selectedMonth.firstIndex(of: "월") ?? selectedMonth.endIndex
        month = "0" + String(selectedMonth[..<submonth])
        
        selectDate = year + "-" + month // Set sqlite variable for user-selected data (question mark in query)
        readMonthlyListValues() // Excute function for Selected-Action value of sqlite
    }
    
    // MARK: - TableView Setting
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        MonthlyTableList.rowHeight = 125 // Setting cell size
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as? MonthlyListTableViewCell
        
        let diary: Diary
        diary = diaryList[indexPath.row] // Set data by checking the location of diaryList for each cell
        
        cell?.selectionStyle = MonthlyListTableViewCell.SelectionStyle.none
        cell?.lbl_DiaryTitle.text = diary.diaryTitle // Setting cell of label 'lbl_DiaryTitle'
        cell?.lbl_DiaryDate.text = diary.diaryDate // Setting cell of label 'lbl_DiaryDate'
        cell?.iv_emotion.image = UIImage(named: Share.imageFileName[Int(diary.diaryEmotion!)!]) // Setting cell of imageView 'iv_emotion'
        
        return cell!
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return PICKER_VIEW_COLUMN
    }
    
    // MARK: - function()
    // Search initially setted year-month diary list
    func readInitialSettingValues(){ 
        diaryList.removeAll() // Init diaryList
        
        // Setting sqlite variable for question mark (year-month)
        let selectedDate = String(startYear + 1)+"-\(realMonth)"
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self) // Encoding in Korean
        
        let queryString = "select diaryNumber, diaryTitle, diaryContent, diaryDate, diaryEmotion from dodamDiary where substr(diaryDate,1,7)=?"
        var stmt : OpaquePointer?
        
        // Set sqlite for select action
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set value for question mark in queryString (initially setted year-month)
        if sqlite3_bind_text(stmt, 1, selectedDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Execute sql, and get data if selected data exists.
        while sqlite3_step(stmt) == SQLITE_ROW{
            let diaryNumber = String(cString: sqlite3_column_text(stmt, 0))
            let diaryTitle = String(cString: sqlite3_column_text(stmt, 1))
            let diaryContent = String(cString: sqlite3_column_text(stmt, 2))
            let diaryDate = String(cString: sqlite3_column_text(stmt, 3))
            let diaryEmotion = String(cString: sqlite3_column_text(stmt, 4))
            
            // Stacking data fetched from sqlite into an array in a diaryList
            diaryList.append(Diary.init(diaryNumber: Int(diaryNumber)!, diaryTitle: diaryTitle, diaryContent: diaryContent, diaryDate: diaryDate, diaryEmotion: diaryEmotion))
        }
        self.MonthlyTableList.reloadData() // Reload data of Tableview
    }
    
    // Search the diarylist of year-month selected by the user
    func readMonthlyListValues(){
        diaryList.removeAll() // init diaryList
        selectedDate = ""
        
        switch selectCheckYearsPicker {
        case 0: // The user not ran the YearPickerview
            switch selectCheckMonthsPicker {
            case 0: // The user did not run YearPickerview and MonthPickerview
                selectedDate = String(startYear + 1)+"-\(realMonth)"
            case 1: // The user not ran the YearPickerview, but ran the MonthPickerview
                selectedDate = String(startYear + 1)+"-\(month)"
            default:
                break
            }
        case 1:  // The user ran the YearPickerview
            switch selectCheckMonthsPicker {
            case 0: // The user ran the YearPickerview, but not ran the MonthPickerview
                selectedDate = "\(year)-\(realMonth)"
            case 1: // The user ran YearPickerview and MonthPickerview
                selectedDate = selectDate
            default:
                break
            }
        default:
            break
        }
        
        var stmt : OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self) // Encoding in Korean
        let queryString = "select diaryNumber, diaryTitle, diaryContent, diaryDate, diaryEmotion from dodamDiary where substr(diaryDate,1,7)=?"
        
        // Set sqlite for select action
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set value for question mark in queryString (selected year-month)
        if sqlite3_bind_text(stmt, 1, selectedDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Execute sql, and get data if selected data exists.
        while sqlite3_step(stmt) == SQLITE_ROW{
            let diaryNumber = String(cString: sqlite3_column_text(stmt, 0))
            let diaryTitle = String(cString: sqlite3_column_text(stmt, 1))
            let diaryContent = String(cString: sqlite3_column_text(stmt, 2))
            let diaryDate = String(cString: sqlite3_column_text(stmt, 3))
            let diaryEmotion = String(cString: sqlite3_column_text(stmt, 4))
            
            // Stacking data fetched from sqlite into an array in a diaryList
            diaryList.append(Diary.init(diaryNumber: Int(diaryNumber)!, diaryTitle: diaryTitle, diaryContent: diaryContent, diaryDate: diaryDate, diaryEmotion: diaryEmotion))
        }
        self.MonthlyTableList.reloadData() // Reload data of Tableview
    }
    
    
    // MARK: - PickerView Sewtting
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case yearsPicker:
            return years.count
        case monthPicker :
            return months.count
        default:
            break
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case yearsPicker:
            return years[row]
        case monthPicker :
            return months[row]
        default:
            break
        }
        return ""
    }
    
    // Get year and month data value of pickerview
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case yearsPicker:
            selectCheckYearsPicker = 1
            selectedYear = years[row]
            selectedYear.remove(at: selectedYear.index(before: selectedYear.endIndex))
        case monthPicker :
            selectCheckMonthsPicker = 1
            selectedMonth = months[row]
            selectedMonth.remove(at: selectedMonth.index(before: selectedMonth.endIndex))
        default:
            break
        }
    }
    
    // MARK: - Navigation
    // Transfer selected diaryDate to DetailviewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgToDetailView"{
            let cell = sender as! UITableViewCell
            let indexPath = self.MonthlyTableList.indexPath(for: cell)
            let detailView = segue.destination as! DetailViewController
            detailView.selectedDate = diaryList[(indexPath?.row)!].diaryDate!
        }
    }
    
} // END
