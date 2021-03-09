//
//  ProfileViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import SQLite3

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
  
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var babyImage: UIImageView!
    
    var selectDate = ""
    var currentDate = ""
    var db: OpaquePointer?  // <----- db는 OpaquePointer 타입을 쓴다.
    var userName = ""
    
    let imagePickerController = UIImagePickerController()
    var imageURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
        // Do any additional setup after loading the view.
        // 이미지 둥글게 만들기
        babyImage.layer.cornerRadius = (babyImage.frame.size.width) / 2
        babyImage.layer.masksToBounds = true
        // imagePickerController
        imagePickerController.delegate = self
        babyImage.isUserInteractionEnabled = true
            let event = UITapGestureRecognizer(target: self,
                                               action: #selector(clickMethod))
        babyImage.addGestureRecognizer(event)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func birthDayPicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        
        let date = NSDate()
        
        // DateFormatter Class constant declaration
        let formatter = DateFormatter()

        
        // Locale Settings "ko" korea standard
        formatter.locale = Locale(identifier: "ko")
        // formatter dateFormat property Settings
        formatter.dateFormat = "yyyy-MM-dd"
        
        
        selectDate = formatter.string(from: datePickerView.date)
        currentDate = formatter.string(from: date as Date)
        let startDate = formatter.date(from:selectDate)!
        let endDate = formatter.date(from:currentDate)!
        print("selectDate",selectDate)
        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        UserDefaults.standard.set(days , forKey: "days")
        
    }
    

    @IBAction func btnProfileRegister(_ sender: UIButton) {
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)      // <--- 한글 들어가기 위해 꼭 필요
        userName = tfUserName.text!
        
        let queryString = "UPDATE dodamSetting SET userName = ?, userBirth = ?, userImage = ? where userNo = ?"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert : \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 1, userName, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding userName : \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 2, selectDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding userBirth : \(errmsg)")
            return
        }
//
//        if sqlite3_bind_blob(stmt, 3, , -1, SQLITE_TRANSIENT) != SQLITE_OK {
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error binding userImage : \(errmsg)")
//            return
//        }
        
        if sqlite3_bind_text(stmt, 4, "1", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding userNo : \(errmsg)")
            return
        }
        
        // sqlite 실행
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting : \(errmsg)")
            return
        }
    }
    
    
    
    // profile image click 메소드
    @objc func clickMethod() {
        print("tapped")
        let photoAlert = UIAlertController(title: "사진 가져오기", message: "Photo Library에서 사진을 가져 옵니다.", preferredStyle: UIAlertController.Style.actionSheet)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { [self]ACTION in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: false, completion: nil) // animated: true로 해서 차이점을 확인해 보세요!
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        photoAlert.addAction(okAction)
        photoAlert.addAction(cancelAction)
        
        present(photoAlert, animated: true, completion: nil)
    }
    
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { // 원본 이미지가 있을 경우
       
            babyImage.image = image
            imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}
