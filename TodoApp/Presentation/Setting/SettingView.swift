//
//  SettingView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/16.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModelImpl()
    @State private var email = ""
    @AppStorage("isSignIn") var isSignIn = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack {
                Image(R.image.person.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.top, 16)
                
                Text(email)
                    .fontWeight(.semibold)
                
                Button {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.signOut()
                            isSignIn = false
                            isLoading = false
                        } catch {
                            isLoading = false
                            print("エラー: \(error)")
                        }
                    }
                } label: {
                    Text("サインアウト")
                        .fontWeight(.semibold)
                        .frame(width: 220, height: 45)
                        .foregroundColor(Color(.white))
                        .background(Color(.accent))
                        .cornerRadius(24)
                }
                .padding()
                Spacer()
            }
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            do {
                email = try viewModel.loadEmail()
            } catch {
                
            }
        }
    }
}

#Preview {
    SettingView()
}
