//
//  LoginTab.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/08.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var showingAlert = false
    @State var alertText = ""
    @State private var ECS_ID: String = ""
    @State private var Password: String = ""
    
    @State private var isLoading = false
    @State private var isLoadingMsg = "ログイン中..."
    
    var body: some View {
        if isLoading {
            ProgressView(isLoadingMsg)
                .scaleEffect(1.5, anchor: .center)
        }else{
            VStack(alignment: .center) {
                Text("PandA Login")
                    .font(.system(size: 48, weight: .heavy))
                
                VStack(spacing: 12) {
                    TextField("ECS_ID", text: $ECS_ID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .frame(width: 280)
                    SecureField("Password", text: $Password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 280)
                }
                .frame(height: 150)
                
                Button(action: {
                    self.isLoading = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        UIApplication.shared.endEditing()
                        if ECS_ID == "" || Password == "" {
                            self.showingAlert = true
                            self.alertText = ErrorMsg.EmptyIDAndPass.rawValue
                        }else{
                            self.showingAlert = true
                            let loginRes: LoginStatus
                            
                            _ = saveKeychain(account: "ECS_ID", value: ECS_ID)
                            _ = saveKeychain(account: "Password", value: Password)
                            
                            if ECS_ID == "apple" && Password == "apple" {
                                loginRes = LoginStatus(success: true)
                                Saver.shared.setDemoFlag(demo: true)
                            } else {
                                SakaiAPI.shared.logout()
                                loginRes = SakaiAPI.shared.login()
                                Saver.shared.setDemoFlag(demo: false)
                            }
                            
                            
                            if loginRes.success {
                                self.alertText = "ECS_ID, パスワードを保存しました。"
                                self.mode.wrappedValue.dismiss()
                            }else{
                                if loginRes.error == Login.Network {
                                    self.alertText = ErrorMsg.FailedToGetResponse.rawValue
                                }else{
                                    self.alertText = loginRes.errorMsg
                                }
                            }
                        }
                        self.isLoading = false
                    }
                    
                },
                label: {
                    Text("ログイン")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                })
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("\(alertText)"))
                }
                Spacer()
                    .onTapGesture {
                        endEditing()
                    }
            }
            .onTapGesture {
                endEditing()
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
func endEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
