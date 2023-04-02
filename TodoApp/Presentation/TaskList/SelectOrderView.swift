//
//  SelectOrderView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/04/02.
//

import Foundation
import UIKit

protocol SelectOrderViewDelegate: AnyObject {
    /// 日付の昇順
    func sortDateAscendingOrder()
    /// 日付の降順
    func sortDateDescendingOrder()
}

class SelectOrderView: UIView {

    weak var delegate: SelectOrderViewDelegate?

    @IBOutlet weak var ascendingCheckImage: UIImageView!
    @IBOutlet weak var descendingCheckImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    func setUp(sort: String) {
        if sort == Sort.ascendingOrderDate.rawValue {
            ascendingCheckImage.isHidden = false
            descendingCheckImage.isHidden = true
        } else {
            ascendingCheckImage.isHidden = true
            descendingCheckImage.isHidden = false
        }
    }

    private func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }

    @IBAction private func ascendingOrder(_ sender: Any) {
        delegate?.sortDateAscendingOrder()
    }
    
    @IBAction private func descendingOrder(_ sender: Any) {
        delegate?.sortDateDescendingOrder()
    }
}
