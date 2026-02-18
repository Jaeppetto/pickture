import SwiftUI

struct PicktureIconView: View {
    var body: some View {
        ZStack {
            // Background
            Color(red: 0xF5/255, green: 0xF0/255, blue: 0xEB/255)
            
            // Stack of Cards
            ZStack {
                // Bottom Card (Yellow - Photo)
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0xFF/255, green: 0xD4/255, blue: 0x3B/255))
                    // Subtle Gallery Icon Overlay
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.4))
                            .padding(40)
                    )
                    .frame(width: 140, height: 160)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -15, y: 10)
                    .shadow(color: Color(red: 0x1A/255, green: 0x1A/255, blue: 0x1A/255).opacity(0.15), radius: 4, x: 2, y: 2)
                
                // Top Card (Green - Action)
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0x51/255, green: 0xCF/255, blue: 0x66/255))
                    .overlay(
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white) // White checkmark for cleaner look
                            .padding(35)
                            .fontWeight(.black)
                    )
                    .frame(width: 140, height: 160)
                    .rotationEffect(.degrees(12))
                    .offset(x: 20, y: -10)
                    .shadow(color: Color(red: 0x1A/255, green: 0x1A/255, blue: 0x1A/255).opacity(0.2), radius: 6, x: 4, y: 4)
                
            }
        }
        .frame(width: 256, height: 256)
        .cornerRadius(58) // iOS App Icon shape
    }
}

#Preview {
    PicktureIconView()
        .previewLayout(.sizeThatFits)
}
