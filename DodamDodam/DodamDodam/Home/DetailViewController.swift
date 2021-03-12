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
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var imageStack: UIStackView!
    
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
    
    // 수정 버튼 액션
    @IBAction func modifyDiaryBtn(_ sender: UIButton) {
        let resultAlert = UIAlertController(title: "알림", message: "수정하시겠습니까?", preferredStyle: UIAlertController.Style.actionSheet)
          let cancelAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
          let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: {ACTION in
              // 현재 화면 사라짐
//                  self.dismiss(animated: true)
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
        vcName!.modalTransitionStyle = .coverVertical
            vcName!.receivedDate = self.diaryDate.text!
            vcName!.emtionImage = Int(self.viewEmotion)!
            self.navigationController?.pushViewController(vcName!, animated: true)

          })
          resultAlert.addAction(okAction)
          resultAlert.addAction(cancelAction)
          present(resultAlert, animated: true, completion: nil)
        
    
        
    }
    
    @IBAction func deleteDiaryBtn(_ sender: UIButton) {

        let resultAlert = UIAlertController(title: "확인", message: "삭제하시겠습니까", preferredStyle: UIAlertController.Style.actionSheet)
           let cancelAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
           let okAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {ACTION in
               self.deleteAction()
               // 현재 화면 사라짐
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "callDetailPage"), object: nil)
            // 메인으로 돌아가기
            self.navigationController?.popToRootViewController(animated: true)
           })
           resultAlert.addAction(cancelAction)
           resultAlert.addAction(okAction)
           present(resultAlert, animated: true, completion: nil)

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
            emotionImage.isHidden = true

            //----------------------
            // 3/10 수정
            // btn 보여지는것
            deleteButton.isHidden = true
            modifyButton.isHidden = true
            //----------------------

            
        } else {
            diaryTitle.text = viewTitle
            diaryContent.text = viewContent
            emotionImage.image = UIImage(named: Share.imageFileName[Int(viewEmotion)!])
        
            if dataDaily.isEmpty == false {
                imageStack.isHidden = false
                dailyImage.image = UIImage(data: dataDaily)
        
            } else {
                imageStack.isHidden = true

            }
            
            //----------------------
            // 3/10 수정
            // btn 보여지는것
            deleteButton.isHidden = false
            modifyButton.isHidden = false
            //----------------------

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
    
    //----------------------
    // 3/10 수정
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "MovediaryModify"{
//           let modifyView = segue.destination as! RegisterViewController
////            modifyView.receivedDate = diaryDate.text!
//
//        }

    }
    //----------------------

}
