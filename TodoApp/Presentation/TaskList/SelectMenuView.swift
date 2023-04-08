//
//  SelectMenuView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/26.
//

import UIKit

protocol SelectMenuViewDelegate: AnyObject {
    /// お気に入りのみ表示
    func didFilterFavorite()
    /// 完了済も表示
    func includeCompleted()
    /// 完了済は表示しない
    func notIncludeCompleted()
}

class SelectMenuView: UIView {
    weak var delegate: SelectMenuViewDelegate?

    @IBOutlet private weak var onlyFavoriteCheckImage: UIImageView!
    @IBOutlet private weak var includeCompletedCheckImage: UIImageView!
    @IBOutlet private weak var notIncludeCompletedCheckImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    func setUp(filterCondition: String) {
        switch filterCondition {
        case FilterCondition.onlyFavorite.rawValue:
            onlyFavoriteCheckImage.isHidden = false
            includeCompletedCheckImage.isHidden = true
            notIncludeCompletedCheckImage.isHidden = true
        case FilterCondition.includeCompleted.rawValue:
            onlyFavoriteCheckImage.isHidden = true
            includeCompletedCheckImage.isHidden = false
            notIncludeCompletedCheckImage.isHidden = true
        case FilterCondition.notIncludeCompleted.rawValue:
            onlyFavoriteCheckImage.isHidden = true
            includeCompletedCheckImage.isHidden = true
            notIncludeCompletedCheckImage.isHidden = false
        default:
            onlyFavoriteCheckImage.isHidden = true
            includeCompletedCheckImage.isHidden = true
            notIncludeCompletedCheckImage.isHidden = false
        }

    }

    private func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }


    @IBAction private func filterFavorite(_ sender: Any) {
        delegate?.didFilterFavorite()
    }

    @IBAction private func showCompletee(_ sender: Any) {
        delegate?.includeCompleted()
    }

    @IBAction private func sort(_ sender: Any) {
        delegate?.notIncludeCompleted()
    }
}
