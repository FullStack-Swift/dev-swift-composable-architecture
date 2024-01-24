//
//  AuthView.swift
//  TheMovie
//
//  Created by PhongND on 1/30/24.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
      VStack {
        Text("Login to your account")
          .fontWeight(.bold)
          .alignment(horizontal: .leading)
        AuthMovieInput(label: "email")
          .onChangeText { text in
            log.info(text)
          }
          .alignment(horizontal: .leading)
        AuthMovieInput(label: "password")
          .onChangeText { text in
            log.info(text)
          }
          .alignment(horizontal: .leading)
      }
      .padding()
    }
}

#Preview {
    AuthView()
}

struct AuthMovieInput: HookView {
  
  var label: String? = nil
  
  var completion: MCompletion<String>? = nil
  
  var hookBody: some View {
    
      @HState var input = ""
      
      useLayoutEffect(.preserved(by: input)) {
        completion?(input)
      }
      
      return VStack {
        IfLet(label) { label in
          Text(label)
            .alignment(horizontal: .leading)
        }
        TextField("", text: $input)
          .frame(height: 48)
          .textFieldStyle(.roundedBorder)
      }
  }
  
  func onChangeText( _ completion: MCompletion<String>? = nil) -> Self {
    with { $0.completion = completion }
  }
}
