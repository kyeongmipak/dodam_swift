//
//  RegisterViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import SQLite3

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var dailyEmotion: UIImageView!
    @IBOutlet weak var dailyDate: UITextField!
    @IBOutlet weak var dailyTitle: UITextField!
    @IBOutlet weak var dailyImage: UIImageView!
    @IBOutlet weak var dailyContent: UITextView!

    var emtionImage = 0
    var registerDate = ""
    
    // 카메라, 앨범 실행
    //-------------------------
    let imagePickerController = UIImagePickerController()
    //-------------------------
    let datePicker = UIDatePicker()
    
    var db: OpaquePointer?
    var diaryDate = ""
    var date = ""
    var conditionImage:UIImage = UIImage()
    
    //-------------------------
    // 3/10
    var receivedDate = ""
    var viewNumber = ""
    var viewTitle = ""
    var viewContent = ""
    var viewEmotion = ""
    //-------------------------
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let date = NSDate()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko") // ko : 한국형 format
        formatter.dateFormat = "yyyy-MM-dd"
        if registerDate == "" {
            dailyDate.text = formatter.string(from: date as Date)
        } else {
            dailyDate.text = registerDate
        }
      
        dailyTitle.layer.borderWidth = 1.0
        dailyTitle.layer.borderColor = UIColor.lightGray.cgColor
        
        dailyEmotion.image = UIImage(named: Share.imageFileName[emtionImage])
        
        placeholderSetting()
        
        // 카메라, 앨범 실행
        //-------------------------
        imagePickerController.delegate = self
        //-------------------------

        createDatePicker()
        dailyDate.delegate = self
        
        // SQLite 생성하기
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite") // sqlite 파일명 기입(파일명은 내가 설정할 수 있다. 다만 확장자는 sqlite를 써준다.)

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // --------------------------
        // 3/10 추가 확인 필요
        // 이미지 클릭 이벤트
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        dailyEmotion.addGestureRecognizer(tapGR)
        dailyEmotion.isUserInteractionEnabled = true
        //-------------------------
        
        // --------------------------
        // 3/10 추가
        if receivedDate != "" {
            dailyDate.text = receivedDate
            print("받앗나?", receivedDate)
            dailyDate.isUserInteractionEnabled = false
            sqlAction(receivedDate: receivedDate)
            
        } else {
            createDatePicker()
            placeholderSetting()
            dailyDate.delegate = self
        }
        // --------------------------

        
    }
    
    //-------------------------
    // 3/10 수정 필요
    // 이미지 클릭 시 사진 선택 가능
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        
        guard let modalPresentView = self.storyboard?.instantiateViewController(identifier: "animated") as? SelectEmotionViewController else { return }
        self.present(modalPresentView, animated: true, completion: nil)
    }
    //-------------------------
    
    
    @IBAction func imageAddBtn(_ sender: UIButton) {
        let alert =  UIAlertController(title: "사진 선택", message: "골라주세요.", preferredStyle: .actionSheet)

        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()

        }

        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in

        self.openCamera()

        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func registerAction(_ sender: UIButton) {
        date = ""
        checkDate(dateCheck: dailyDate.text!)
        print("date : ", date)
        
        if date == "" || date == "null" {
            
            if nilCheck() == 0 {
                let resultAlert = UIAlertController(title: "알림", message: "제목 또는 내용을 입력해주세요.", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: nil)
                
                resultAlert.addAction(okAction)
                present(resultAlert, animated: true, completion: nil)
            } else {
                var daily: NSData = NSData()
                var stmt: OpaquePointer?  // db의 statement
                // 꼭 넣어줘야한다.: unsafeBitCast
                let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)  // <---- 한글 사용을 위해 설정
                
                let title = dailyTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
                let content = dailyContent.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
                let date = dailyDate.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
                let imageDaily = dailyImage.image
                let imageCondition = String(emtionImage)
                if imageDaily != nil {
                    daily = imageDaily!.pngData()! as NSData
                }
                
                let queryString = "INSERT INTO dodamDiary (diaryTitle, diaryContent, diaryDate, diaryImage, diaryEmotion) VALUES (?,?,?,?,?)"
                
                if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // insert 하기 위한 셋팅
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
                if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK {  // 첫번째 statementm, 두번째 숫자입력란에 위치 적어준다.
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error binding name: \(errmsg)")
                    return
                }
                
                if sqlite3_bind_text(stmt, 2, content, -1, SQLITE_TRANSIENT) != SQLITE_OK { // 두번째 statement
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error binding dept: \(errmsg)")
                    return
                }
                
                if sqlite3_bind_text(stmt, 3, date, -1, SQLITE_TRANSIENT) != SQLITE_OK { // 세번째 statement
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error binding phone: \(errmsg)")
                    return
                }
                
                if sqlite3_bind_blob(stmt, 4, daily.bytes, Int32(daily.length), SQLITE_TRANSIENT) != SQLITE_OK { // 세번째 statement
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error binding phone: \(errmsg)")
                    return
                }
                
                if sqlite3_bind_text(stmt, 5, imageCondition, -1, SQLITE_TRANSIENT) != SQLITE_OK { // 세번째 statement
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error binding phone: \(errmsg)")
                    return
                }
                
                
                // 실행
                if sqlite3_step(stmt) != SQLITE_DONE{  // done : 끝났다, step : 쿼리 실행
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting: \(errmsg)")
                    return
                }
                let resultAlert = UIAlertController(title: "결과", message: "입력되었습니다.", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: {ACTION in

                    self.navigationController?.popToRootViewController(animated: true)
                })
                
                resultAlert.addAction(okAction)
                present(resultAlert, animated: true, completion: nil)
                print("Diary saved successfully")
            }
            

            
        } else {
            
            let resultAlert = UIAlertController(title: "알림", message: "\(date)에 등록된 일기가 있습니다. \n날짜를 다시 선택해주세요.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: nil)
            
            resultAlert.addAction(okAction)
            present(resultAlert, animated: true, completion: nil)
        }
    }

    
    func placeholderSetting() {
        dailyContent.delegate = self // txtvReview가 유저가 선언한 outlet
        dailyContent.text = "내용을 입력해주세요."
        dailyContent.textColor = UIColor.lightGray
            
        }
        
        
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if dailyContent.textColor == UIColor.lightGray {
            dailyContent.text = nil
            dailyContent.textColor = UIColor.black
        }
        
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if dailyContent.text.isEmpty {
            dailyContent.text = "내용을 입력해주세요."
            dailyContent.textColor = UIColor.lightGray
        }
    }

    
    //-------------------------
    func createDatePicker() {
        dailyDate.textAlignment = .center
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: true)
        // assign toolbar
        dailyDate.inputAccessoryView = toolbar
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko")
        // assign date picker to the text field
        dailyDate.inputView = datePicker
        
        // date picker mode
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        // formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        
        diaryDate = formatter.string(from: datePicker.date)
        
        dailyDate.text = "\(diaryDate)"
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
      }
    //-------------------------
    
    // 앨범 접근
    func openLibrary(){
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: false, completion: nil)

    }
    
    // 카메라 접근
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: false, completion: nil)

        }

        else{
            print("Camera not available")

        }
    }
    
    // 사진 찍은 후 가져오기
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dailyImage.isHidden = false
            dailyImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // 사진 촬영이나 선택을 취소했을 때 호출되는 델리게이트 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 현재의 뷰(이미지 피커) 제거
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // 등록된 일기 있는지 확인
    func checkDate(dateCheck: String) {
        let queryString = "SELECT diaryDate FROM dodamDiary WHERE diaryDate = ?"
        var stmt: OpaquePointer?
       
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        if sqlite3_bind_text(stmt, 1, dateCheck, -1, SQLITE_TRANSIENT) != SQLITE_OK {  // 첫번째 statementm, 두번째 숫자입력란에 위치 적어준다.
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }

        while sqlite3_step(stmt) == SQLITE_ROW{  // 읽어올 데이터가 있는지 확인
            date = String(cString: sqlite3_column_text(stmt, 0))

        }
    }
    
    // 빈칸 체크
    func nilCheck() -> Int {
        if dailyTitle.text == "" {
            return 0
            
        } else if dailyContent.text == "내용을 입력해주세요." {
            return 0
            
        } else {
            return 1
        }
    }
    
    // 수정
    func updateAction() {
        var stmt: OpaquePointer?  // db의 statement
        // 꼭 넣어줘야한다.: unsafeBitCast
        var dailyPicture: NSData = NSData()
        
        let dTitle = dailyTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
        let dContent = dailyContent.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
        let dImage = dailyImage.image
        if dImage != nil {
            dailyPicture = dImage!.pngData()! as NSData
        }
        
        let queryString = "UPDATE dodamDiary SET diaryTitle = ?, diaryContent = ?, diaryImage = ?, diaryEmotion = ? WHERE diaryDate = ?"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // insert 하기 위한 셋팅
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, dTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, dContent, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_blob(stmt, 3, dailyPicture.bytes, Int32(dailyPicture.length), SQLITE_TRANSIENT) != SQLITE_OK { // 세번째 statement
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding phone: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 4, viewEmotion, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 5, receivedDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
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
        print("Diary update successfully")
        
    }
    
    // 수정을 위한 data select action
    func sqlAction(receivedDate: String) {
        var dataDaily:Data = Data()
        
            let queryString = "SELECT diaryNumber, diaryTitle, diaryContent, diaryImage, diaryEmotion FROM dodamDiary WHERE diaryDate = ?"
        
            var stmt: OpaquePointer?
            
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert 요가?: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 1, receivedDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {  // 첫번째 statementm, 두번째 숫자입력란에 위치 적어준다.
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

            //----------------------
            // 3/10 수정
            dailyTitle.text = viewTitle
            dailyContent.text = viewContent
//            dailyImage.image = UIImage(data: dataDaily)
            dailyEmotion.image = UIImage(named: Share.imageFileName[Int(viewEmotion)!])
    
            if dataDaily.isEmpty {
                dailyImage.isHidden = true
                
            } else {
                dailyImage.isHidden = false
                dailyImage.image = UIImage(data: dataDaily)
            }

            //----------------------
  
    }
    
    // 아무곳이나 눌러 softkeyboard 지우기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
