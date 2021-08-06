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
        
        let nib = UINib(nibName:"ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
//        taskAdd()
        tableView.reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
//    func taskAdd(){
//        taskList.append(Task(id: "1", title: "Swift", content: "StackViewについて", date: Date()))
//        taskList.append(Task(id: "2", title: "AWS", content: "CloudWatch", date: Date()))
//        taskList.append(Task(id: "3", title: "Python", content: "AI", date: Date()))
//        taskList.append(Task(id: "4", title: "TypeScript", content: "React", date: Date()))
//    }
    
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
