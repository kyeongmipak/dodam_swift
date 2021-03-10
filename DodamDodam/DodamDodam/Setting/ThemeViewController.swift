//
//  ThemeViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit
import SQLite3

class ThemeViewController: UIViewController {

    @IBOutlet weak var themeBrown: UIImageView!
    @IBOutlet weak var tnemeRed: UIImageView!
    @IBOutlet weak var themeSky: UIImageView!
    @IBOutlet weak var themeYellow: UIImageView!
    @IBOutlet weak var themePink: UIImageView!
    @IBOutlet weak var themeBlue: UIImageView!
    
    @IBOutlet weak var selectTheme: UILabel!
    
    // SQLite3 와 연결하기 위해 :OpaquePointer 로 연결
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // **********************************
        // SQLite 생성하기
        //.appendingPathComponent("ThemeData.sqlite") -> 파일이름 생성.확장자
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        // 없으면 오류 메시지 띄우기
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        //
        
        
        // 이미지뷰를 터치했을때 이벤트 주기 ( 빨간색 ) +++++++++++++++++
        let tapBrown = UITapGestureRecognizer(target: self, action: #selector(touchToBrown))
        themeBrown.addGestureRecognizer(tapBrown)
        themeBrown.isUserInteractionEnabled = true
        // ++++++++++++++++++++++++++++++++++++++++
        
        // 이미지뷰를 터치했을때 이벤트 주기 ( 노란색 ) +++++++++++++++++
        let tapRed = UITapGestureRecognizer(target: self, action: #selector(touchToRed))
        tnemeRed.addGestureRecognizer(tapRed)
        tnemeRed.isUserInteractionEnabled = true
        // ++++++++++++++++++++++++++++++++++++++++
        
        // 이미지뷰를 터치했을때 이벤트 주기 ( 하늘색 ) +++++++++++++++++
        let tapSky = UITapGestureRecognizer(target: self, action: #selector(touchToSky))
        themeSky.addGestureRecognizer(tapSky)
        themeSky.isUserInteractionEnabled = true
        // ++++++++++++++++++++++++++++++++++++++++
        
        // 이미지뷰를 터치했을때 이벤트 주기 ( 주황색 ) +++++++++++++++++
        let tapYellow = UITapGestureRecognizer(target: self, action: #selector(touchToYellow))
        themeYellow.addGestureRecognizer(tapYellow)
        themeYellow.isUserInteractionEnabled = true
        // ++++++++++++++++++++++++++++++++++++++++
        
        // 이미지뷰를 터치했을때 이벤트 주기 ( 초록색 ) +++++++++++++++++
        let tapPink = UITapGestureRecognizer(target: self, action: #selector(touchToPink))
        themePink.addGestureRecognizer(tapPink)
        themePink.isUserInteractionEnabled = true
        // ++++++++++++++++++++++++++++++++++++++++
        
        // 이미지뷰를 터치했을때 이벤트 주기 ( 보라색 ) +++++++++++++++++
        let tapBlue = UITapGestureRecognizer(target: self, action: #selector(touchToBlue))
        themeBlue.addGestureRecognizer(tapBlue)
        themeBlue.isUserInteractionEnabled = true
        // ++++++++++++++++++++++++++++++++++++++++
        
        selectTheme.isHidden = true
        
    }
    
    //테마 **********************************
    // 갈색 테마
    @objc func touchToBrown(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .brown
            UITabBar.appearance().barTintColor = .brown
            self.tabBarController?.tabBar.barTintColor = .brown
            
            // 버튼 배경 지정
            UIButton.appearance().backgroundColor = .brown
            
            selectTheme.text = "brown"
        }
    }
    // 빨간색 테마
    @objc func touchToRed(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .red
            UITabBar.appearance().barTintColor = .red
            self.tabBarController?.tabBar.barTintColor = .red
            
            // 버튼 배경 지정
            UIButton.appearance().backgroundColor = .red
            
            selectTheme.text = "red"
            
        }
    }
    // 하늘색 테마
    @objc func touchToSky(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .systemTeal
            UITabBar.appearance().barTintColor = .systemTeal
            self.tabBarController?.tabBar.barTintColor = .systemTeal
            
            
            // 버튼 배경 지정
            UIButton.appearance().backgroundColor = .systemTeal
            
            selectTheme.text = "systemTeal"
        }
    }
    // 노란색 테마
    @objc func touchToYellow(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .yellow
            UITabBar.appearance().barTintColor = .yellow
            self.tabBarController?.tabBar.barTintColor = .yellow
            
            // 버튼 배경 지정
            UIButton.appearance().backgroundColor = .yellow
            
            selectTheme.text = "yellow"
        }
    }
    // 핑크색 테마
    @objc func touchToPink(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .systemPink
            UITabBar.appearance().barTintColor = .systemPink
            self.tabBarController?.tabBar.barTintColor = .systemPink
            
            // 버튼 배경 지정
            UIButton.appearance().backgroundColor = .systemPink
            
            selectTheme.text = "systemPink"
        }
    }
    // 파란색 테마
    @objc func touchToBlue(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .blue
            UITabBar.appearance().barTintColor = .blue
            self.tabBarController?.tabBar.barTintColor = .blue
            
            // 버튼 배경 지정
            UIButton.appearance().backgroundColor = .blue
            
            selectTheme.text = "blue"
        }
    }
    //테마 **********************************
    
    
    
    
    @IBAction func themeChange(_ sender: UIButton) {
        

        // 값 업데이트
        // TableViewController 의 tempInsert() 부분을 전체 복붙해옴
        var stmt: OpaquePointer?

        // 이게 있어야 한글을 입력해도 무관하다.
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self) // <-- 중요!!!!!

        //++++++++++++++
        //.trimmingCharacters(in: .whitespacesAndNewlines) -> 스페이스를 입력했을 떄를 대비한다.
        let settingTheme = selectTheme.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        //++++++++++++++

        let queryString = "UPDATE dodamSetting SET settingTheme = ? WHERE userNo = ?"

        // ? 있으니 prepare 해주기
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        // (?) 입력 받을 값이 총 1개 이므로 하나하나 if문을 돌려준다.
        // ? 첫번째 sname
        if sqlite3_bind_text(stmt, 1, settingTheme, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding name: \(errmsg)")
            return
        }


        // ? 네번째 sid
        if sqlite3_bind_text(stmt, 2, "1", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error binding phone: \(errmsg)")
            return
        }

        // 연결 해주기
        if sqlite3_step(stmt) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting : \(errmsg)")
            return
        }

        //++++++++++++++
        let resultAlert = UIAlertController(title: "결과", message: "수정이 완료되었습니다.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: {ACTION in
            self.navigationController?.popViewController(animated: true)    // 현재 화면 close
        })

        resultAlert.addAction(okAction)
        present(resultAlert, animated: true, completion: nil)
        //++++++++++++++
        print("Theme update successfully")


    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
