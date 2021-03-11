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
    var userBirth: String? = ""
    var dataView:Data = Data()
    
    
    let imagePickerController = UIImagePickerController()
    var imageURL: URL?
    
    // DateFormatter Class constant declaration
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
        // Do any additional setup after loading the view.
        // 이미지 둥글게 만들기
        babyImage.layer.cornerRadius = (babyImage.frame.size.width) / 2
        babyImage.layer.masksToBounds = true
        
        // profile border color
        babyImage.layer.borderWidth = 1.0
        babyImage.layer.borderColor = UIColor.lightGray.cgColor
        
        // imagePickerController
        imagePickerController.delegate = self
        babyImage.isUserInteractionEnabled = true
        let event = UITapGestureRecognizer(target: self,
                                           action: #selector(clickMethod))
        babyImage.addGestureRecognizer(event)
        
        
        // sqlite file open
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        userInformationSearch()
    }
    
    
    
    @IBAction func birthDayPicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        
        let date = NSDate()
        
        
        
        
        
        // Locale Settings "ko" korea standard
        formatter.locale = Locale(identifier: "ko")
        // formatter dateFormat property Settings
        formatter.dateFormat = "yyyy-MM-dd"
        
        
        selectDate = formatter.string(from: datePickerView.date)
        currentDate = formatter.string(from: date as Date)
        let startDate = formatter.date(from:selectDate)!
        let endDate = formatter.date(from:currentDate)!
        
        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        UserDefaults.standard.set(days , forKey: "days")
        
    }
    
    
    @IBAction func btnProfileRegister(_ sender: UIButton) {
        var stmt: OpaquePointer?
        var daily: NSData = NSData()
        
        
        if selectDate == ""{
            selectDate = userBirth!
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)      // <--- 한글 들어가기 위해 꼭 필요
        userName = tfUserName.text!.trimmingCharacters(in: .whitespacesAndNewlines.self)
        if userName.isEmpty == true {
            let resultAlert = UIAlertController(title: "Dodam 알림", message: "아기의 이름을 입력 해주세요!", preferredStyle: UIAlertController.Style.actionSheet)
            let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler:nil)
            resultAlert.addAction(okAction)
            self.present(resultAlert, animated: true, completion: nil)
        }
        
        let imageDaily = babyImage.image
        if imageDaily != nil {
            daily = imageDaily!.pngData()! as NSData
        }
        
        let queryString = "UPDATE dodamSetting SET userName = ?, userBirth = ?, userImage = ? where userNo = ?"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update : \(errmsg)")
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
        
        if sqlite3_bind_blob(stmt, 3, daily.bytes, Int32(daily.length), SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding userImage : \(errmsg)")
            return
        }
        if sqlite3_bind_int(stmt, 4, 1) != SQLITE_OK{
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
        
        let resultAlert = UIAlertController(title: "Dodam 알림", message: "아기의 프로필이 등록되었습니다!", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {ACTION in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        resultAlert.addAction(okAction)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "callDetailPage"), object: nil)
        present(resultAlert, animated: true, completion: nil)
    }
    
    
    
    // profile image click 메소드
    @objc func clickMethod() {
        print("tapped")
        let photoAlert = UIAlertController(title: "사진 가져오기", message: "Photo Library에서 사진을 가져 옵니다.", preferredStyle: UIAlertController.Style.actionSheet)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { [self]ACTION in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: false, completion: nil) // animated: true로 해서 차이점을 확인해 보세요!
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
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
    
    
    // 사용자 기본정보
    func userInformationSearch() {
        
        
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
        
        babyImage.image = UIImage(data: dataView)
        tfUserName.text = userName
        formatter.dateFormat = "yyyy-MM-dd"
        print("userBirth",userBirth!)
        if userBirth == ""{
            
        }else{
            let dateTime = formatter.date(from: userBirth!)!
            self.datePicker.setDate(dateTime, animated: true)
        }
        
        
        
    }
}
