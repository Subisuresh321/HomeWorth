// HomeWorth/Views/AdminDashboardView.swift
import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var propertyViewModel = AdminDashboardViewModel()

    var body: some View {
        TabView {
            // Properties Management Tab
            VStack {
                Picker("Filter", selection: $propertyViewModel.selectedFilter) {
                    Text("Pending").tag("pending")
                    Text("Approved").tag("approved")
                    Text("Rejected").tag("rejected")
                    Text("All").tag("all")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: propertyViewModel.selectedFilter) {
                    propertyViewModel.applyFilter()
                }

                List {
                    if propertyViewModel.isLoading {
                        ProgressView("Loading properties...")
                    } else if let errorMessage = propertyViewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if propertyViewModel.pendingProperties.isEmpty {
                        Text("No properties available for this filter.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(propertyViewModel.pendingProperties) { property in
                            AdminPropertyCardView(
                                property: property,
                                onApprove: { propertyId in
                                    propertyViewModel.approveProperty(propertyId: propertyId)
                                },
                                onReject: { propertyId in
                                    propertyViewModel.rejectProperty(propertyId: propertyId)
                                }
                            )
                        }
                    }
                }
            }
            .tabItem { Label("Properties", systemImage: "list.bullet.rectangle.fill") }

            // User Management Tab
            UserManagementView()
                .tabItem { Label("Users", systemImage: "person.3.fill") }
        }
        .navigationTitle("Admin Dashboard")
        .onAppear {
            propertyViewModel.fetchProperties()
        }
    }
}
