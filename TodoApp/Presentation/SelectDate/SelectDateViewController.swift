//
//  SelectDateViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/04/01.
//

import Foundation
import UIKit

protocol SelectDateViewControllerDelegate: AnyObject {
    /// 日付選択を通知する
    func didSelectDate(_ date: Date)
}

class SelectDateViewController: BaseViewController {
    weak var delegate: SelectDateViewControllerDelegate?
    private var selectDate: Date?
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }

    func setSelectDate(selectDate: Date) {
        self.selectDate = selectDate
    }

    private func setUp() {
        guard let selectDate = self.selectDate else { return }
        self.datePicker.date = selectDate
    }

    @IBAction func selectDatea(_ sender: Any) {
        delegate?.didSelectDate(datePicker.date)
        self.dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

