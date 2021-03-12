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
    var selectCheckYearsPicker = 0
    var selectCheckMonthsPicker = 0
    
    // For SQLite
    var db: OpaquePointer?
    var emotionCount : [Double] = []
    
    // For the bar chart
    var chartColor = Share.emotionBaseColor
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
        
        groupImageView = [totalFirst, totalSecond, totalThird, totalFourth, totalFifth, totalSixth, totalSeventh, totalEighth, totalNinth, totalTenth, totalEleventh, totalTwelveth]
        
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
    
    // 선택한 값 받아올 수 있음
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case yearsPicker:
            selectCheckYearsPicker = 1
            selectedYear = years[row]
            selectedYear.remove(at: selectedYear.index(before: selectedYear.endIndex))
            
        case monthsPicker :
            selectCheckMonthsPicker = 1
            selectedMonth = months[row]
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
        
        while sqlite3_step(stmt) == SQLITE_ROW {        // 읽어올 데이터가 있는지
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
        for i in 0..<emotionCount.count{
            var minn = emotionCount[i]
            var location : Int = i;
            for j in i+1..<emotionCount.count{
                if(emotionCount[i]>emotionCount[j])
                {
                    minn = emotionCount[j];
                    location = j;
                }
            }

            if i != location{
                emotionCount.swapAt(i, location)
                sortedIndex.swapAt(i, location)
            }
        }
        
        //
        for index in sortedIndex {
            imageArraySorted.append(imageArray[index])
            chartColorSorted.append(chartColor[index])
        }

        //
        for i in 0 ..< emotionCount.count {
            if Int(emotionCount[i]) == 0 {
                addChartCount = addChartCount + 1
            }
        }
        
        //
        for _ in 0 ..< addChartCount {
            imageArraySorted.remove(at: 0)
            emotionCount.remove(at: 0)
            chartColorSorted.remove(at: 0)
        }
        
        for index in (0 ..< imageArraySorted.count).reversed() {
            groupImageView[imageArraySorted.count - index - 1].image = UIImage(named: imageArraySorted[index])
        }
        
    }
    
    /*
    // MARK: - Bar Chart Navigation

    
    */
    
    func setChart (dataPoints : [String], values : [Double]){
        var dataEntries: [BarChartDataEntry] = []

        for i in 0 ..< dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i+addChartCount)*2, y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = chartColorSorted
        
        
        // 더블은 인테저로 바꿔 줌
        let format = NumberFormatter()
        format.generatesDecimalNumbers = false
        let formatter = DefaultValueFormatter(formatter: format)
        chartDataSet.valueFormatter = formatter
        
        
        barChart.xAxis.axisMinimum = -0.6
        barChart.xAxis.axisMaximum = 12 * 2 - 1.5
        
        
        // 차트 컬러
//        chartDataSet.colors = [.systemBlue]

        // 선택 안되게
        chartDataSet.highlightEnabled = false
        barChart.legend.enabled = false
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 30)
        
        // 줌 안되게
        barChart.doubleTapToZoomEnabled = false
        
        // X축 레이블 위치 조정
//        barChart.xAxis.labelPosition = .bottomInside
        // X축 레이블 포맷 지정
//        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: emotion)
        
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        barChart.xAxis.setLabelCount(dataPoints.count, force: false)
        
        barChart.rightAxis.enabled = false
         barChart.leftAxis.enabled = false
        barChart.xAxis.enabled = false
        
        barChart.leftAxis.axisMinimum = 0
        
        
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
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
