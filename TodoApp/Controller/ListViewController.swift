//
//  ListViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//

import UIKit

class ListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskAddButton: UIButton!
    
    let cellId = "cellId"
    var taskList:[Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        taskAddButton.layer.cornerRadius = taskAddButton.bounds.width / 2
        taskAddButton.backgroundColor = .darkGray
        tableView.delegate = self
        tableView.dataSource = self
        taskAddButton.addTarget(self, action: #selector(taskAdd), for: .touchUpInside)
        
        let nib = UINib(nibName:"ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskRequest()
        
        
    }
    @objc private func taskAdd(){
        //タスクのIdで最大値を検索
        let maxId = taskList.map{$0.taskId}.max() ?? 0
        //登録画面に遷移
        guard let postVC = self.storyboard?.instantiateViewController(withIdentifier:"PostViewController") as? PostViewController else { return }
        postVC.modalPresentationStyle = .fullScreen
        postVC.maxId = maxId
        self.present(postVC,animated: true,completion:nil)
    }
    
    //タスクの一覧を取得
    func taskRequest(){
        API.shared.request(type: [Task?].self) { (tasks) in
            self.taskList = tasks.compactMap{$0} //nilを除外
            print("self.taskList",self.taskList)
            DispatchQueue.main.async {
                //メインスレッドにて実施
                self.tableView.reloadData()
            }

        }
    }    
}
extension ListViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListTableViewCell
        cell.setData(taskList[indexPath.row])
        return cell
    }
    
    
}
