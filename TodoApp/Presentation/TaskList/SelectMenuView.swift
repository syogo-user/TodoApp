//
//  SelectMenuView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/26.
//

import UIKit

protocol SelectMenuViewDelegate: AnyObject {
    /// 日付の昇順
    func sortDateAscendingOrder()
    /// 日付の降順
    func sortDateDescendingOrder()
}

class SelectMenuView: UIView {

    weak var delegate: SelectMenuViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    private func loadNib() {
        // 選択しているものにチェックを付ける
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)

        }
    }

    @IBAction func ascendingOrder(_ sender: Any) {
        delegate?.sortDateAscendingOrder()
    }

    @IBAction func descendingOrder(_ sender: Any) {
        delegate?.sortDateDescendingOrder()
    }
}
