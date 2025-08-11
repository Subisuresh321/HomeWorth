// HomeWorth/App/ContentView.swift
import SwiftUI
import Supabase
import UIKit

// TestItem model for Firestore
struct TestItem: Codable, Identifiable {
    var id: UUID?
    var name: String
    var userId: UUID
}

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @State private var testItemName = ""
    @State private var fetchedItems: [Property] = []
    
    // Fixed: Remove synchronous initialization since currentUserId is now async
    @State private var userId: UUID? = nil

    // Storage Test properties
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var uploadedImageURL: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: Authentication UI
                    Text("Authentication Test (Supabase)")
                        .font(.title2)
                        .padding(.top)
                    
                    VStack(spacing: 10) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Button("Sign Up") {
                                SupabaseService.shared.signUp(email: email, password: password) { result in
                                    switch result {
                                    case .success(let user):
                                        self.message = "Signed up successfully! User ID: \(user.id)"
                                        self.userId = user.id
                                    case .failure(let error):
                                        self.message = "Sign up failed: \(error.localizedDescription)"
                                    }
                                }
                            }
                            .foregroundColor(.red)
                            .buttonStyle(.borderedProminent)

                            Button("Sign In") {
                                SupabaseService.shared.signIn(email: email, password: password) { result in
                                    switch result {
                                    case .success(let user):
                                        self.message = "Signed in successfully! User ID: \(user.id)"
                                        self.userId = user.id
                                    case .failure(let error):
                                        self.message = "Sign in failed: \(error.localizedDescription)"
                                    }
                                }
                            }
                            .foregroundColor(.red)
                            .buttonStyle(.borderedProminent)
                        }

                        Button("Sign Out") {
                            SupabaseService.shared.signOut { error in
                                if let error = error {
                                    self.message = "Sign out failed: \(error.localizedDescription)"
                                } else {
                                    self.message = "Signed out successfully."
                                    self.userId = nil
                                }
                            }
                        }
                        .foregroundColor(.red)
                        .buttonStyle(.borderedProminent)
                        
                        Button("Check Current User") {
                            Task {
                                do {
                                    let currentUserId = try await SupabaseService.shared.currentUserId
                                    await MainActor.run {
                                        self.userId = currentUserId
                                        self.message = "Current User ID: \(currentUserId?.uuidString ?? "None")"
                                    }
                                } catch {
                                    await MainActor.run {
                                        self.message = "Failed to get current user: \(error.localizedDescription)"
                                        self.userId = nil
                                    }
                                }
                            }
                        }
                        .foregroundColor(.red)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Text("Current User ID: \(userId?.uuidString ?? "None")")
                        .padding(.top)
                        .font(.caption)

                    // MARK: Database Test
                    Divider()
                        .padding(.horizontal)
                    
                    Text("Database & Storage Test")
                        .font(.title2)
                    
                    VStack(spacing: 10) {
                        Button("Add Test Property") {
                            guard let userId = userId else {
                                self.message = "Please sign in to add a property."
                                return
                            }
                            
                            let newProperty = Property(
                                sellerId: userId,
                                area: 1500, bedrooms: 3, bathrooms: 2, balconies: 1, builtYear: 2025,
                                numberOfFloors: 2, atmDistance: 0.5, hospitalDistance: 1.2, schoolDistance: 0.8,
                                woodQuality: 2, cementGrade: 53, steelGrade: 1, brickType: 0,
                                flooringQuality: 1, paintQuality: 2, plumbingQuality: 1,
                                electricalQuality: 2, roofingType: 1, windowGlassQuality: 1,
                                areaType: 4, askingPrice: 4500000,
                                imageUrls: uploadedImageURL != nil ? [uploadedImageURL!] : nil, // Use uploaded image URL
                                status: "pending",
                                createdAt: Date()
                            )

                            SupabaseService.shared.createProperty(property: newProperty) { error in
                                if let error = error {
                                    self.message = "Property creation failed: \(error.localizedDescription)"
                                } else {
                                    self.message = "Property added successfully!"
                                }
                            }
                        }
                        .foregroundColor(.red)
                        .buttonStyle(.borderedProminent)
                        
                        Button("Fetch All Properties") {
                            SupabaseService.shared.fetchProperties { result in
                                switch result {
                                case .success(let items):
                                    self.fetchedItems = items
                                    self.message = "Fetched \(items.count) properties."
                                case .failure(let error):
                                    self.message = "Fetch failed: \(error.localizedDescription)"
                                }
                            }
                        }
                        .foregroundColor(.red)
                        .buttonStyle(.borderedProminent)
                        
                        // MARK: Storage Test UI
                        Button("Upload Image") {
                            isShowingImagePicker = true
                        }
                        .foregroundColor(.red)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    // Display fetched items
                    if !fetchedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Properties:")
                                .font(.headline)
                                .padding(.top)
                            
                            ForEach(fetchedItems, id: \.id) { item in
                                Text("Property ID: \(item.id?.uuidString ?? "N/A") - Asking Price: \(item.askingPrice ?? 0)")
                                    .font(.caption)
                                    .padding(.vertical, 2)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if let uploadedImageURL = uploadedImageURL {
                        VStack(spacing: 10) {
                            Text("Image uploaded successfully!")
                                .foregroundColor(.green)
                                .font(.headline)
                            
                            // Display the image from the URL.
                            AsyncImage(url: URL(string: uploadedImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 150, height: 150)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }

                    Text(message)
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.caption)
                }
                .padding()
            }
            .navigationTitle("Supabase Testbed")
            .task {
                // Fixed: Use .task to handle async operations on view appear
                do {
                    self.userId = try await SupabaseService.shared.currentUserId
                } catch {
                    self.message = "Failed to get current user on startup: \(error.localizedDescription)"
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if let image = selectedImage {
                            uploadImage(image)
                        }
                    }
            }
        }
    }
    
    // MARK: Helper function for image upload
    func uploadImage(_ image: UIImage) {
        guard let userId = userId else {
            self.message = "Please sign in to upload an image."
            return
        }
        let path = "test_images/\(userId)/\(UUID().uuidString).jpg"
        
        SupabaseService.shared.uploadImage(image: image, path: path) { result in
            switch result {
            case .success(let url):
                self.message = "Image upload successful! URL: \(url)"
                self.uploadedImageURL = url.absoluteString
            case .failure(let error):
                self.message = "Image upload failed: \(error.localizedDescription)"
            }
        }
    }
}
