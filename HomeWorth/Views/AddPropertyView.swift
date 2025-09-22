// HomeWorth/Views/AddPropertyView.swift
import SwiftUI

struct AddPropertyView: View {
    @StateObject private var viewModel = AddPropertyViewModel()
    @State private var showingImagePicker = false
    @State private var acceptDetails = false
    @State private var isLoading = false  // LOCAL LOADING STATE
    
    var body: some View {
        ZStack {
            // Futuristic background gradient
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
            
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        Text("ADD NEW PROPERTY")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.deepBlack)
                            .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                            .padding(.top, 20)
                        
                        // Property Details Section
                        AddPropertyDetailsCard(viewModel: viewModel)
                        
                        // Distance Details Section
                        AddDistanceDetailsCard(viewModel: viewModel)
                        
                        // Construction Quality Section
                        AddConstructionQualityCard(viewModel: viewModel)
                        
                        // Description Section
                        AddPropertyDescriptionCard(viewModel: viewModel)
                        
                        // Images Section
                        AddPropertyImagesCard(
                            selectedImages: viewModel.selectedImages,
                            onSelectImages: { showingImagePicker = true }
                        )
                        
                        // AI Prediction Section
                        AddAIPredictionCard(viewModel: viewModel)
                        
                        // Save Section - FIXED WITH LOCAL LOADING
                        AddSavePropertyCard(
                            acceptDetails: $acceptDetails,
                            isLoading: $isLoading,
                            message: viewModel.message,
                            onSave: {
                                isLoading = true
                                Task {
                                    await viewModel.savePropertyToSupabase()
                                    DispatchQueue.main.async {
                                        isLoading = false
                                    }
                                }
                            }
                        )
                        
                        // Bottom spacing
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $viewModel.selectedImages)
        }
    }
}

// MARK: - Add Property Components

