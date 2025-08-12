// HomeWorth/Views/AddPropertyView.swift
import SwiftUI

struct AddPropertyView: View {
    @StateObject private var viewModel = AddPropertyViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Area (sq ft)", text: $viewModel.area)
                        .keyboardType(.decimalPad)
                    TextField("Bedrooms", text: $viewModel.bedrooms)
                        .keyboardType(.numberPad)
                    TextField("Bathrooms", text: $viewModel.bathrooms)
                        .keyboardType(.numberPad)
                    TextField("Balconies", text: $viewModel.balconies)
                        .keyboardType(.numberPad)
                    TextField("Built Year", text: $viewModel.builtYear)
                        .keyboardType(.numberPad)
                    TextField("Number of Floors", text: $viewModel.numberOfFloors)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Distances (in km)")) {
                    TextField("ATM Distance", text: $viewModel.atmDistance)
                        .keyboardType(.decimalPad)
                    TextField("Hospital Distance", text: $viewModel.hospitalDistance)
                        .keyboardType(.decimalPad)
                    TextField("School Distance", text: $viewModel.schoolDistance)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Construction Quality")) {
                    Picker("Wood Quality", selection: $viewModel.woodQuality) {
                        ForEach(WoodQuality.allCases) { quality in
                            Text(quality.description).tag(quality)
                        }
                    }
                    Picker("Cement Grade", selection: $viewModel.cementGrade) {
                        ForEach(CementGrade.allCases) { grade in
                            Text(grade.description).tag(grade)
                        }
                    }
                    Picker("Steel Grade", selection: $viewModel.steelGrade) {
                        ForEach(SteelGrade.allCases) { grade in
                            Text(grade.description).tag(grade)
                        }
                    }
                    Picker("Brick Type", selection: $viewModel.brickType) {
                        ForEach(BrickType.allCases) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    Picker("Flooring Quality", selection: $viewModel.flooringQuality) {
                        ForEach(FlooringQuality.allCases) { quality in
                            Text(quality.description).tag(quality)
                        }
                    }
                    Picker("Paint Quality", selection: $viewModel.paintQuality) {
                        ForEach(PaintQuality.allCases) { quality in
                            Text(quality.description).tag(quality)
                        }
                    }
                    Picker("Plumbing Quality", selection: $viewModel.plumbingQuality) {
                        ForEach(PlumbingQuality.allCases) { quality in
                            Text(quality.description).tag(quality)
                        }
                    }
                    Picker("Electrical Quality", selection: $viewModel.electricalQuality) {
                        ForEach(ElectricalQuality.allCases) { quality in
                            Text(quality.description).tag(quality)
                        }
                    }
                    Picker("Roofing Type", selection: $viewModel.roofingType) {
                        ForEach(RoofingType.allCases) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    Picker("Window Glass Quality", selection: $viewModel.windowGlassQuality) {
                        ForEach(WindowGlassQuality.allCases) { quality in
                            Text(quality.description).tag(quality)
                        }
                    }
                    Picker("Area Type", selection: $viewModel.areaType) {
                        ForEach(AreaType.allCases) { type in
                            Text(type.description).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Prediction & Pricing")) {
                    Button("Predict Fair Price") {
                        viewModel.makePrediction()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    
                    Text("Predicted Fair Price: \(viewModel.formattedPrice)")
                        .font(.headline)
                        .foregroundColor(viewModel.predictedPrice != nil ? .green : .secondary)
                    
                    TextField("Your Asking Price (₹)", text: $viewModel.askingPrice)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button("Save Property") {
                        Task {
                            await viewModel.savePropertyToSupabase()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.askingPrice.isEmpty)
                }
                
                if !viewModel.message.isEmpty {
                    Section {
                        Text(viewModel.message)
                            .foregroundColor(viewModel.message.contains("successfully") ? .green : .red)
                    }
                }
            }
            .navigationTitle("Add New Property")
        }
    }
}
