//
//  TaskTableViewCell.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import UIKit
import RxSwift

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var completeCheckButton: CheckButton!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var scheduledDateLabel: UILabel!

    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUp(taskInfoItem: TaskInfoItem) {
        completeCheckButton.isChecked = taskInfoItem.isCompleted
        title.text = taskInfoItem.title
        contentLabel.text = taskInfoItem.content
        scheduledDateLabel.text = taskInfoItem.scheduledDate.dateFormat().dateJpFormat()
        favoriteButton.isFavorite = taskInfoItem.isFavorite
    }
}
