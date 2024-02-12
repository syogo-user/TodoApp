//
//  CheckButton.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/21.
//

//import UIKit
import SwiftUI
//
//class CheckButton: UIButton {
//    let checkedImage = UIImage(named:"icon_check_on")! as UIImage
//    let uncheckedImage = UIImage(named:"icon_check_off")! as UIImage
//
//    var isChecked : Bool = false{
//        didSet{
//            if isChecked == true {
//                self.setImage(checkedImage,for:UIControl.State.normal)
//            }else{
//                self.setImage(uncheckedImage,for:UIControl.State.normal)
//            }
//        }
//    }
//
//    override func awakeFromNib() {
//        self.addTarget(self, action: #selector(tapCheck(sender:)), for: UIControl.Event.touchUpInside)
//        self.isChecked = false
//    }
//
//    @objc func tapCheck(sender:UIButton){
//        if sender == self {
//            isChecked = !isChecked
//        }
//    }
//}



struct CheckBoxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
            .foregroundStyle(configuration.isOn ? Color.accentColor : Color.primary)
            .buttonStyle(.plain)
            
            configuration.label
        }
    }
}

extension ToggleStyle where Self == CheckBoxStyle {
    static var checkBox: CheckBoxStyle {
        .init()
    }
}
