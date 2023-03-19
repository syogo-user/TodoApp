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

    let refreshCtl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
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
            })
            .disposed(by: disposeBag)

    }

    private func setUp() {
        tableView.register(R.nib.taskTableViewCell)
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh), for: .valueChanged)

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
}

extension TaskListViewController: UITableViewDelegate {

    /// セクションの高さ
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//    }

//    // スクロール時
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        //一番下に到達したときの挙動
//    }

    /// セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100.0
    }

//    /// セルタップ
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 更新画面に遷移
//        let taskId = viewModel.toTaskId(index: indexPath.row)
//        self.toUpdateTask(taskId: taskId)
//    }

//    /// セルを左から右にスワイプ
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//    }
//
    /// セルを右から左にスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { _, _, handler in
//            self.deleteAlert(index: indexPath.row)
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }


}
