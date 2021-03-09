//
//  SettingViewController.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let customCellIdentifier: String = "SettingAlarmCell"
    let cellIdentifier: String = "SettingCell"
    let optionList: [String] = ["프로필", "테마", "폰트", "푸시 알림"]
    
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table View Delegate Data Source Setting
        self.tableView.delegate = self
        self.tableView.dataSource = self
       
        
        // Remove cell underline
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    
       
        // 알림센터에 옵저버를 적용
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                          object: nil,
                                                          queue: .main) {
            [unowned self] notification in
            // background에서 foreground로 돌아오는 경우 실행 될 코드
            notificationAllow()
        
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // return Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // Footer Title
      func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
             // Load
//            return "알림 시간은 매일 \(String(describing: UserDefaults.standard.value(forKey: "TimeKeeper")!))입니다!"
        }
        

        return nil
      }
    

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return CGFloat.leastNonzeroMagnitude
       }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
      }
    
    
    // select the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section < 1 {
            switch indexPath.row {
            case 0: self.performSegue(withIdentifier: "profile", sender: nil)
            case 1: self.performSegue(withIdentifier: "theme", sender: nil)
            case 2: self.performSegue(withIdentifier: "font", sender: nil)
            case 3:
                if String(describing: UserDefaults.standard.value(forKey: "TimeKeeper")!) == "notAllow"{
                    let resultAlert = UIAlertController(title: "Dodam 알림", message: "푸시 알림을 허용해주세요!", preferredStyle: UIAlertController.Style.actionSheet)
                    let okAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler:nil)
                    let moveToSetting = UIAlertAction(title: "설정창으로 이동", style: UIAlertAction.Style.default, handler: {ACTION in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                        self.navigationController?.popViewController(animated: true)
                    })
                    resultAlert.addAction(okAction)
                    resultAlert.addAction(moveToSetting)
                    self.present(resultAlert, animated: true, completion: nil)
            }else  {
                self.performSegue(withIdentifier: "pushAlarm", sender: nil)
            }
            default:
                return
            }
        }
        
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
             case 0:
                 return optionList.count
//             case 1:
//                 return 1
             default:
                 return 0
             }
        }
        
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
//            if indexPath.section < 1 {
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
                let text: String =  optionList[indexPath.row]
                cell.textLabel?.text = text
                return cell
//            } else {
//                let customCell: AlarmSettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.customCellIdentifier, for: indexPath) as! AlarmSettingTableViewCell
//                return customCell
//            }
        }

    func notificationAllow(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: {didAllow,Error in
            if didAllow {
                UserDefaults.standard.set("doAllow", forKey: "TimeKeeper")
                print("Push: 권한 허용")
            } else {
                UserDefaults.standard.set("notAllow", forKey: "TimeKeeper")
                print("Push: 권한 거부")
            }
        })
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
