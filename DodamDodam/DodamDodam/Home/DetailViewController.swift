//
//  DetailViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import SQLite3

class DetailViewController: UIViewController {

    @IBOutlet weak var diaryDate: UILabel!
    @IBOutlet weak var emotionImage: UIImageView!
    @IBOutlet weak var dailyImage: UIImageView!
    @IBOutlet weak var diaryTitle: UILabel!
    @IBOutlet weak var diaryContent: UITextView!
    
    
    var conditionImage:UIImage = UIImage()
    var viewNumber = ""
    var date = ""
    var viewTitle = ""
    var viewContent = ""
    var viewEmotion = ""
    
    var db: OpaquePointer?
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)  // <---- 한글 사용을 위해 설정
    
    override func viewDidLoad() {
        super.viewDidLoad()

        diaryDate.text = date
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite") // sqlite 파일명 기입(파일명은 내가 설정할 수 있다. 다만 확장자는 sqlite를 써준다.)
                
          if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
              print("error opening database")
          }
        
        sqlAction()
       
    }
    
    
    @IBAction func deleteDiaryBtn(_ sender: UIButton) {
        if nilCheck() == 0 {
            let resultAlert = UIAlertController(title: "알림", message: "작성된 일기가 없습니다.", preferredStyle: UIAlertController.Style.alert)
               let okAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: nil)
            resultAlert.addAction(okAction)
            present(resultAlert, animated: true, completion: nil)
            
        } else {
            let resultAlert = UIAlertController(title: "확인", message: "삭제하시겠습니까", preferredStyle: UIAlertController.Style.alert)
               let cancelAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
               let okAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {ACTION in
                   self.deleteAction()
                   // 현재 화면 사라짐
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                guard (self.storyboard? .instantiateViewController (withIdentifier: "HomeViewController") as? HomeViewController) != nil else {
                            fatalError ()
                        }
               
               })
               resultAlert.addAction(cancelAction)
               resultAlert.addAction(okAction)
               present(resultAlert, animated: true, completion: nil)
        }
    }
    
    // sqlite 실행
    func sqlAction() {
        var dataDaily:Data = Data()
        
            let queryString = "SELECT diaryNumber, diaryTitle, diaryContent, diaryImage, diaryEmotion FROM dodamDiary WHERE diaryDate = ?"
            var stmt: OpaquePointer?
            
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // insert 하기 위한 셋팅
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 1, date, -1, SQLITE_TRANSIENT) != SQLITE_OK {  // 첫번째 statementm, 두번째 숫자입력란에 위치 적어준다.
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding name: \(errmsg)")
                return
            }

            while sqlite3_step(stmt) == SQLITE_ROW{  // 읽어올 데이터가 있는지 확인
                viewNumber = String(cString: sqlite3_column_text(stmt, 0))
                viewTitle = String(cString: sqlite3_column_text(stmt, 1))  // db 타입은 text로 string으로 변환해야 배열에 쓸 수 있다.
                viewContent = String(cString: sqlite3_column_text(stmt, 2))
                
                if let dataBlob = sqlite3_column_blob(stmt, 3){
                    let viewCondition = Int(sqlite3_column_bytes(stmt, 3))
                    dataDaily = Data(bytes: dataBlob, count: viewCondition)
                }
                
                viewEmotion = String(cString: sqlite3_column_text(stmt, 4))

            }
            
            // view 화면 출력
            if viewTitle.isEmpty == true {
                diaryTitle.text = "작성된 일기가 없습니다!"
                diaryContent.text = ""
                diaryContent.backgroundColor = .white
                
            } else {
                diaryTitle.text = viewTitle
                diaryContent.text = viewContent
                emotionImage.image = UIImage(named: Share.imageFileName[Int(viewEmotion)!])
                if UIImage(data: dataDaily) != nil {
                    dailyImage.isHidden = false
                    dailyImage.image = UIImage(data: dataDaily)
                } else {
                    dailyImage.isHidden = true
                }
               
               
            }
        
    }
    
    // 삭제
    func deleteAction() {
        var stmt: OpaquePointer?  // db의 statement
        // 꼭 넣어줘야한다.: unsafeBitCast
        
        let queryString = "DELETE FROM dodamDiary WHERE diaryNumber = ?"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // insert 하기 위한 셋팅
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, viewNumber, -1, SQLITE_TRANSIENT) != SQLITE_OK {  // 첫번째 statementm, 두번째 숫자입력란에 위치 적어준다.
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }
        
        // 실행
        if sqlite3_step(stmt) != SQLITE_DONE{  // done : 끝났다, step : 쿼리 실행
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting: \(errmsg)")
            return
        }
        print("Diary delete successfully")
    }
    
    // check
    func nilCheck() -> Int {
        var count = 0
        let checkTitle = diaryTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if checkTitle == "작성된 일기가 없습니다!" || checkTitle == "" {
            count = 0
            
        } else {
            count = 1
        }
        return count
    }

}
