//
//  DetailUploadImageViewController.swift
//  DodamDodam
//
//  Created by 박경미 on 2021/03/21.
//

import UIKit
import SQLite3

class DetailUploadImageViewController: UIViewController {
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var closePage: UILabel!
    
    var diaryDate = ""
    
    var db: OpaquePointer?
    
    // Set SQLite for using Korean
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Open SQLite file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        // If there is a problem opening database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        }
                
        // Execute SQL for watching a daily image
        dailyImageSearchAction()
        
    }
    
    // Execute SQL for watching a daily image
    func dailyImageSearchAction() {
        var dataDaily:Data = Data()
        var stmt: OpaquePointer?

            let queryString = "SELECT diaryImage FROM dodamDiary WHERE diaryDate = ?"
            
            // Set sqlite for select action
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {  // insert 하기 위한 셋팅
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
            
            // Set date for question mark in queryString
            if sqlite3_bind_text(stmt, 1, diaryDate, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                _ = String(cString: sqlite3_errmsg(db)!)
                return
            }
        
            // When diaryDate exists
            while sqlite3_step(stmt) == SQLITE_ROW{
                if let dataBlob = sqlite3_column_blob(stmt, 0){
                    let viewCondition = Int(sqlite3_column_bytes(stmt, 0))
                    dataDaily = Data(bytes: dataBlob, count: viewCondition)
                }
            }
            
            // Set clicked image for enlarging
            uploadImage.image = UIImage(data: dataDaily)
    }
            
}
