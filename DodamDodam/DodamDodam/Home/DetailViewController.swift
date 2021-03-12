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
    
    var viewNumber = ""
    var date = ""
    var viewTitle = ""
    var viewContent = ""
    var viewEmotion = ""
    
    var db: OpaquePointer?
    
    // Set SQLite for using Korean
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        diaryDate.text = date
        
        // Open SQLite file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite") // sqlite 파일명 기입(파일명은 내가 설정할 수 있다. 다만 확장자는 sqlite를 써준다.)
                
          if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
              print("error opening database")
          }
        
        // Execute SQL for watching a written diary
        sqlAction()
       
        diaryContent.isUserInteractionEnabled = false
    }
    
    // Excute modify when modify's button click
    @IBAction func modifyDiaryBtn(_ sender: UIButton) {
        let resultAlert = UIAlertController(title: "알림", message: "수정하시겠습니까?", preferredStyle: UIAlertController.Style.actionSheet)
          let cancelAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
          let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: {ACTION in
            // Move RegisterViewController
            let registerView = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
            registerView!.modalTransitionStyle = .coverVertical
            registerView!.receivedDate = self.diaryDate.text!
            registerView!.emtionImage = Int(self.viewEmotion)!
            registerView!.modifyCheck = 1
            self.navigationController?.pushViewController(registerView!, animated: true)

          })
          resultAlert.addAction(okAction)
          resultAlert.addAction(cancelAction)
          present(resultAlert, animated: true, completion: nil)
      
    }
    
    // Excute delete when delete's button click
    @IBAction func deleteDiaryBtn(_ sender: UIButton) {

        let resultAlert = UIAlertController(title: "확인", message: "삭제하시겠습니까", preferredStyle: UIAlertController.Style.actionSheet)
           let cancelAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
           let okAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {ACTION in
            // Excute delete Action when okAction click
            self.deleteAction()
            
            // Move HomeViewController when okAction click
            self.navigationController?.popToRootViewController(animated: true)
           })
           resultAlert.addAction(okAction)
           resultAlert.addAction(cancelAction)
           present(resultAlert, animated: true, completion: nil)

    }
    
    
    // Execute SQL for watching a written diary
    func sqlAction() {
        var dataDaily:Data = Data()
        
            let queryString = "SELECT diaryNumber, diaryTitle, diaryContent, diaryImage, diaryEmotion FROM dodamDiary WHERE diaryDate = ?"
            var stmt: OpaquePointer?
            
            // Set sqlite for select action
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // insert 하기 위한 셋팅
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            // Set data for question mark in queryString
            if sqlite3_bind_text(stmt, 1, date, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error binding name: \(errmsg)")
                return
            }
        
            // When selected data exists
            while sqlite3_step(stmt) == SQLITE_ROW{
                viewNumber = String(cString: sqlite3_column_text(stmt, 0))
                viewTitle = String(cString: sqlite3_column_text(stmt, 1))
                viewContent = String(cString: sqlite3_column_text(stmt, 2))
                
                if let dataBlob = sqlite3_column_blob(stmt, 3){
                    let viewCondition = Int(sqlite3_column_bytes(stmt, 3))
                    dataDaily = Data(bytes: dataBlob, count: viewCondition)
                }
                
                viewEmotion = String(cString: sqlite3_column_text(stmt, 4))

            }
            
        // Set detail view
//        // When diaryTitle exists
//        if viewTitle.isEmpty == true {
//            diaryTitle.text = "작성된 일기가 없습니다!"
//            diaryContent.text = ""
//            diaryContent.backgroundColor = .white
//            emotionImage.isHidden = true
//
//            //----------------------
//            // 3/10 수정
//            // btn 보여지는것
//            deleteButton.isHidden = true
//            modifyButton.isHidden = true
//            //----------------------
//
//        // When diaryTitle doesn't exist
//        } else {
            diaryTitle.text = viewTitle
            diaryContent.text = viewContent
            emotionImage.image = UIImage(named: Share.imageFileName[Int(viewEmotion)!])
            
            // When diaryImage exists
            if dataDaily.isEmpty == false {
                imageStack.isHidden = false
                dailyImage.image = UIImage(data: dataDaily)
                
            // When diaryImage doesn't exist
            } else {
                imageStack.isHidden = true

            }
//
//            //----------------------
//            // 3/10 수정
//            // btn 보여지는것
//            deleteButton.isHidden = false
//            modifyButton.isHidden = false
//            //----------------------

//        }

    }
    
    // Excute delete Action
    func deleteAction() {
        var stmt: OpaquePointer?
        
        let queryString = "DELETE FROM dodamDiary WHERE diaryNumber = ?"
        
        // Set sqlite for select action
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // Set data for question mark in queryString
        if sqlite3_bind_text(stmt, 1, viewNumber, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }
        
        // Excute SQL
        if sqlite3_step(stmt) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting: \(errmsg)")
            return
        }
        
    }
    
//    //----------------------
//    // 3/10 수정
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
////        if segue.identifier == "MovediaryModify"{
////           let modifyView = segue.destination as! RegisterViewController
//////            modifyView.receivedDate = diaryDate.text!
////
////        }
//
//    }
//    //----------------------

}
