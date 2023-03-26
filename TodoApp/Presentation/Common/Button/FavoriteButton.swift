//
//  FavoriteButton.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/26.
//

import UIKit

class FavoriteButton: UIButton {
    let favoriteImage = UIImage(named:"icon_check_on")! as UIImage
    let unfavoriteImage = UIImage(named:"icon_check_off")! as UIImage

    var isFavorite : Bool = false{
        didSet{
            if isFavorite == true {
                self.setImage(favoriteImage,for:UIControl.State.normal)
            }else{
                self.setImage(unfavoriteImage,for:UIControl.State.normal)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(tapFavorite(sender:)), for: UIControl.Event.touchUpInside)
        self.isFavorite = false
    }

    @objc func tapFavorite(sender:UIButton){
        if sender == self{
            isFavorite = !isFavorite
        }
    }
}

