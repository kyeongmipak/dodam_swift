//
//  StatisticsViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import SQLite3
import Charts

class StatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var barChart: HorizontalBarChartView!
    @IBOutlet var yearsPicker: UIPickerView!
    @IBOutlet var monthsPicker: UIPickerView!
    
    // Total emotion count ranking imageview
    @IBOutlet var totalFirst: UIImageView!
    @IBOutlet var totalSecond: UIImageView!
    @IBOutlet var totalThird: UIImageView!
    @IBOutlet var totalFourth: UIImageView!
    @IBOutlet var totalFifth: UIImageView!
    @IBOutlet var totalSixth: UIImageView!
    @IBOutlet var totalSeventh: UIImageView!
    @IBOutlet var totalEighth: UIImageView!
    @IBOutlet var totalNinth: UIImageView!
    @IBOutlet var totalTenth: UIImageView!
    @IBOutlet var totalEleventh: UIImageView!
    @IBOutlet var totalTwelveth: UIImageView!
    var groupImageView:[UIImageView] = []
    
    // For picker
    let formatter = DateFormatter()
    let date = NSDate()
    var years : [String] = []
    var months : [String] = []
    var nowYear = 0
    var nowMonth = ""
    var selectedYear = ""
    var selectedMonth = ""
    // Variables to verify that Picker is selected
    var selectCheckYearsPicker = 0
    var selectCheckMonthsPicker = 0
    
    // For SQLite
    var db: OpaquePointer?
    var emotionCount : [Double] = []
    
    // For the bar chart
    var chartColor : [UIColor] = []
    var imageArray = Share.imageFileName
    
    // To sort the data
    var imageArraySorted : [String] = []
    var chartColorSorted : [UIColor] = []
    var sortedIndex: [Int] = []
    
    // Index to clear information with zero count
    var removeIndex: [Int] = []
    
    // Variable to add as many charts as deleted
    var addChartCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Batch UIimageviews into arrays
        groupImageView = [totalFirst, totalSecond, totalThird, totalFourth, totalFifth, totalSixth, totalSeventh, totalEighth, totalNinth, totalTenth, totalEleventh, totalTwelveth]
        
        // Save emotion color (use chart)
        chartColor = [UIColor.init(red: 244.0/255.0, green: 206.0/255.0, blue: 243.0/255.0, alpha: 1), UIColor.init(red: 175.0/255.0, green: 236.0/255.0, blue: 229.0/255.0, alpha: 1), UIColor.init(red: 255.0/255.0, green: 139.0/255.0, blue: 116.0/255.0, alpha: 1), UIColor.init(red: 255.0/255.0, green: 209.0/255.0, blue: 80.0/255.0, alpha: 1), UIColor.init(red: 255.0/255.0, green: 65.0/255.0, blue: 56.0/255.0, alpha: 1), UIColor.init(red: 255.0/255.0, green: 175.0/255.0, blue: 181.0/255.0, alpha: 1), UIColor.init(red: 106.0/255.0, green: 151.0/255.0, blue: 255.0/255.0, alpha: 1), UIColor.init(red: 255.0/255.0, green: 207.0/255.0, blue: 197.0/255.0, alpha: 1), UIColor.init(red: 255.0/255.0, green: 224.0/255.0, blue: 131.0/255.0, alpha: 1), UIColor.init(red: 188.0/255.0, green: 238.0/255.0, blue: 151.0/255.0, alpha: 1), UIColor.init(red: 172.0/255.0, green: 238.0/255.0, blue: 255.0/255.0, alpha: 1), UIColor.init(red: 0.0/255.0, green: 203.0/255.0, blue: 194.0/255.0, alpha: 1)]
        
        // SQLite setting
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
        }
        
        // years picker setting
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy"
        
        let startYear = Int(formatter.string(from: date as Date))! - 100
        nowYear = Int(formatter.string(from: date as Date))!
        
        for year in  startYear ..< nowYear+1 {
            years.append("\(year)년")
        }
        yearsPicker.selectRow(100, inComponent: 0, animated: true)
        
        // months picker setting
        for month in 1..<13 {
            if month < 10{
                months.append("0\(month)월")
            } else {
                months.append("\(month)월")
            }
            
        }
        
        formatter.dateFormat = "MM"
        nowMonth = formatter.string(from: date as Date)
        monthsPicker.selectRow((Int(nowMonth)!-1), inComponent: 0, animated: true)
        
        // Load data for today's year and month
        for index in 0 ..< imageArray.count {
            readValues(index: index, year: String(nowYear), month: String(nowMonth))
        }
        
        sortData()

        setChart(dataPoints: imageArraySorted, values: emotionCount)
        
    }
    
    
    @IBAction func searchButton(_ sender: UIButton) {
        // Data Initialization
        emotionCount.removeAll()
        imageArraySorted.removeAll()
        chartColorSorted.removeAll()
        sortedIndex.removeAll()
        removeIndex.removeAll()
        addChartCount = 0
        for index in 0 ..< groupImageView.count {
            groupImageView[index].image = UIImage.init()
        }
        
        
        // Divide the number of cases depending on whether the picker is selected
        switch selectCheckYearsPicker {
        case 0:
            switch selectCheckMonthsPicker {
            case 0:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: String(nowYear), month: nowMonth)
                }
            case 1:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: String(nowYear), month: selectedMonth)
                }
            default:
                break
            }
        case 1:
            switch selectCheckMonthsPicker {
            case 0:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: selectedYear, month: nowMonth)
                }
            case 1:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: selectedYear, month: selectedMonth)
                }
            default:
                break
            }
        default:
            break
        }
        
        sortData()
        setChart(dataPoints: imageArraySorted, values: emotionCount)
    }
    
    
    /*
    // MARK: - PickerNavigation

    
    */
    
    // Setting for picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case yearsPicker:
            return years.count
        case monthsPicker :
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
        case monthsPicker :
            return months[row]
        default:
            break
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case yearsPicker:
            
            selectCheckYearsPicker = 1
            selectedYear = years[row]
            
            // Remove unnecessary content from picker
            selectedYear.remove(at: selectedYear.index(before: selectedYear.endIndex))
        case monthsPicker :
            
            selectCheckMonthsPicker = 1
            selectedMonth = months[row]
            
            // Remove unnecessary content from picker
            selectedMonth.remove(at: selectedMonth.index(before: selectedMonth.endIndex))
        default:
            break
        }
    }
    
    /*
    // MARK: - SQLiteNavigation

    
    */
    
    func readValues(index : Int, year : String, month : String) {
        let queryString = "SELECT count(*) FROM dodamDiary WHERE diaryEmotion = ? and diaryDate like '\(year)-\(month)%'"
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
        }
        if sqlite3_bind_text(stmt, 1, String(index), -1, SQLITE_TRANSIENT) != SQLITE_OK {
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let count = sqlite3_column_int(stmt, 0)
            if index == 0 {
                emotionCount.append(Double(count))
            } else if index == 1 {
                emotionCount.append(Double(count))
            } else if index == 2 {
                emotionCount.append(Double(count))
            } else if index == 3 {
                emotionCount.append(Double(count))
            } else if index == 4 {
                emotionCount.append(Double(count))
            } else if index == 5 {
                emotionCount.append(Double(count))
            } else if index == 6 {
                emotionCount.append(Double(count))
            } else if index == 7 {
                emotionCount.append(Double(count))
            } else if index == 8 {
                emotionCount.append(Double(count))
            } else if index == 9 {
                emotionCount.append(Double(count))
            } else if index == 10 {
                emotionCount.append(Double(count))
            } else if index == 11 {
                emotionCount.append(Double(count))
            }
        }
    }
    
    /*
    // MARK: - Sort Data Navigation

    
    */
    
    func sortData() {
        
        // sortedInex Initialization
        for index in 0 ..< emotionCount.count {
            sortedIndex.append(index)
        }
        
        // Sort emotion counts
        for _ in 0 ..< emotionCount.count - 1 {
            for j in 0 ..< emotionCount.count - 1 {
                if (emotionCount[j] > emotionCount[j+1]){
                    let temp = emotionCount[j]
                    emotionCount[j] = emotionCount[j+1]
                    emotionCount[j+1] = temp
                    let tempIndex = sortedIndex[j]
                    sortedIndex[j] = sortedIndex[j+1]
                    sortedIndex[j+1] = tempIndex
                }
            }
        }
        
        // Sort data by sorted index
        for index in sortedIndex {
            imageArraySorted.append(imageArray[index])
            chartColorSorted.append(chartColor[index])
        }

        // Store index and number of data equal to zero
        for i in 0 ..< emotionCount.count {
            if Int(emotionCount[i]) == 0 {
                addChartCount = addChartCount + 1
                removeIndex.append(i)
            }
        }
        
        // Erases arrays of zero data from large numbers.
        for index in 0 ..< removeIndex.count {
            imageArraySorted.remove(at: removeIndex[removeIndex.count - index - 1])
            emotionCount.remove(at: removeIndex[removeIndex.count - index - 1])
            chartColorSorted.remove(at: removeIndex[removeIndex.count - index - 1])
        }
        
    }
    
    /*
    // MARK: - Bar Chart Navigation

    
    */
    
    func setChart (dataPoints : [String], values : [Double]){
        
        // Shows images sorted in order with the most statistics
        for index in 0 ..< imageArraySorted.count {
            groupImageView[imageArraySorted.count - index - 1].image = UIImage(named: imageArraySorted[index])
        }
        
        // To set bar chart
        var dataEntries: [BarChartDataEntry] = []
        for i in 0 ..< dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i+addChartCount)*2, y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = chartColorSorted
        let format = NumberFormatter()
        format.generatesDecimalNumbers = false
        let formatter = DefaultValueFormatter(formatter: format)
        chartDataSet.valueFormatter = formatter
        chartDataSet.highlightEnabled = false
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 30)
        
        barChart.xAxis.axisMinimum = -0.6
        barChart.xAxis.axisMaximum = 12 * 2 - 1.5
        barChart.legend.enabled = false
        barChart.doubleTapToZoomEnabled = false
        barChart.xAxis.setLabelCount(dataPoints.count, force: false)
        barChart.rightAxis.enabled = false
        barChart.leftAxis.enabled = false
        barChart.xAxis.enabled = false
        barChart.leftAxis.axisMinimum = 0
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
    }
    
    /*
    // MARK: - Theme Navigation

    
    */
    
    // select Theme
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
    
    /*
    // MARK: - viewWillAppear Navigation

    
    */
    
    override func viewWillAppear(_ animated: Bool) {
        selectTheme()
        
        // Data Initialization
        emotionCount.removeAll()
        imageArraySorted.removeAll()
        chartColorSorted.removeAll()
        sortedIndex.removeAll()
        removeIndex.removeAll()
        addChartCount = 0
        for index in 0 ..< groupImageView.count {
            groupImageView[index].image = UIImage.init()
        }
        
        
        // Divide the number of cases depending on whether the picker is selected
        switch selectCheckYearsPicker {
        case 0:
            switch selectCheckMonthsPicker {
            case 0:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: String(nowYear), month: nowMonth)
                }
            case 1:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: String(nowYear), month: selectedMonth)
                }
            default:
                break
            }
        case 1:
            switch selectCheckMonthsPicker {
            case 0:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: selectedYear, month: nowMonth)
                }
            case 1:
                for index in 0 ..< imageArray.count {
                    readValues(index: index, year: selectedYear, month: selectedMonth)
                }
            default:
                break
            }
        default:
            break
        }
        
        sortData()
        setChart(dataPoints: imageArraySorted, values: emotionCount)
    }
}
