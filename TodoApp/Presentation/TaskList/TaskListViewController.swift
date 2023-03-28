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
    private var selectMenuView: SelectMenuView?
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
                // 明示的にdisposeしないと開放されない
                taskTableViewCell.disposeBag = DisposeBag()
                taskTableViewCell.selectionStyle = .none
                // セル内のボタンタップイベント
                taskTableViewCell.completeCheckButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
                        let isCompleted = taskTableViewCell.completeCheckButton.isChecked
                        self.changeComplete(index: indexPath.row, isCompleted: isCompleted)
                    })
                    .disposed(by: taskTableViewCell.disposeBag)

                taskTableViewCell.favoriteButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
                        let isFavorite = taskTableViewCell.favoriteButton.isFavorite
                        self.changeFavorite(index: indexPath.row, isFavorite: isFavorite)
                    })
                    .disposed(by: taskTableViewCell.disposeBag)
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
                        onParseError: { self.parseErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
            })
            .disposed(by: disposeBag)

        // タスクの更新結果
        viewModel.updateTaskInfo
            .emit(onNext: { [unowned self] result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onAuthError: { self.tokenErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onAPIError: { self.updateTaskErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
                self.viewModel.loadLocalTaskList()
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
        let selectMenuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(showSelectMenuView))
        navigationItem.rightBarButtonItem = selectMenuButton

        tableView.register(R.nib.taskTableViewCell)
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.delegate = self
        
        if viewModel.isFromSignIn() {
            self.isConnect() {
                // サーバからデータを取得
                viewModel.fetchTaskList()
                viewModel.setFromSignIn()
            }
        } else {
            // ローカルからデータを取得
            viewModel.loadLocalTaskList()
        }
    }


    @objc private func showSelectMenuView() {
        selectMenuView = SelectMenuView(frame: .null)
        guard let selectMenuView = self.selectMenuView else { return }
        selectMenuView.delegate = self
        selectMenuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectMenuView)
        selectMenuView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        selectMenuView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        selectMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        selectMenuView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64.0).isActive = true
    }

    private func dismissSelectMenuView() {
        selectMenuView?.removeFromSuperview()
//        selectMenuView = nil
    }

    private func changeComplete(index: Int, isCompleted: Bool) {
        viewModel.changeComplete(index: index, isCompleted: isCompleted)
        viewModel.updateTask(index: index)
    }

    private func changeFavorite(index: Int, isFavorite: Bool) {
        viewModel.changeFavorite(index: index, isFavorite: isFavorite)
        viewModel.updateTask(index: index)
    }

    private func fetchTaskErrorDialog() {
        self.showDialog(
            title: R.string.localizable.fetchTaskErrorTitle(),
            message: R.string.localizable.fetchTaskErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func updateTaskErrorDialog() {
        self.showDialog(
            title: R.string.localizable.updateTaskErrorTitle(),
            message: R.string.localizable.updateTaskErrorMessage(),
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

    override func localDbErrorDialog() {
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
        self.isConnect() {
            viewModel.fetchTaskList()
        }
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

    /// セルを右から左にスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { _, _, handler in
            self.isConnect() {
                self.deleteWarningDialog() {
                    // タスクの削除
                    self.viewModel.deleteTask(index: indexPath.row)
                }
            }
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension TaskListViewController: SelectMenuViewDelegate {
    func sortDateAscendingOrder() {
        dismissSelectMenuView()
        // ユーザデフォルトに保存
        viewModel.setSortOrder(sortOrder: Sort.ascendingOrderDate.rawValue)
        // ロードする
        viewModel.loadLocalTaskList()
    }

    func sortDateDescendingOrder() {
        dismissSelectMenuView()
        // ユーザデフォルトに保存
        viewModel.setSortOrder(sortOrder: Sort.descendingOrderDate.rawValue)
        // ロードする
        viewModel.loadLocalTaskList()
    }
}
