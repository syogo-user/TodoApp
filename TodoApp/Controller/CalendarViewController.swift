//
//  CalendarViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/16.
//

import UIKit
import FirebaseAuth
import FSCalendar
import CalculateCalendarLogic
import SVProgressHUD

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    private let cellId = "cellId"
    private var selectDate = Date().dateFormat()
    var taskList :[Task] = []
    var calendarTaskList:[Task] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.backgroundColor = .clear
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellId)
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let settingBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "figure.walk"), style: .plain, target: self, action: #selector(logoutMenu))
        tabBarController?.navigationItem.rightBarButtonItems = [settingBarButtonItem]
        tabBarController?.title = "Myカレンダー"
        // カレンダーのページを本日に設定
        self.calendar.currentPage = Date()
        //　カレンダーの設定
        self.calendar.layoutCalendar()
        //　タスク一覧を取得
        taskRequest()
    }
    
    //タスクの一覧を取得
    private func taskRequest() {
        self.taskList = []
        self.tableView.reloadData()
        SVProgressHUD.show()
        // ログインUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // タスク一覧データを取得
        API.shared.getTasks(uid:uid, type: TaskList.self) { tasks in
            guard let taskList = tasks else { return }
            self.calendarTaskList = taskList.tasks
            // カレンダーにて選択した日付のタスクのみを抽出
            self.taskList =  taskList.tasks.filter({ (task) -> Bool in
                task.date == self.selectDate
            })
            DispatchQueue.main.async {
                //メインスレッドにて実施
                self.calendar.reloadData()
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
        
    @objc private func logoutMenu() {
        let dialog = UIAlertController(title: Const.Message7, message: nil, preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            SVProgressHUD.show()
            // ログアウト
            try! Auth.auth().signOut()
            // ログイン画面を表示する
            let mainStoryboard =  UIStoryboard(name: "Main", bundle: nil)
            guard let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
            // 左タブを選択
            self.tabBarController?.selectedIndex = 0
            SVProgressHUD.dismiss()
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 日付選択時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 選択日付のタスクを取得
        self.selectDate = date.dateFormat()
        self.taskList = self.calendarTaskList.filter({ (task) -> Bool in
            task.date == self.selectDate
        })
        self.tableView.reloadData()
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
    
    // 日付下のマーク（点）の表示
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count = 0
        for i in self.calendarTaskList {
            if i.date == date.dateFormat() {
                count = count + 1
            }
        }
        return count
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListTableViewCell
        cell.setData(taskList[indexPath.row])
        // セル選択時白色
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = selectionView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集画面へ遷移
        let listStoryboard =  UIStoryboard(name: "List", bundle: nil)
        let editVC = listStoryboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.task = taskList[indexPath.row]
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}
