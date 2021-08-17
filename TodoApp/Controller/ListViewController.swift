//
//  ListViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//
import Firebase
import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskAddButton: UIButton!
    let cellId = "cellId"
    let toEditSegue = "toEdit"
    var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        taskAddButton.layer.cornerRadius = taskAddButton.bounds.width / 2
        taskAddButton.backgroundColor = .darkGray
        tableView.delegate = self
        tableView.dataSource = self
        taskAddButton.addTarget(self, action: #selector(taskAdd), for: .touchUpInside)
        taskAddButton.setImage(UIImage(systemName:"plus"), for: .normal)
        taskAddButton.tintColor = .white
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Auth.auth().currentUser else { return }
        // タスクの一覧を取得
        taskRequest()
    }
    
    @objc private func taskAdd() {
        // 登録画面に遷移
        guard let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else { return }
        postVC.modalPresentationStyle = .fullScreen
        self.present(postVC,animated: true, completion: nil)
    }
    
    //タスクの一覧を取得
    func taskRequest() {
        self.taskList = []
        self.tableView.reloadData()
        // ログインUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // タスク一覧データを取得
        API.shared.getTasks(uid:uid,method:.get, type: TaskList.self) { tasks in
            guard let taskList = tasks else { return }
            self.taskList =  taskList.tasks
            DispatchQueue.main.async {
                //メインスレッドにて実施
                self.tableView.reloadData()
            }
        }
    }    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListTableViewCell
        cell.setData(taskList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集画面へ遷移
        performSegue(withIdentifier: toEditSegue, sender: taskList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // 削除ボタンが押されて時に呼ばれる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除
        API.shared.deleteTask(method: .delete, deleteTaskId: taskList[indexPath.row].taskId,type: Task.self) { _ in
            // タスク削除後に一覧を再取得
            self.taskRequest()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toEditSegue {
            guard let editVC = segue.destination as? EditViewController else { return }
            editVC.task = sender as? Task
        }
    }
    
}
