//
//  TaskTableViewCell.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var scheduledDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUp(taskInfoItem: TaskInfoItem) {
        title.text = taskInfoItem.title
        contentLabel.text = taskInfoItem.content + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaend"
        scheduledDateLabel.text = taskInfoItem.scheduledDate
    }

    
}
