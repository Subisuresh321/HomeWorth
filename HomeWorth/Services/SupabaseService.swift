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
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRieXBncmVxa3BydXZ1aWRjenlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MDI4NzEsImV4cCI6MjA3MDM3ODg3MX0.Ec6o-pG3fLFTQ7eW_pdOQObWinFsJUDA67qoUH0IyhA" // Your key here
    )
    
    var currentUserId: UUID? {
            get async throws {
                // Fixed: session is async and can throw, so we need async throws
                return try await supabaseClient.auth.session.user.id
            }
        }
        
    
    // MARK: - Auth
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                let authResponse = try await supabaseClient.auth.signUp(email: email, password: password)
                
                let user = authResponse.user
                
                // Fixed: Corrected parameter order - name must precede userType
                let newUserProfile = User(id: user.id, email: user.email!, name: nil,phoneNumber: nil, userType: "buyer", createdAt: Date())
                
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
                
                // Corrected: user.id is a non-optional UUID. No need to force unwrap.
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
                    // Fixed: Pass the error directly instead of wrapping in .failure
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Storage
    func uploadImage(image: UIImage, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    completion(.failure(SupabaseError.fileUploadFailed))
                }
                return
            }
            
            do {
                // Fixed: Removed extraneous 'path:' label
                _ = try await supabaseClient.storage
                    .from("property-images")
                    .upload(path, data: data)
                
                let fileURL = try supabaseClient.storage
                    .from("property-images")
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

