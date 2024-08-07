//
//  LoginSignupView.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import SwiftUI
import SwiftData

struct LoginSignupView: View {
    @Binding var isUserLoggedIn: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var name = ""
    @State private var isLoginMode = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isLoginMode ? "Login" : "Sign Up")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)

                    if !isLoginMode {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                        TextField("Name", text: $name)
                    }
                }

                Section {
                    Button(action: {
                        if isLoginMode {
                            loadSampleUser()
                        } else {
                            signUp()
                        }
                    }) {
                        Text(isLoginMode ? "Log In" : "Sign Up")
                    }
                }

                Section {
                    Button(action: {
                        isLoginMode.toggle()
                    }) {
                        Text(isLoginMode ? "Need an account? Sign Up" : "Already have an account? Log In")
                    }
                }
            }
            .navigationTitle(isLoginMode ? "Login" : "Sign Up")
        }
    }

    private func loadSampleUser() {
        guard let url = Bundle.main.url(forResource: "sample_user", withExtension: "json") else {
            print("Unable to find sample_user.json file")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let sampleUser = try decoder.decode(User.self, from: data)

            // Delete existing users
            let existingUsers = try modelContext.fetch(FetchDescriptor<User>())
            for user in existingUsers {
                modelContext.delete(user)
            }

            // Insert the sample user
            modelContext.insert(sampleUser)

            try modelContext.save()
            isUserLoggedIn = true
        } catch {
            print("Error loading or decoding JSON: \(error)")
        }
    }

    private func signUp() {
        let newUser = User(id: Int.random(in: 1...1000000),
                           name: name,
                           username: username,
                           email: email)
        modelContext.insert(newUser)

        do {
            try modelContext.save()
            isUserLoggedIn = true
        } catch {
            print("Error saving new user: \(error)")
        }
    }
}

