//
//  DateSelectViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/19.
//

import UIKit
import FSCalendar

class DateSelectViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var decisionButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    private var selectDate: String = Date().dateFormat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        decisionButton.addTarget(self, action: #selector(decision), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(dissmiss), for: .touchUpInside)
        //　カレンダーの設定
        CommonDate.layoutCalendar(calendar:self.calendar)
    }
    
    // 日付決定
    @objc private func decision() {
        guard let preVC = presentingViewController as? PostViewController else { return }
        preVC.selectDate = selectDate
        dissmiss()
    }
    
    // 画面を閉じる
    @objc private func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }    
}

extension DateSelectViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 日付選択時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 選択した日付を取得
        selectDate = date.dateFormat()
    }
    
    // 土日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 祝日判定をする（祝日は赤色で表示する）
        if CommonDate.judgeHoliday(date) {
            return UIColor.red
        }
        // 土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = CommonDate.getWeekIdx(date)
        if weekday == 0 {
            // 日曜日
            return UIColor.red
        }
        else if weekday == 6 {
            // 土曜日
            return UIColor.blue
        }
        return nil
    }
}
