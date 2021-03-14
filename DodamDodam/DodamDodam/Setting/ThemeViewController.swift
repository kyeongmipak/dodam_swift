//
//  ThemeViewController.swift
//  DodamDodam
//
//  Created by 박지은 on 2021/03/04.
//

import UIKit
import SQLite3

class ThemeViewController: UIViewController {
    
    @IBOutlet weak var themePurple: UIImageView!
    @IBOutlet weak var themePink: UIImageView!
    @IBOutlet weak var themeGreen: UIImageView!
    @IBOutlet weak var themeYellow: UIImageView!
    @IBOutlet weak var themeOrange: UIImageView!
    @IBOutlet weak var themeSky: UIImageView!
    
    @IBOutlet weak var selectTheme: UILabel!
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Open SQLite file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Dodam.sqlite")
        
        // If there is a problem opening database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        }
        
        // Event cycle when clicking image view -> Purple
        let tapPurple = UITapGestureRecognizer(target: self, action: #selector(touchToPurple))
        themePurple.addGestureRecognizer(tapPurple)
        themePurple.isUserInteractionEnabled = true
        
        // Event cycle when clicking image view -> Pink
        let tapPink = UITapGestureRecognizer(target: self, action: #selector(touchToPink))
        themePink.addGestureRecognizer(tapPink)
        themePink.isUserInteractionEnabled = true
        
        // Event cycle when clicking image view -> Green
        let tapGreen = UITapGestureRecognizer(target: self, action: #selector(touchToGreen))
        themeGreen.addGestureRecognizer(tapGreen)
        themeGreen.isUserInteractionEnabled = true
        
        // Event cycle when clicking image view -> Yellow
        let tapYellow = UITapGestureRecognizer(target: self, action: #selector(touchToYellow))
        themeYellow.addGestureRecognizer(tapYellow)
        themeYellow.isUserInteractionEnabled = true
        
        // Event cycle when clicking image view -> Orange
        let tapOrange = UITapGestureRecognizer(target: self, action: #selector(touchToOrange))
        themeOrange.addGestureRecognizer(tapOrange)
        themeOrange.isUserInteractionEnabled = true
        
        // Event cycle when clicking image view -> Sky
        let tapSky = UITapGestureRecognizer(target: self, action: #selector(touchToSky))
        themeSky.addGestureRecognizer(tapSky)
        themeSky.isUserInteractionEnabled = true
        
        // Hide selected theme text
        selectTheme.isHidden = true
    }
    
    
    // Purple theme
    @objc func touchToPurple(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
            UITabBar.appearance().barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
            self.tabBarController?.tabBar.barTintColor = .init(red: 220.0/255.0, green:197.0/255.0,  blue: 253.0/255.0, alpha: 1)
            
            selectTheme.text = "Purple"
        }
    }
    // Pink theme
    @objc func touchToPink(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
            UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
            self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:179.0/255.0,  blue: 219.0/255.0, alpha: 1)
            
            selectTheme.text = "Pink"
            
        }
    }
    // Green theme
    @objc func touchToGreen(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
            UITabBar.appearance().barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
            self.tabBarController?.tabBar.barTintColor = .init(red: 223.0/255.0, green:255.0/255.0,  blue: 230.0/255.0, alpha: 1)
            
            
            selectTheme.text = "Green"
        }
    }
    // Yellow theme
    @objc func touchToYellow(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
            UITabBar.appearance().barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
            self.tabBarController?.tabBar.barTintColor = .init(red: 251.0/255.0, green:254.0/255.0,  blue: 182.0/255.0, alpha: 1)
            
            selectTheme.text = "Yellow"
        }
    }
    // Orange theme
    @objc func touchToOrange(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
            UITabBar.appearance().barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
            self.tabBarController?.tabBar.barTintColor = .init(red: 253.0/255.0, green:197.0/255.0,  blue: 172.0/255.0, alpha: 1)
            
            selectTheme.text = "Orange"
        }
    }
    // Sky theme
    @objc func touchToSky(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.navigationController?.navigationBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
            UITabBar.appearance().barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
            self.tabBarController?.tabBar.barTintColor = .init(red: 206.0/255.0, green:221.0/255.0,  blue: 254.0/255.0, alpha: 1)
            
            selectTheme.text = "Sky"
        }
    }
    
    
    
    // button click -> theme change
    @IBAction func themeChange(_ sender: UIButton) {
        
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let settingTheme = selectTheme.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let queryString = "UPDATE dodamSetting SET settingTheme = ? WHERE userNo = ?"
        
        // Set sqlite for update action
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        if sqlite3_bind_text(stmt, 1, settingTheme, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        if sqlite3_bind_text(stmt, 2, "1", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE{
            _ = String(cString: sqlite3_errmsg(db)!)
            return
        }
        
        let resultAlert = UIAlertController(title: "결과", message: "수정이 완료되었습니다.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "네, 알겠습니다.", style: UIAlertAction.Style.default, handler: {ACTION in
            self.navigationController?.popViewController(animated: true)   
        })
        
        resultAlert.addAction(okAction)
        present(resultAlert, animated: true, completion: nil)
    }
    
}
