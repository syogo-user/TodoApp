//
//  CommonDate.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/17.
//

import Foundation
import FSCalendar
import CalculateCalendarLogic

class CommonDate {
    private static let weekList = ["日", "月", "火", "水", "木", "金", "土"]
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    static func judgeHoliday(_ date : Date) -> Bool {
         //祝日判定用のカレンダークラスのインスタンス
         let tmpCalendar = Calendar(identifier: .gregorian)
         // 祝日判定を行う日にちの年、月、日を取得
         let year = tmpCalendar.component(.year, from: date)
         let month = tmpCalendar.component(.month, from: date)
         let day = tmpCalendar.component(.day, from: date)
         // CalculateCalendarLogic()：祝日判定のインスタンスの生成
         let holiday = CalculateCalendarLogic()
         return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
     }
    
    // 曜日判定(日曜日:0 〜 土曜日:6)
    static func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date) - 1
    }
    
    // 年月日を取得
    static func getDay(_ date:Date) -> (Int,Int,Int) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }

    // カレンダー曜日設定
    static func layoutCalendar(calendar: FSCalendar) {
        for (index,weekday) in calendar.calendarWeekdayView.weekdayLabels.enumerated() {
            weekday.text = weekList[index]
            if weekList[index] == weekList[0] {
                // 日曜
                weekday.textColor = UIColor.red
            } else if weekList[index] == weekList[6] {
                // 土曜
                weekday.textColor = UIColor.blue
            } else {
                // 平日
                weekday.textColor = UIColor.black
            }
        }
    }
    
}
