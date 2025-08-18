// HomeWorth/Services/SupabaseService.swift
import Foundation
import Supabase
import UIKit

// MARK: - Errors
enum SupabaseError: Error, LocalizedError {
    case generalError(description: String)
    case unauthorized
    case fileUploadFailed
    case fileDownloadFailed
    case userNotFound
    case decodingError(description: String)
    
    var errorDescription: String? {
        switch self {
        case .generalError(let description):
            return "An error occurred: \(description)"
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .fileUploadFailed:
            return "Failed to upload the image to storage."
        case .fileDownloadFailed:
            return "Failed to download the image from storage."
        case .userNotFound:
            return "User not found in the database."
        case .decodingError(let description):
            return "Failed to decode data: \(description)"
        }
    }
}

// MARK: - Supabase Service
class SupabaseService {
    static let shared = SupabaseService()
    
    private let supabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://tbypgreqkpruvuidczyq.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRieXBncmVxa3BydXZ1aWRjenlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MDI4NzEsImV4cCI6MjA3MDM3ODg3MX0.Ec6o-pG3fLFTQ7eW_pdOQObWinFsJUDA67qoUH0IyhA"
    )
    
    var currentUserId: UUID? {
        get async throws {
            return try await supabaseClient.auth.session.user.id
        }
    }
    
    // MARK: - Auth
    func signUp(email: String, password: String, name: String?, phoneNumber: String?, userType: String, profileImage: UIImage?, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                let authResponse = try await supabaseClient.auth.signUp(email: email, password: password)
                let user = authResponse.user
                
                var profilePhotoUrl: String? = nil
                
                if let image = profileImage {
                    let uniqueFileName = UUID().uuidString + ".jpeg"
                    let path = "profile-photos/\(user.id.uuidString)/\(uniqueFileName)"
                    
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        _ = try await supabaseClient.storage.from("profile-photos").upload(path, data: imageData)
                        profilePhotoUrl = try supabaseClient.storage.from("profile-photos").getPublicURL(path: path).absoluteString
                    }
                }
                
                let newUserProfile = User(
                    id: user.id,
                    email: user.email!,
                    name: name,
                    phoneNumber: phoneNumber,
                    userType: userType,
                    profilePhotoUrl: profilePhotoUrl,
                    createdAt: Date()
                )
                
                try await supabaseClient.from("users")
                    .insert(newUserProfile)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(.success(newUserProfile))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                let session = try await supabaseClient.auth.signIn(email: email, password: password)
                let user = session.user
                
                let fetchedUsers: [User] = try await supabaseClient.from("users")
                    .select()
                    .eq("id", value: user.id)
                    .execute()
                    .value
                
                guard let fetchedUser = fetchedUsers.first else {
                    throw SupabaseError.userNotFound
                }
                
                DispatchQueue.main.async {
                    completion(.success(fetchedUser))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await supabaseClient.auth.signOut()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - User Profiles
    func fetchCurrentUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                guard let currentUserId = try await self.currentUserId else {
                    throw SupabaseError.userNotFound
                }
                
                let fetchedUsers: [User] = try await supabaseClient.from("users")
                    .select()
                    .eq("id", value: currentUserId)
                    .single()
                    .execute()
                    .value
                
                guard let userProfile = fetchedUsers.first else {
                    throw SupabaseError.userNotFound
                }
                
                DispatchQueue.main.async {
                    completion(.success(userProfile))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchUserProfile(userId: UUID, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                let userProfiles: [User] = try await supabaseClient.from("users")
                    .select()
                    .eq("id", value: userId)
                    .execute()
                    .value
                
                guard let userProfile = userProfiles.first else {
                    throw SupabaseError.userNotFound
                }
                
                DispatchQueue.main.async {
                    completion(.success(userProfile))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateUserProfile(user: User, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                _ = try await supabaseClient.from("users")
                    .update([
                        "name": user.name,
                        "phone_number": user.phoneNumber,
                        "profile_photo_url": user.profilePhotoUrl
                    ])
                    .eq("id", value: user.id)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func deleteUser(userId: UUID, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                _ = try await supabaseClient.from("users")
                    .delete()
                    .eq("id", value: userId)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    func fetchAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
          Task {
              do {
                  let users: [User] = try await supabaseClient.from("users")
                      .select()
                      .execute()
                      .value
                  
                  DispatchQueue.main.async {
                      completion(.success(users))
                  }
              } catch {
                  DispatchQueue.main.async {
                      completion(.failure(error))
                  }
              }
          }
      }
    // MARK: - Properties
    func fetchProperties(completion: @escaping (Result<[Property], Error>) -> Void) {
        Task {
            do {
                let properties: [Property] = try await supabaseClient.from("properties")
                    .select()
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    completion(.success(properties))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchPropertiesBySeller(sellerId: UUID, completion: @escaping (Result<[Property], Error>) -> Void) {
        Task {
            do {
                let properties: [Property] = try await supabaseClient.from("properties")
                    .select()
                    .eq("seller_id", value: sellerId)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    completion(.success(properties))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createProperty(property: Property, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                _ = try await supabaseClient.from("properties")
                    .insert(property)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func updatePropertyStatus(propertyId: UUID, newStatus: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                _ = try await supabaseClient.from("properties")
                    .update(["status": newStatus])
                    .eq("id", value: propertyId)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Inquiries
    func createInquiry(inquiry: Inquiry, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                _ = try await supabaseClient.from("inquiries")
                    .insert(inquiry)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchInquiries(forPropertyId propertyId: UUID, completion: @escaping (Result<[Inquiry], Error>) -> Void) {
        Task {
            do {
                let inquiries: [Inquiry] = try await supabaseClient.from("inquiries")
                    .select()
                    .eq("property_id", value: propertyId)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    completion(.success(inquiries))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Storage
    func uploadImage(image: UIImage, to bucket: String, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    completion(.failure(SupabaseError.fileUploadFailed))
                }
                return
            }
            
            do {
                _ = try await supabaseClient.storage
                    .from(bucket)
                    .upload(path, data: data)
                
                let fileURL = try supabaseClient.storage
                    .from(bucket)
                    .getPublicURL(path: path)
                
                DispatchQueue.main.async {
                    completion(.success(fileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func uploadProfileImage(image: UIImage, userId: UUID, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    completion(.failure(SupabaseError.fileUploadFailed))
                }
                return
            }
            
            do {
                let uniqueFileName = UUID().uuidString + ".jpeg"
                let path = "profile-photos/\(userId.uuidString)/\(uniqueFileName)"
                
                _ = try await supabaseClient.storage
                    .from("profile-photos")
                    .upload(path, data: data)
                
                let fileURL = try supabaseClient.storage
                    .from("profile-photos")
                    .getPublicURL(path: path)
                
                DispatchQueue.main.async {
                    completion(.success(fileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
