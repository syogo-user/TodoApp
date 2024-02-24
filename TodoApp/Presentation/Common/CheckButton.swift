//
//  CheckButton.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/02/24.
//
import SwiftUI

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
