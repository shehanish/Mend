//
//  ProfileView.swift
//  Mend
//
//  Created by Shehani Hansika on 07.05.26.
//


import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("profileImageData") var profileImageData: Data = Data()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var editName: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Avatar
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 2))
                                    .padding(.top, 40)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundStyle(Color.brandPrimary)
                                    .padding(.top, 40)
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    profileImageData = data
                                    if let uiImage = UIImage(data: data) {
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.headline)
                                .foregroundStyle(Color.textOnPrimary)
                            
                            TextField("Enter your name", text: $editName)
                                .textInputAutocapitalization(.words)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .environment(\.colorScheme, .light)
                        }
                        .padding(.horizontal, 30)
                        
                        Button(action: {
                            userName = editName
                            dismiss()
                        }) {
                            Text("Save Profile")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brandPrimary)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 50)
                        
                        Button(action: {
                            // Sign out logic
                            isLoggedIn = false
                            dismiss()
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
            }
            .onAppear {
                editName = userName
                if !profileImageData.isEmpty, let uiImage = UIImage(data: profileImageData) {
                    profileImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}