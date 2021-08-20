//
//  ListTableViewCell.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ task:Task) {
        self.titleLabel.text = task.title
        self.contentLabel.text = task.content
        self.dateLabel.text = task.date.dateJpFormat()
    }
}
