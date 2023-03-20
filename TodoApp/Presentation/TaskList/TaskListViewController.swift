//
//  TaskListViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import UIKit
import RxSwift

class TaskListViewController: BaseViewController {
    private var viewModel: TaskListViewModel = TaskListViewModelImpl()
    private let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    let refreshCtl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelValue()
        setUp()
    }

    private func bindViewModelValue() {
        viewModel.taskItems.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.taskListTableViewCell.identifier)) { [weak self] _, element, cell in
                guard let taskTableViewCell = cell as? TaskTableViewCell else {
                    return
                }
                taskTableViewCell.setUp(taskInfoItem: element)
            }
            .disposed(by: disposeBag)

        viewModel.taskInfo
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(error: error) {

                    }
                }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

    }

    private func setUp() {
        tableView.register(R.nib.taskTableViewCell)
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.delegate = self
        
        if viewModel.isFromSignIn() {
            // サーバからデータを取得
            viewModel.fetchTaskList()
            viewModel.setFromSignIn()
        } else {
            // ローカルからデータを取得
            viewModel.loadLocalTaskList()
        }
    }

    @objc private func refresh() {
        viewModel.fetchTaskList()
        refreshCtl.endRefreshing()
    }

    @IBAction private func add(_ sender: Any) {
        toAddTask()
    }
}

extension TaskListViewController: AddTaskViewControllerDelegate {
    /// タスクの送信後
    func didTapSend() {
        viewModel.loadLocalTaskList()
    }
}

extension TaskListViewController: UITableViewDelegate {
    /// セクションの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20.0
    }

    /// セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120.0
    }

    /// セルタップ
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toUpdateTask(taskInfoItem: viewModel.selectItemAt(index: indexPath.row))
    }

    /// セルを左から右にスワイプ
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { _, _, handler in
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }

    /// セルを右から左にスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { _, _, handler in
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
