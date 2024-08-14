//
//  UserDetailsView.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import SwiftUI
import SwiftData

struct UserDetailsView: View {
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @AppStorage("deviceToken") private var deviceToken = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var horoscopes: [Horoscope]
    
    @State private var isEditing = false
    @State private var editedUser: User?
    
    var user: User? {
        users.first
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account Information")) {
                    InfoRow(label: "Name", value: Binding(
                        get: { self.editedUser?.name ?? self.user?.name ?? "" },
                        set: { self.editedUser?.name = $0 }
                    ), isEditing: isEditing)
                    InfoRow(label: "Email", value: Binding(
                        get: { self.editedUser?.email ?? self.user?.email ?? "" },
                        set: { self.editedUser?.email = $0 }
                    ), isEditing: isEditing)
                    InfoRow(label: "Username", value: Binding(
                        get: { self.editedUser?.username ?? self.user?.username ?? "" },
                        set: { self.editedUser?.username = $0 }
                    ), isEditing: isEditing)
                }
                Section {
                    Button(action: {
                        logout()
                    }) {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .disabled(isEditing)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("User Details")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print(deviceToken)
                    }) {
                        Image(systemName: "ladybug.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if isEditing {
                            saveUserData()
                        } else {
                            startEditing()
                        }
                        isEditing.toggle()
                    }) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                    }
                    Button(isEditing ? "Done" : "Edit") {
                        if isEditing {
                            saveUserData()
                        } else {
                            startEditing()
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }
    
    private func startEditing() {
        editedUser = user?.copy()
    }
    
    private func saveUserData() {
        if let editedUser = editedUser, let user = user {
            user.name = editedUser.name
            user.email = editedUser.email
            user.username = editedUser.username
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving user data: \(error)")
            }
        }
        editedUser = nil
    }
    
    private func logout() {
        // Clear Horoscopes database
        for horoscope in horoscopes {
            modelContext.delete(horoscope)
        }
        
        // Clear user data
        if let user = user {
            modelContext.delete(user)
        }
        
        // Attempt to save changes
        do {
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
        
        // Set user as logged out
        isUserLoggedIn = false
    }
}

struct InfoRow: View {
    let label: String
    @Binding var value: String
    var isEditing: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            if isEditing {
                TextField(label, text: $value)
                    .multilineTextAlignment(.trailing)
            } else {
                Text(value)
            }
        }
    }
}

extension User {
    func copy() -> User {
        User(id: self.id, name: self.name, username: self.username, email: self.email)
    }
}


#Preview {
    UserDetailsView()
}
