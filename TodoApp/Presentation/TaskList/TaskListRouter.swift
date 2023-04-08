//
//  TaskListRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import UIKit

extension TaskListViewController {
    /// 追加画面に遷移
    func toAddTask() {
        guard let addTaskVC = R.storyboard.list.addTaskVC() else { return }
        addTaskVC.delegate = self
        self.present(addTaskVC, animated: true)
    }

    /// 更新画面に遷移
    func toUpdateTask(taskInfoItem: TaskInfoItem) {
        guard let updateTaskVC =  R.storyboard.list.updateTaskVC() else { return }
        updateTaskVC.setUpdateTask(task: taskInfoItem)
        updateTaskVC.delegate = self
        navigationController?.pushViewController(updateTaskVC, animated: true)
    }
}
