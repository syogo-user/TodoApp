//
//  TaskListRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import UIKit

extension TaskListViewController {

    func toAddTask() {
        guard let addTaskVC = R.storyboard.list.addTaskVC() else { return }
        addTaskVC.delegate = self
        self.present(addTaskVC, animated: true)
    }

    func toUpdateTask(taskInfoItem: TaskInfoItem) {
        guard let updateTaskVC =  R.storyboard.list.updateTaskVC() else { return }
        updateTaskVC.updateTask = taskInfoItem
        self.present(updateTaskVC, animated: true)
    }
}
