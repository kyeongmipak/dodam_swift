//
//  Diary.swift
//  DodamDodam
//
//  Created by Ria Song on 2021/03/13.
//

import Foundation

class Diary{ // Class to use as bean
    var diaryNumber: Int // key value
    var diaryTitle: String?
    var diaryContent: String?
    var diaryDate: String?
//    var diaryEmotion: Int
    var diaryEmotion: String?
    
    // Constructor
    init(diaryNumber: Int, diaryTitle: String?, diaryContent: String?, diaryDate: String?, diaryEmotion: String?) {
        self.diaryNumber = diaryNumber
        self.diaryTitle = diaryTitle
        self.diaryContent = diaryContent
        self.diaryDate = diaryDate
        self.diaryEmotion = diaryEmotion
    }
}
