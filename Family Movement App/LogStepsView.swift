import SwiftUI

struct LogStepsView: View {
    @AppStorage("todaySteps") private var todaySteps: Int = 0
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var stepsText = ""
    @State private var noteText = ""
    
    private var isSaveEnabled: Bool {
        guard !stepsText.isEmpty,
              let steps = Int(stepsText),
              steps > 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
       
        ZStack {
            // Full-screen background
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with Cancel button
                HStack {
                    Spacer()
                    Button("Cancel") {
                        // Dismiss action (to be wired in Step 2)
                    }
                    .foregroundColor(.primaryBlue)
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title and subtitle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Log steps")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Add your steps for today")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // White card container
                        VStack(alignment: .leading, spacing: 20) {
                            // DatePicker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            
                            Divider()
                            
                            // Steps TextField
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Steps")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                TextField("Enter steps", text: $stepsText)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Divider()
                            
                            // Optional note TextField
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Note (optional)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                TextField("Add a note", text: $noteText)
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Save button at bottom
                Button(action: {
                    if let steps = Int(stepsText), steps > 0 {
                        todaySteps = steps
                        dismiss()
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSaveEnabled ? Color.primaryBlue : Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                }
                .disabled(!isSaveEnabled)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    LogStepsView()
}
