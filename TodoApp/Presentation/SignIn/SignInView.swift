//
//  SignInView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/12.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModelImpl()
//    @State private var isPresented = false
    @AppStorage("isSignIn") var isSignIn = false
    
    var body: some View {
//        NavigationStack {
            Button {
                Task {
                    do {
                        try await viewModel.socialSigIn(provider: .google)
                        isSignIn = true
//                        isPresented = true
                    } catch {
                        
                    }
                }
            } label: {
                Text("GoogleSignIn")
            }
//            .navigationDestination(isPresented: $isPresented) {
//                 TaskListView()
//            }
    }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }

}

#Preview {
    SignInView()
}
