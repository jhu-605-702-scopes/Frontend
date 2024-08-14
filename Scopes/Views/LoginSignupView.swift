//
//  LoginSignupView.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import SwiftUI
import SwiftData
import Pow

struct LoginSignupView: View {
    @Binding var isUserLoggedIn: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var name = ""
    @State private var isLoginMode = true
    @State private var isLoading = false
    @State private var loginAttempts = 0
    @State private var isError = false

    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !username.isEmpty && !name.isEmpty
        }
    }

    
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
                .disabled(isLoading)

                Section {
                    Button(action: {
                        if isLoginMode {
                            Task {
                                await logIn()
                            }
                        } else {
                            Task {
                                await signUp()
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isError ? Color.red : !isFormValid ? Color.gray : Color.indigo)
                    .cornerRadius(10)
                }
                .disabled(!isFormValid || isLoading)
                .changeEffect(.shake(rate: .fast), value: loginAttempts)
                .listRowInsets(EdgeInsets())


                Section {
                    Button(action: {
                        isLoginMode.toggle()
                    }) {
                        Text(isLoginMode ? "Need an account? Sign Up" : "Already have an account? Log In")
                    }
                }
                .disabled(isLoading)

            }
            .navigationTitle("Scopes")
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
    
    private func logIn() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let logInResponse = try await Requests.shared.logIn(email: email, password: password)
            let user = User(from: logInResponse)
            modelContext.insert(user)
            try modelContext.save()
            isUserLoggedIn = true
        } catch let scopesError as ScopesError {
            print("Log in error: \(scopesError.message)")
        } catch {
            fatalError("Unexpected login error: \(error)")
        }

    }

    private func signUp() async {
        isLoading.toggle()
        defer { isLoading = false }
        
        do {
            let signUpResponse = try await Requests.shared.signUp(name: name, username: username, email: email, password: password)
            let user = User(from: signUpResponse)
            modelContext.insert(user)
            try modelContext.save()
            
            isUserLoggedIn = true
        } catch let scopesError as ScopesError {
            print("Sign up error: \(scopesError.message)")
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }
}

struct LogInSignUpResponse: Codable {
    let user: User
}

struct UserJSON: Codable {
    let name: String?
    let username: String?
    let email: String
    let password: String
    let userId: String?
}

struct LogInData: Codable {
    let email: String
    let password: String
}

extension Requests {
    func signUp(name: String, username: String, email: String, password: String) async throws -> UserJSON {
        let signUpData = UserJSON(name: name, username: username, email: email, password: password, userId: nil)
        let response: APIResponse = try await post("/users", body: signUpData)
        return response.body
    }
    
    func logIn(email: String, password: String) async throws -> UserJSON {
        let logInData = UserJSON(name: nil, username: nil, email: email, password: password, userId: nil)
        let response: APIResponse = try await post("/login", body: logInData)
        return response.body
    }
}

