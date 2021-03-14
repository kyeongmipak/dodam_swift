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
    
    var count:[Double] = []
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
    var startYear = 0
    var realMonth = ""
    var selectYear = ""
    var selectMonth = ""
    var selectedYear = ""
    var selectedMonth = ""
    var selectDate = ""
    var month = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting initial value of Sqlite
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        // If there is a problem opening database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
        }
        
        // If there is an existing table, ignore it, create it if it does not exist
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS dodamDiary (diaryNumber INTEGER PRIMARY KEY AUTOINCREMENT, diaryTitle TEXT, diaryContent TEXT, diaryImage BLOB, diaryDate TEXT)", nil, nil, nil) != SQLITE_OK{
            _ = String(cString: sqlite3_errmsg(db)!)
        }
        if sqlite3_exec(db,  "CREATE TABLE IF NOT EXISTS dodamSetting (userNo INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT, userBirth TEXT, userImage BLOB, settingTheme TEXT, settingFont Text, settingPassword INTEGER)", nil, nil, nil) != SQLITE_OK{
            _ = String(cString: sqlite3_errmsg(db)!)
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
        print("\(formatter.string(from: date as Date))월")
        
        // Setting initial value
        yearsPicker.selectRow(1, inComponent: 0, animated: true)
        monthPicker.selectRow((Int(realMonth)!-1), inComponent: 0, animated: true)
        
        readInitialSettingValues() // Excute function for initial value of sqlite
    }
    
    // for reload data
    override func viewWillAppear(_ animated: Bool) {
        // Setting initial value
        yearsPicker.selectRow(1, inComponent: 0, animated: true)
        monthPicker.selectRow((Int(realMonth)!-1), inComponent: 0, animated: true)
        readInitialSettingValues()
    }
    
    // Functions executed when the magnifying glass button is pressed
    @IBAction func selectDateAction(_ sender: UIButton) {
        // Truncate year and month string for sqlite
        let subyear = selectedYear.firstIndex(of: "년") ?? selectedYear.endIndex
        let year = String(selectedYear[..<subyear])
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
        let selectedDate = selectDate // Setting sqlite variable for question mark (selected by the user)
      
        // if -> 실패
        // switch -> 실패
        // 선택안한 피커뷰는?
        print("selectedDate >>>>>>> \(selectedDate)")
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
            selectedYear = years[row]
            selectedYear.remove(at: selectedYear.index(before: selectedYear.endIndex))
        case monthPicker :
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
    
}
