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
    private var selectDate = Date().dateFormat()
    var task :Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.decisionButton.addTarget(self, action: #selector(decision), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(dissmiss), for: .touchUpInside)
        //　カレンダーの曜日設定
//        CommonDate.layoutCalendar(calendar:self.calendar)
        self.calendar.layoutCalendar()
        // カレンダーの初期日付を設定
        calendarSelect()
    }
    
    // 初期選択日付を設定
    private func calendarSelect(){
        guard let task = self.task else { return }
        let year = Int(String(task.date.prefix(4)))
        // 5文字目の位置を指定
        let startIndex = task.date.index(task.date.startIndex, offsetBy: 4)
        // 6文字目の位置を指定
        let endIndex = task.date.index(task.date.endIndex, offsetBy: -3)
        let month = Int(String(task.date[startIndex...endIndex]))
        let day = Int(String(task.date.suffix(2)))
        let calendar = Calendar.current
        let selectDate = calendar.date(from: DateComponents(year: year, month: month, day: day))
        // カレンダーへ初期選択日付を設定
        self.calendar.select(selectDate)
    }
    
    // 日付決定
    @objc private func decision() {
        if presentingViewController is PostViewController {
            // 投稿画面へ戻る場合
            guard let postVC = presentingViewController as? PostViewController else { return }
            postVC.selectDate = self.selectDate
            postVC.setDateButton()
        } else {
            // 編集画面へ戻る場合
            guard let navVC =  self.presentingViewController as? UINavigationController else { return }
            guard let editVC = navVC.topViewController as? EditViewController else { return }
            editVC.task = self.task
            editVC.displayLayout()
        }
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
        if self.task != nil {
            // タスクがnilの場合(投稿画面からの遷移)
            self.task?.date = date.dateFormat()
        } else {
            // タスクがnilでない場合(編集画面からの遷移)
            self.selectDate = date.dateFormat()
        }
    }
    
    // 土日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 祝日判定をする（祝日は赤色で表示する）
        if calendar.judgeHoliday(date) {
            return UIColor.red
        }
        // 土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = calendar.getWeekIdx(date)
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
