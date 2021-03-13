//
//  MonthlyListTableViewCell.swift
//  DodamDodam
//
//  Created by Ria Song on 2021/03/13.
//

import UIKit

class MonthlyListTableViewCell: UITableViewCell {
    
    @IBOutlet var iv_emotion: UIImageView!
    @IBOutlet var lbl_DiaryTitle: UILabel!
    @IBOutlet var lbl_DiaryDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
