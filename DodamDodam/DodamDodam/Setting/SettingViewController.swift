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
    let optionList: [String] = ["프로필", "테마", "폰트"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table View Delegate Data Source Setting
        self.tableView.delegate = self
        self.tableView.dataSource = self
       
        
        // Remove cell underline
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    // return Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // Footer Title
      func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
          return "알림 시간은 입니다."
        }
        return nil
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
            //            case 3: self.performSegue(withIdentifier: "pushAlarm", sender: nil)
            default:
                return
            }
        }else{
            switch indexPath.row {
            case 0: self.performSegue(withIdentifier: "pushAlarm", sender: nil)
            default:
                return
            }
        }
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
             case 0:
                 return optionList.count
             case 1:
                 return 1
             default:
                 return 0
             }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.section < 1 {
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
                let text: String =  optionList[indexPath.row]
                cell.textLabel?.text = text
                return cell
            } else {
                let customCell: AlarmSettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.customCellIdentifier, for: indexPath) as! AlarmSettingTableViewCell
                return customCell
            }
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
