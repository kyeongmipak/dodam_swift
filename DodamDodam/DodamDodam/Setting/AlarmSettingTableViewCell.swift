//
//  AlarmSettingTableViewCell.swift
//  DodamDodam
//
//  Created by 김대환 on 2021/03/04.
//

import UIKit

class AlarmSettingTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func alarmSwitch(_ sender: UISwitch) {
        print("select")
    }
}
