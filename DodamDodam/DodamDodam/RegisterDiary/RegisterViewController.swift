//
//  RegisterViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import SQLite3

// Bring data from SelectEmotionViewController to RegisterViewController using the protocol
protocol DeliveryEmotionCheckProtocol: class {
    func deliveryEmotionCheckData(_ emotion: Int, _ modifyCheck: Int)
}

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, DeliveryEmotionCheckProtocol{
    
    @IBOutlet weak var dailyEmotion: UIImageView!
    @IBOutlet weak var dailyDate: UITextField!
    @IBOutlet weak var dailyTitle: UITextField!
    @IBOutlet weak var dailyContent: UITextView!
    @IBOutlet weak var dailyImage: UIImageView!
    @IBOutlet weak var dailyImageStackView: UIStackView!
    
    var emotionImage = 100
    var registerDate = ""
    var modifyCheck = 0
    var modifyEmotion = 0
    
    // Declaration UIImagePickerController for executing camera and album
    let imagePickerController = UIImagePickerController()
    let datePicker = UIDatePicker()
    
    var db: OpaquePointer?
    var diaryDate = ""
    var date = ""
    
    var receivedDate = ""
    var viewNumber = ""
    var viewTitle = ""
    var viewContent = ""
    var viewEmotion = ""
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Current date
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy-MM-dd"
        
        // If there is no date to pass, set current date
        if registerDate == "" {
            dailyDate.text = formatter.string(from: date as Date)
            
        // If there is date to pass, set date
        } else {
            dailyDate.text = registerDate
        }
      
        // Set title border and borderColor
        dailyTitle.layer.borderWidth = 1.0
        dailyTitle.layer.borderColor = UIColor.lightGray.cgColor
        
        // Set emotion image selected on the previous controller
        dailyEmotion.image = UIImage(named: Share.imageFileName[emotionImage])
        
        // Connect imagePickerController
        imagePickerController.delegate = self

        // Set datePicker
        createDatePicker()
        // Connect datePicker
        dailyDate.delegate = self
        
        // Open SQLite file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        // If there is a problem opening database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        }
        
        // When emotionImage tap
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        dailyEmotion.addGestureRecognizer(tapGR)
        dailyEmotion.isUserInteractionEnabled = true
        
        // If If there is a date for correction, set that day diary content
        if receivedDate != "" {
            dailyDate.text = receivedDate
            dailyDate.isUserInteractionEnabled = false
            sqlAction(receivedDate: receivedDate)
            
        // If If there is no date for correction, init
        } else {
            createDatePicker()
            placeholderSetting()
            dailyDate.delegate = self
        }
        
    }
    
    // Receive data to SelectEmotionViewController
    func receivedItem(selectedDate: String, selectedEmotion: Int) {
        registerDate = selectedDate
        emotionImage = selectedEmotion
    }
    
    // Receive data to SelectEmotionViewController when DeliveryDataProtocol excutes
    func deliveryEmotionCheckData(_ emotion: Int, _ modifyCheck: Int) {
        if modifyCheck == 2 && emotion != emotionImage{
            emotionImage = emotion
            dailyEmotion.image = UIImage(named: Share.imageFileName[emotion])
        }
    }
    
    // Move SelectEmotionViewController when emotionImage tapped
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        
        guard let selectEmotionView = self.storyboard?.instantiateViewController(withIdentifier: "SelectEmotionViewController") as? SelectEmotionViewController else { return }
        selectEmotionView.delegate = self
        selectEmotionView.modifyCheck = 1
        
        self.present(selectEmotionView, animated: true, completion: nil)
    }
    
    // Excute add image when imageAddBtn click
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
    
    
    // Click Done button
    @IBAction func registerAction(_ sender: UIButton) {
        // When diary register action
        if receivedDate == "" {
            date = ""
            checkDate(dateCheck: dailyDate.text!)
            
            if date == "" || date == "null" {
                if nilCheck() == 0 {
                    let resultAlert = UIAlertController(title: "알림", message: "제목 또는 내용을 입력해주세요.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: nil)
                    
                    resultAlert.addAction(okAction)
                    present(resultAlert, animated: true, completion: nil)
                } else {
                    var daily: NSData = NSData()
                    var stmt: OpaquePointer?
                    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                    
                    let title = dailyTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
                    let content = dailyContent.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
                    let date = dailyDate.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
                    let imageDaily = dailyImage.image
                    let imageCondition = String(emotionImage)
                    if imageDaily != nil {
                        daily = imageDaily!.pngData()! as NSData
                    }
                    
                    let queryString = "INSERT INTO dodamDiary (diaryTitle, diaryContent, diaryDate, diaryImage, diaryEmotion) VALUES (?,?,?,?,?)"
                    
                    // Set sqlite for insert action
                    if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                        _ = String(cString: sqlite3_errmsg(db)!)
                        return
                    }
                    
                    // Set settingTheme for question mark in queryString
                    if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                        _ = String(cString: sqlite3_errmsg(db)!)
                        return
                    }
                    
                    // Set settingTheme for question mark in queryString
                    if sqlite3_bind_text(stmt, 2, content, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                        _ = String(cString: sqlite3_errmsg(db)!)
                        return
                    }
                    
                    // Set settingTheme for question mark in queryString
                    if sqlite3_bind_text(stmt, 3, date, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                        _ = String(cString: sqlite3_errmsg(db)!)
                        return
                    }
                    
                    // Set settingTheme for question mark in queryString
                    if sqlite3_bind_blob(stmt, 4, daily.bytes, Int32(daily.length), SQLITE_TRANSIENT) != SQLITE_OK {
                        _ = String(cString: sqlite3_errmsg(db)!)
                        return
                    }
                    
                    // Set settingTheme for question mark in queryString
                    if sqlite3_bind_text(stmt, 5, imageCondition, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                        _ = String(cString: sqlite3_errmsg(db)!)
                        return
                    }
                    
                    
                    if sqlite3_step(stmt) != SQLITE_DONE{
                        _ = String(cString: sqlite3_errmsg(db)!)
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
            
        // When diary modify action
        } else {
            if nilCheck() == 1 {
                  let resultAlert = UIAlertController(title: "결과", message: "수정되었습니다.", preferredStyle: UIAlertController.Style.alert)
                  let cancelAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
                  let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: {ACTION in
                      self.updateAction()
                      
                    self.navigationController?.popToRootViewController(animated: true)
                    
                  })
                  resultAlert.addAction(cancelAction)
                  resultAlert.addAction(okAction)
                  present(resultAlert, animated: true, completion: nil)
            } else {
                let resultAlert = UIAlertController(title: "알림", message: "제목 또는 내용을 입력해주세요.", preferredStyle: UIAlertController.Style.actionSheet)
                let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: nil)
                
                resultAlert.addAction(okAction)
                present(resultAlert, animated: true, completion: nil)
            }
        }
    }

    // TextView Place Holder
    func placeholderSetting() {
        dailyContent.delegate = self
        dailyContent.text = "내용을 입력해주세요."
        dailyContent.textColor = UIColor.lightGray
            
        }
        
    // TextView Place Holder when beginEditing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if dailyContent.textColor == UIColor.lightGray {
            dailyContent.text = nil
            dailyContent.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder when endEditing
    func textViewDidEndEditing(_ textView: UITextView) {
        if dailyContent.text.isEmpty {
            dailyContent.text = "내용을 입력해주세요."
            dailyContent.textColor = UIColor.lightGray
        }
    }

    // Set datePicker
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
    
    // done action when datePicker's doneButton click
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
    
    // cancel action when datePicker's cancelButton click
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
        
      }
    
    // Access album
    func openLibrary(){
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: false, completion: nil)

    }
    
    // Access camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: false, completion: nil)

        }
    }
    
    // Bring image to album
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dailyImageStackView.isHidden = false
            dailyImage.image = fixOrientation(image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Cancel imagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // remove present view
        self.dismiss(animated: true, completion: nil)
    }
    
    // Set image for image's direction
    func fixOrientation(_ img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img

        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)

        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage

    }
    
    
    // Check if there is a written diary
    func checkDate(dateCheck: String) {
        var stmt: OpaquePointer?

        let queryString = "SELECT diaryDate FROM dodamDiary WHERE diaryDate = ?"
        
        // Set sqlite for select action
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set date for question mark in queryString
        if sqlite3_bind_text(stmt, 1, dateCheck, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Excute SQL
        while sqlite3_step(stmt) == SQLITE_ROW{
            date = String(cString: sqlite3_column_text(stmt, 0))

        }
    }
    
    // Check blank
    func nilCheck() -> Int {
        if dailyTitle.text == "" {
            return 0
            
        } else if dailyContent.text == "내용을 입력해주세요." || dailyContent.text == ""{
            return 0
            
        } else {
            return 1
        }
    }
    
    // Modify diary
    func updateAction() {
        var stmt: OpaquePointer?
        var dailyPicture: NSData = NSData()
        
        let diaryTitle = dailyTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
        let diaryContent = dailyContent.text?.trimmingCharacters(in: .whitespacesAndNewlines.self)
        let diaryImage = dailyImage.image
        if diaryImage != nil {
            dailyPicture = diaryImage!.pngData()! as NSData
        }
        
        let queryString = "UPDATE dodamDiary SET diaryTitle = ?, diaryContent = ?, diaryImage = ?, diaryEmotion = ? WHERE diaryDate = ?"
        
        // Set sqlite for update action
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set diary title for question mark in queryStrin
        if sqlite3_bind_text(stmt, 1, diaryTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set diary content for question mark in queryStrin
        if sqlite3_bind_text(stmt, 2, diaryContent, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set diary image for question mark in queryStrin
        if sqlite3_bind_blob(stmt, 3, dailyPicture.bytes, Int32(dailyPicture.length), SQLITE_TRANSIENT) != SQLITE_OK { // 세번째 statement
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set diary emotion for question mark in queryStrin
        if sqlite3_bind_text(stmt, 4, String(emotionImage), -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Set diary date for question mark in queryStrin
        if sqlite3_bind_text(stmt, 5, receivedDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        // Excute SQL
        if sqlite3_step(stmt) != SQLITE_DONE{ 
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
    }
    
    // Search a diary for selected date
    func sqlAction(receivedDate: String) {
        var dataDailyImage:Data = Data()
        var stmt: OpaquePointer?

            let queryString = "SELECT diaryNumber, diaryTitle, diaryContent, diaryImage, diaryEmotion FROM dodamDiary WHERE diaryDate = ?"
            
            // Set sqlite for delete action
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
        
            // Set date for question mark in queryString
            if sqlite3_bind_text(stmt, 1, receivedDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
        
            // When selected data exists
            while sqlite3_step(stmt) == SQLITE_ROW{  // 읽어올 데이터가 있는지 확인
                viewNumber = String(cString: sqlite3_column_text(stmt, 0))
                viewTitle = String(cString: sqlite3_column_text(stmt, 1))
                viewContent = String(cString: sqlite3_column_text(stmt, 2))
                
                if let dataBlob = sqlite3_column_blob(stmt, 3){
                    let viewDailyImage = Int(sqlite3_column_bytes(stmt, 3))
                    dataDailyImage = Data(bytes: dataBlob, count: viewDailyImage)
                }
                
                viewEmotion = String(cString: sqlite3_column_text(stmt, 4))

            }
        
            // Set view the diary for the selected date
            dailyTitle.text = viewTitle
            dailyContent.text = viewContent
            dailyEmotion.image = UIImage(named: Share.imageFileName[Int(viewEmotion)!])
        
            // When diaryImage exists
            if dataDailyImage.isEmpty {
                dailyImageStackView.isHidden = true

            // When diaryImage doesn't exist
            } else {
                dailyImageStackView.isHidden = false
                dailyImage.image = UIImage(data: dataDailyImage)
            }
    }
    
    // Press anywhere to erase the softkeyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
