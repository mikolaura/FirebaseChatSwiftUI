//
//  CreateNewMessageView.swift
//  FirebaseChatSiwftUI
//
//  Created by uran on 28.03.2023.
//

import SwiftUI
import SDWebImageSwiftUI
class CreateNewMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init() {
        fetchAllUser()
    }
    private func fetchAllUser() {
        FirebaseManager.shared.firestore.collection("users")
            
            .getDocuments { docSnap, err in
                if let err = err {
                    self.errorMessage = "Failed to fetch users: \(err)"
                    print("Failed to fetch users: \(err)")
                    return
                }
                
                docSnap?.documents.forEach({snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid{
                        self.users.append(.init(data: data))
                    }
                })
//                self.errorMessage = "Fetched users  successfully"
            }
    }
}

struct CreateNewMessageView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { users in
                    Button {
                        
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: users.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50,height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label),lineWidth: 2))
                            Text(users.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                        Divider().padding(.vertical,8)
                    }

                    
                }
            }
            .navigationTitle("New message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    }label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView()

    }
}