struct AddPropertyDetailsCard: View {
    @ObservedObject var viewModel: AddPropertyViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PROPERTY DETAILS")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    AddPropertyInputField(
                        title: "AREA (SQ FT)",
                        text: $viewModel.totalarea,
                        keyboardType: .decimalPad
                    )
                    
                    AddPropertyInputField(
                        title: "BEDROOMS",
                        text: $viewModel.bedrooms,
                        keyboardType: .numberPad
                    )
                }
                
                HStack(spacing: 12) {
                    AddPropertyInputField(
                        title: "BATHROOMS",
                        text: $viewModel.bathrooms,
                        keyboardType: .numberPad
                    )
                    
                    AddPropertyInputField(
                        title: "BALCONIES",
                        text: $viewModel.balconies,
                        keyboardType: .numberPad
                    )
                }
                
                HStack(spacing: 12) {
                    AddPropertyInputField(
                        title: "BUILT YEAR",
                        text: $viewModel.builtYear,
                        keyboardType: .numberPad
                    )
                    
                    AddPropertyInputField(
                        title: "FLOORS",
                        text: $viewModel.numberOfFloors,
                        keyboardType: .numberPad
                    )
                }
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct AddDistanceDetailsCard: View {
    @ObservedObject var viewModel: AddPropertyViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("NEARBY AMENITIES (KM)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(spacing: 16) {
                AddPropertyInputField(
                    title: "ATM DISTANCE",
                    text: $viewModel.atmDistance,
                    keyboardType: .decimalPad
                )
                
                AddPropertyInputField(
                    title: "HOSPITAL DISTANCE",
                    text: $viewModel.hospitalDistance,
                    keyboardType: .decimalPad
                )
                
                AddPropertyInputField(
                    title: "SCHOOL DISTANCE",
                    text: $viewModel.schoolDistance,
                    keyboardType: .decimalPad
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct AddConstructionQualityCard: View {
    @ObservedObject var viewModel: AddPropertyViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CONSTRUCTION QUALITY")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(spacing: 16) {
                // FIXED: Removed generic pickers, using direct Picker implementation
                HStack(spacing: 12) {
                    QualityPickerSection(
                        title: "WOOD QUALITY",
                        selection: $viewModel.woodQuality,
                        cases: WoodQuality.allCases
                    )
                    
                    QualityPickerSection(
                        title: "CEMENT GRADE",
                        selection: $viewModel.cementGrade,
                        cases: CementGrade.allCases
                    )
                }
                
                HStack(spacing: 12) {
                    QualityPickerSection(
                        title: "STEEL GRADE",
                        selection: $viewModel.steelGrade,
                        cases: SteelGrade.allCases
                    )
                    
                    QualityPickerSection(
                        title: "BRICK TYPE",
                        selection: $viewModel.brickType,
                        cases: BrickType.allCases
                    )
                }
                
                HStack(spacing: 12) {
                    QualityPickerSection(
                        title: "FLOORING",
                        selection: $viewModel.flooringQuality,
                        cases: FlooringQuality.allCases
                    )
                    
                    QualityPickerSection(
                        title: "PAINT QUALITY",
                        selection: $viewModel.paintQuality,
                        cases: PaintQuality.allCases
                    )
                }
                
                HStack(spacing: 12) {
                    QualityPickerSection(
                        title: "PLUMBING",
                        selection: $viewModel.plumbingQuality,
                        cases: PlumbingQuality.allCases
                    )
                    
                    QualityPickerSection(
                        title: "ELECTRICAL",
                        selection: $viewModel.electricalQuality,
                        cases: ElectricalQuality.allCases
                    )
                }
                
                HStack(spacing: 12) {
                    QualityPickerSection(
                        title: "ROOFING",
                        selection: $viewModel.roofingType,
                        cases: RoofingType.allCases
                    )
                    
                    QualityPickerSection(
                        title: "WINDOW GLASS",
                        selection: $viewModel.windowGlassQuality,
                        cases: WindowGlassQuality.allCases
                    )
                }
                
                // Area type picker (full width)
                QualityPickerSection(
                    title: "AREA TYPE",
                    selection: $viewModel.areaType,
                    cases: AreaType.allCases
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct AddPropertyDescriptionCard: View {
    @ObservedObject var viewModel: AddPropertyViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DESCRIPTION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            TextEditor(text: $viewModel.propertyDescription)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.deepBlack)
                .frame(height: 120)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                        )
                )
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct AddPropertyImagesCard: View {
    let selectedImages: [UIImage]
    let onSelectImages: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROPERTY IMAGES")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Button(action: onSelectImages) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("SELECT IMAGES")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.deepBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.homeWorthYellow.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.deepBlack, lineWidth: 1)
                        )
                )
                .shadow(color: .homeWorthYellow.opacity(0.4), radius: 6, x: 0, y: 3)
            }
            
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                )
                                .shadow(color: .deepBlack.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 4)
                }
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct AddAIPredictionCard: View {
    @ObservedObject var viewModel: AddPropertyViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI PRICE PREDICTION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Button(action: { viewModel.makePrediction() }) {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("GET AI PREDICTION")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.deepBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.deepBlack, lineWidth: 1)
                        )
                )
                .shadow(color: .blue.opacity(0.4), radius: 6, x: 0, y: 3)
            }
            
            Text("Predicted Fair Price: \(viewModel.formattedPrice)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(viewModel.predictedPrice != nil ? .blue : .secondary)
            
            AddPropertyInputField(
                title: "YOUR ASKING PRICE (₹)",
                text: $viewModel.askingPrice,
                keyboardType: .decimalPad
            )
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct AddSavePropertyCard: View {
    @Binding var acceptDetails: Bool
    @Binding var isLoading: Bool  // FIXED: Use binding to local loading state
    let message: String
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONFIRMATION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Toggle("I have verified the details and they are true to my knowledge.", isOn: $acceptDetails)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack)
                .tint(.green)
            
            Button(action: onSave) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.deepBlack)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Text(isLoading ? "SAVING..." : "SAVE PROPERTY")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.deepBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(acceptDetails ? Color.homeWorthYellow : Color.gray.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.deepBlack, lineWidth: acceptDetails ? 2 : 1)
                        )
                )
                .shadow(
                    color: acceptDetails ? .homeWorthYellow.opacity(0.4) : .clear,
                    radius: 6,
                    x: 0,
                    y: 3
                )
            }
            .disabled(!acceptDetails || isLoading)
            
            if !message.isEmpty {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(message.contains("successfully") ? .green : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(message.contains("successfully") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        message.contains("successfully") ? Color.green.opacity(0.3) : Color.red.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Fixed Reusable Input Components

struct AddPropertyInputField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.deepBlack.opacity(0.7))
            
            TextField("Enter \(title.lowercased())", text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack)
                .keyboardType(keyboardType)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                        )
                )
                .tint(.homeWorthYellow)
        }
    }
}

// FIXED: Non-generic quality picker to avoid type constraints errors
struct QualityPickerSection<T>: View where T: CaseIterable, T: Hashable {
    let title: String
    @Binding var selection: T
    let cases: T.AllCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.deepBlack.opacity(0.7))
            
            Picker(title, selection: $selection) {
                ForEach(Array(cases), id: \.self) { option in
                    Text("\(option)")
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            .foregroundColor(.deepBlack)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}
