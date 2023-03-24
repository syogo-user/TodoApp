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
    @IBOutlet private weak var tableView: UITableView!
    let refreshCtl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelValue()
        setUp()
    }

    private func bindViewModelValue() {
        viewModel.isLoading
            .drive(onNext: { [unowned self] isLoading in
                self.setIndicator(show: isLoading)
            })
            .disposed(by: disposeBag)

        // セル情報
        viewModel.taskItems.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.taskListTableViewCell.identifier)) { [weak self] _, element, cell in
                guard let taskTableViewCell = cell as? TaskTableViewCell else {
                    return
                }
                taskTableViewCell.setUp(taskInfoItem: element)
            }
            .disposed(by: disposeBag)

        // タスクの取得結果
        viewModel.taskInfo
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onAuthError: { self.tokenErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onAPIError: { self.fetchTaskErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
            })
            .disposed(by: disposeBag)

        // タスクの削除結果
        viewModel.deleteTaskInfo
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onAuthError: { self.tokenErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onAPIError: { self.deleteTaskErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
            })
            .disposed(by: disposeBag)
    }

    private func setUp() {
        navigationItem.backButtonDisplayMode = .minimal
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

    private func fetchTaskErrorDialog() {
        self.showDialog(
            title: R.string.localizable.fetchTaskErrorTitle(),
            message: R.string.localizable.fetchTaskErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func deleteTaskErrorDialog() {
        self.showDialog(
            title: R.string.localizable.deleteTaskErrorTitle(),
            message:  R.string.localizable.deleteTaskErrorMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    private func localDbErrorDialog() {
        self.showDialog(
            title: R.string.localizable.localDbErrorTitle(),
            message: R.string.localizable.localTaskDBErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func deleteWarningDialog(completion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: R.string.localizable.deleteWarningTitle(), message: R.string.localizable.deleteWarningMessage(), preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { action in
            completion?()
        }))
        dialog.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        self.present(dialog,animated: true,completion: nil)
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
    /// タスクの追加後
    func didAddTask() {
        viewModel.loadLocalTaskList()
    }
}

extension TaskListViewController: UpdateTaskViewControllerDelegate {
    /// タスクの更新後
    func didUpdateTask() {
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
            self.deleteWarningDialog() {
                // タスクの削除
                self.viewModel.deleteTask(index: indexPath.row)
            }
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
