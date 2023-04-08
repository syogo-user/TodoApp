//
//  UpdateTaskRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/04/01.
//

import Foundation
import UIKit

extension UpdateTaskViewController {
    /// 予定日時選択画面に遷移
    func toSelectDate() {
        guard let selectDateVC = R.storyboard.list.selectDateVC() else { return }
        if let date = self.getSelectDate() {
            selectDateVC.setSelectDate(selectDate: date)
        }
        selectDateVC.modalPresentationStyle = .fullScreen
        selectDateVC.delegate = self
        self.present(selectDateVC, animated: false, completion: nil)
    }
}
