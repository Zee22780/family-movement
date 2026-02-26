import SwiftUI

// Color extension for hex colors
extension Color {
    static let background = Color(hex: "ECFEFE")
    static let primaryBlue = Color(hex: "246AA0")
    static let peach = Color(hex: "F4CFB9")
    static let rust = Color(hex: "CC6D19")
    static let white = Color(hex: "FFFFFF")
    static let teal = Color(hex: "1D8A99")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct TodayView: View {
    @AppStorage("dailySteps") private var dailyStepsData: String = "{}"
    @AppStorage("todaySteps") private var legacyTodaySteps: Int = 0
    @State private var quickStepsText = ""
    @FocusState private var quickStepsFocused: Bool
    @State private var showToast = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var todayKey: String {
        Self.dateFormatter.string(from: Date())
    }

    private var todaySteps: Int {
        decodeDailySteps()[todayKey] ?? 0
    }
    
    private var isQuickSaveEnabled: Bool {
        guard !quickStepsText.isEmpty,
              let steps = Int(quickStepsText),
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
            
            VStack(alignment: .leading, spacing: 0) {
                // Top text block
                VStack(alignment: .leading, spacing: 8) {
                    Text("Coach Leo here.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Log today’s steps.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                if todaySteps > 0 {
                    Text("Today: \(todaySteps) steps")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                }

                Spacer(minLength: 8)

                VStack(spacing: 12) {
                    TextField("Enter steps", text: $quickStepsText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .focused($quickStepsFocused)
                        .padding(.horizontal, 20)
                    
                    Text("Updates today’s total.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        if let steps = Int(quickStepsText), steps > 0 {
                            var updated = decodeDailySteps()
                            updated[todayKey] = steps
                            dailyStepsData = encodeDailySteps(updated)
                            legacyTodaySteps = steps
                            quickStepsText = ""
                            quickStepsFocused = false
                            withAnimation(.easeOut(duration: 0.2)) {
                                showToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    showToast = false
                                }
                            }
                        }
                    }) {
                        Text("Log Steps")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isQuickSaveEnabled ? Color.primaryBlue : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .disabled(!isQuickSaveEnabled)
                    .padding(.horizontal, 20)
                }
                .padding(.top, 8)

                Spacer(minLength: 6)

                Image("lionMascot")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 420)
                    .offset(y: 0)
                    .padding(.vertical, 4)

                Spacer(minLength: 16)

                // Bottom pill button
                NavigationLink {
                    StatsView()
                } label: {
                    Text("Stats")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryBlue)
                        .clipShape(Capsule())
                }

                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            
            if showToast {
                VStack {
                    Spacer()
                    Text("Locked in. Nice work.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.teal)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.bottom, 90)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            if legacyTodaySteps > 0 {
                let current = decodeDailySteps()
                if current[todayKey] == nil {
                    var updated = current
                    updated[todayKey] = legacyTodaySteps
                    dailyStepsData = encodeDailySteps(updated)
                }
            }
        }
    }
    
    private func decodeDailySteps() -> [String: Int] {
        guard let data = dailyStepsData.data(using: .utf8) else {
            return [:]
        }
        return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
    }
    
    private func encodeDailySteps(_ steps: [String: Int]) -> String {
        guard let data = try? JSONEncoder().encode(steps),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

#Preview {
    TodayView()
}
