//
//  ContentView.swift
//  FirebaseChatSiwftUI
//
//  Created by uran on 26.03.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct ContentView: View {
    let didCompleteLoginProcess: () -> ()
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var pasword = ""
    @State private var shouldShowImagePicker = false
    var body: some View {
        
        NavigationView{
            ScrollView{
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode, label:
                            Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                    if !isLoginMode{
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        
                                        .cornerRadius(64)
                                }
                                else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                            .stroke(Color.black, lineWidth: 3))
                        }
                    }
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Passoword", text: $pasword)
                            
                    }.padding(12)
                        .background(Color.white)
                    Button {
                        handleAction()
                        self.didCompleteLoginProcess()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log In" :  "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    Text(self.message)
                        .foregroundColor(.red)
                }.padding()
                    
            }.navigationTitle(isLoginMode ? "login" : "Create Account")
                .background(Color(.init(white: 0, alpha: 0.05))
                    .ignoresSafeArea())
                

                
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
        }
    }
    @State var image: UIImage?
    private func handleAction(){
        if isLoginMode{
            loginUser()
            print("Log in mode")
        }else{
            createNewAccount()
            print("Sign in mode")
        }
    }
    @State var message=""
    private func createNewAccount(){
        if self.image == nil {
            self.message = "You must selcent an avatar image"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: pasword) { result, error in
            if let err = error {
                print("failed to create user:", err)
                self.message = "failed to create user: \(err)"
                return
            }
            print("Successfully create user: \(result?.user.uid)")
            self.message = "Successfully create user: \(result?.user.uid)"
            self.persistImageToStorege()
        }
    }
    private func persistImageToStorege(){
//        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else{return}
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
        else{return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.message = "Failde to push image to Storage \(err)"
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    self.message = "Failde to retrive downloadURL \(err)"
                    return
                }
                self.message = "Successfully stored image with url : \(url?.absoluteString ?? "")"
                guard let url = url else{return}
                self.storeUserInfomration(imageProfile: url)
                
            }
        }
    }
    private func storeUserInfomration(imageProfile: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfile.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData( userData) { err in
                if let err = err {
                    print(err)
                    self.message = "\(err)"
                    return
                }
                print("Success")
                
                self.didCompleteLoginProcess()
            }
    }
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: pasword) { result, err in
            if let err = err {
                print("failed to login user:", err)
                self.message = "failed to login user: \(err)"
                return
            }
            print("Successfully logged in as user: \(result?.user.uid)")
            self.message = "Successfully logged in as user: \(result?.user.uid)"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView {
            
        }
    }
}
