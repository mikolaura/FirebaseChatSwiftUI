//
//  MainMessagesView.swift
//  FirebaseChatSiwftUI
//
//  Created by uran on 27.03.2023.
//

import SwiftUI
import SDWebImageSwiftUI


class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    init(){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil

        }
        
        fetchCurrentUser()
    }
    func fetchCurrentUser(){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find uid"
            return
            
        }
        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, err in
            if let err = err{
                print("Failed to fetch current user: ",err)
                return
            }
            
            
            guard let data = snapshot?.data() else{return}
//            print(data)
            self.chatUser = .init(data: data)            

        }
    }
    @Published var isUserCurrentlyLoggedOut = false
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainMessagesView: View {
    private var customNavigationBar: some View {
        HStack(spacing: 16){
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            //            Image(systemName: "person.fill")
            
            VStack(alignment: .leading, spacing: 4) {
                let username =  vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text("\(username)")
                    .font(.system(size: 24))
                HStack{
                    Circle().foregroundColor(.green)
                        .frame(width: 14,height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settigs"), message: Text("What do you want to do?"),buttons: [
                .destructive(Text("Sign Out"),action: {
                    print("Sign out")
                    vm.handleSignOut()
                }),
//                        .default(Text("Defa")),
                .cancel()
                                                                            ])
        }.fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
            ContentView {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            }
        }
    }
    @State var shouldShowLogOutOptions = false
    @ObservedObject var vm = MainMessagesViewModel()
    var body: some View {
        NavigationView{
            
            VStack{
//                Text("Current user id: \(vm.chatUser?.uid ?? "")")
                customNavigationBar
                messagesView
            }
            .overlay(newMessageButton ,alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    private var messagesView: some View {
        ScrollView{
            ForEach(0..<10, id: \.self ){num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size:32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1))
                        VStack(alignment: .leading){
                            Text("Username")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
    @State var shouldShowNewMessageScreen = false
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("+ New message")
                    .font(.system(size: 16, weight: .bold))
                    
                Spacer()
            }.foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(24)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView()
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        MainMessagesView()
    }
}

