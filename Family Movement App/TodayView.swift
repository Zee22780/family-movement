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
    var body: some View {
        ZStack {
            // Full-screen background
            Color.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top text block
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hi, I'm Leo")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.gray)
                    
                    Text("Your dedicated partner in creating a fitness habit for life!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Bottom pill button
                Button(action: {
                    // Action placeholder
                }) {
                    Text("Let's Get Started!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    TodayView()
}


