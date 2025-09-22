// HomeWorth/Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isFilterExpanded = false
    @State private var searchText = ""
    @State private var animateBackground = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simplified background - removed heavy animations
                GeometryReader { geometry in
                    ZStack {
                        // Static gradient background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.homeWorthGradientStart,
                                Color.homeWorthGradientEnd,
                                Color.homeWorthYellow.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        // Light grid overlay - no animation
                        SimpleGrid()
                            .opacity(0.05)
                    }
                }
                
                VStack(spacing: 0) {
                    // Simplified header
                    VStack(spacing: 20) {
                        // Title - removed house icon animation
                        HStack {
                            Text("HomeWorth")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.deepBlack)
                                .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                            
                            Image(systemName: "house.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.deepBlack)
                        }
                        .padding(.top, 10)
                        
                        // Static search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.deepBlack.opacity(0.7))
                                .font(.system(size: 20, weight: .medium))
                            
                            TextField("Search premium properties...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.deepBlack)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                                )
                        )
                        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
                        .padding(.horizontal, 20)
                        
                        // Simplified filter section
                        VStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isFilterExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Advanced Filters")
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                    Image(systemName: isFilterExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.deepBlack)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .shadow(color: .deepBlack.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                            
                            if isFilterExpanded {
                                OptimizedFiltersView(viewModel: viewModel)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Simplified content area
                    Group {
                        if viewModel.isLoading {
                            SimpleLoadingView()
                        } else if let errorMessage = viewModel.errorMessage {
                            SimpleErrorView(message: errorMessage)
                        } else if viewModel.properties.isEmpty {
                            SimpleEmptyView()
                        } else {
                            // Optimized property list
                            List(viewModel.properties.indices, id: \.self) { index in
                                NavigationLink(destination: PropertyDetailView(property: viewModel.properties[index])) {
                                    OptimizedPropertyCard(
                                        property: viewModel.properties[index]
                                    )
                                    .padding(.vertical, 8)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchProperties()
            }
            .refreshable {
                viewModel.fetchProperties()
            }
        }
    }
}

// MARK: - Optimized Components (Minimal Animations)



struct OptimizedFiltersView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                SimpleFilterField(
                    title: "Min Price",
                    placeholder: "₹0",
                    text: $viewModel.minPrice,
                    onChange: { viewModel.applyFiltersAndSorting() }
                )
                
                SimpleFilterField(
                    title: "Max Price",
                    placeholder: "₹∞",
                    text: $viewModel.maxPrice,
                    onChange: { viewModel.applyFiltersAndSorting() }
                )
            }
            
            // Static sort menu
            Menu {
                Picker("Sort by", selection: $viewModel.selectedSortOption) {
                    ForEach(HomeViewModel.SortOption.allCases) { option in
                        Label(option.rawValue, systemImage: getSortIcon(for: option))
                            .tag(option)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.deepBlack)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sort By")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        Text(viewModel.selectedSortOption.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.deepBlack)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.homeWorthYellow.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                )
            }
            .onChange(of: viewModel.selectedSortOption) {
                viewModel.applyFiltersAndSorting()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: .deepBlack.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
    
    private func getSortIcon(for option: HomeViewModel.SortOption) -> String {
        switch option {
        case .priceAscending: return "arrow.up.circle"
        case .priceDescending: return "arrow.down.circle"
        case .areaAscending: return "square.resize.up"
        case .areaDescending: return "square.resize.down"
        }
    }
}

struct SimpleFilterField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let onChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.7))
            
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.deepBlack)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                        )
                )
                .tint(.homeWorthYellow)
                .onChange(of: text) { _ in
                    onChange()
                }
        }
    }
}

struct SimpleLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Simple rotating circle
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.deepBlack, lineWidth: 4)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            Text("Loading properties...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SimpleErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("ERROR")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.deepBlack)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SimpleEmptyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.fill")
                .font(.system(size: 70))
                .foregroundColor(.deepBlack.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("NO PROPERTIES FOUND")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.deepBlack)
                
                Text("Adjust your search criteria or check back later.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.deepBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Optimized Property Card (Essential Animations Only)

struct OptimizedPropertyCard: View {
    let property: Property
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack {
                if let imageUrlString = property.imageUrls?.first, let url = URL(string: imageUrlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } placeholder: {
                        ZStack {
                            Rectangle()
                                .fill(Color.homeWorthLightGray)
                                .frame(height: 200)
                            
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.homeWorthYellow)
                        }
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.homeWorthLightGray)
                            .frame(height: 200)
                        
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.5))
                    }
                }
                
                // Simple gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                // Static price badge (no pulsing)
                VStack {
                    HStack {
                        Spacer()
                        if let askingPrice = property.askingPrice {
                            StaticPriceBadge(price: askingPrice)
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .cornerRadius(20, corners: [.topLeft, .topRight])
            
            // Content section
            VStack(alignment: .leading, spacing: 16) {
                // Area info with static icon
                HStack(spacing: 12) {
                    Image(systemName: "square.resize")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.deepBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("\(Int(property.area)) sq ft")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.homeWorthDarkGray)
                    
                    Spacer()
                    
                    // Static status indicator
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
                
                // Room details
                HStack(spacing: 20) {
                    HStack(spacing: 8) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack)
                        Text("\(property.bedrooms)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.homeWorthDarkGray)
                        Text("Beds")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.7))
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "toilet.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack)
                        Text("\(property.bathrooms)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.homeWorthDarkGray)
                        Text("Baths")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                // Static AI price analysis
                if let predictedPrice = property.predictedPrice,
                   let askingPrice = property.askingPrice {
                    StaticAIAnalysis(
                        predictedPrice: predictedPrice,
                        askingPrice: askingPrice
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}

struct StaticPriceBadge: View {
    let price: Double
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    var body: some View {
        Text(formatPrice(price))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.deepBlack)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.homeWorthYellow)
                    .shadow(color: .homeWorthYellow.opacity(0.4), radius: 6, x: 0, y: 4)
            )
    }
}

struct StaticAIAnalysis: View {
    let predictedPrice: Double
    let askingPrice: Double
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    private var percentage: Double {
        ((askingPrice - predictedPrice) / predictedPrice) * 100
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // AI Predicted Price
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                    Text("AI Predicted")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.7))
                }
                
                Text(formatPrice(predictedPrice))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Static percentage indicator
            StaticPercentageIndicator(percentage: percentage)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .blue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct StaticPercentageIndicator: View {
    let percentage: Double
    
    private var arrowIcon: String {
        if percentage > 10 { return "arrow.up.circle.fill" }
        else if percentage < -10 { return "arrow.down.circle.fill" }
        else { return "equal.circle.fill" }
    }
    
    private var indicatorColor: Color {
        if percentage > 10 { return .red }
        else if percentage < -10 { return .green }
        else { return .orange }
    }
    
    private var statusText: String {
        if percentage > 10 { return "OVERPRICED" }
        else if percentage < -10 { return "GOOD DEAL" }
        else { return "FAIR PRICE" }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: arrowIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(indicatorColor)
                
                Text(String(format: "%.0f%%", abs(percentage)))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(indicatorColor)
            }
            
            Text(statusText)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(indicatorColor)
        }
    }
}

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
