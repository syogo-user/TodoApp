//
//  ListViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//
import Firebase
import UIKit
import SVProgressHUD

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskAddButton: UIButton!
    private let cellId = "cellId"
    private let toEditSegue = "toEdit"
    var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.taskAddButton.layer.cornerRadius = taskAddButton.bounds.width / 2
        self.taskAddButton.backgroundColor = .darkGray
        self.taskAddButton.addTarget(self, action: #selector(taskAdd), for: .touchUpInside)
        self.taskAddButton.setImage(UIImage(systemName:"plus"), for: .normal)
        self.taskAddButton.tintColor = .white
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellId)
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.rightBarButtonItems = []
        tabBarController?.title = "タスク一覧"
        guard let _ = Auth.auth().currentUser else { return }
        // タスクの一覧を取得
        taskRequest()
    }
    
    @objc private func taskAdd() {
        // 登録画面に遷移
        guard let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else { return }
        postVC.maxOrderNo = taskList.map{ $0.order }.max() ?? -1
        self.present(postVC,animated: true, completion: nil)
    }
    
    //タスクの一覧を取得
    func taskRequest() {
        self.taskList = []
        self.tableView.reloadData()
        // ログインUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        SVProgressHUD.show()
        // タスク一覧データを取得
        API.shared.getTasks(uid:uid, type: TaskList.self) { tasks in
            guard let taskList = tasks else { return }
            self.taskList =  taskList.tasks
            //日付順に入れ替える
            self.taskList.sort{ (d0 ,d1) -> Bool in
                if d0.date == d1.date {
                    //日付が同じ場合
                    return d0.order < d1.order
                } else {
                    //日付が異なる場合
                    return Int(d0.date) ?? 0  < Int(d1.date) ?? 0
                }
            }
            DispatchQueue.main.async {
                //メインスレッドにて実施
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListTableViewCell
        cell.setData(self.taskList[indexPath.row])
        // セル選択時白色
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = selectionView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集画面へ遷移
        performSegue(withIdentifier: toEditSegue, sender: taskList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    // 削除ボタンが押されて時に呼ばれる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除
        SVProgressHUD.show()
        API.shared.deleteTask(deleteTaskId: taskList[indexPath.row].taskId,type: Task.self) { _ in
            // タスク削除後に一覧を再取得
            self.taskRequest()
            SVProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toEditSegue {
            guard let editVC = segue.destination as? EditViewController else { return }
            editVC.task = sender as? Task
        }
    }
    
}
