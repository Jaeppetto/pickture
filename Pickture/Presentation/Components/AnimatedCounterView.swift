import SwiftUI

struct AnimatedCounterView: View {
    let targetValue: Int
    let font: Font
    let color: Color

    @State private var displayedValue: Int = 0

    var body: some View {
        Text("\(displayedValue)")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText(value: Double(displayedValue)))
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    displayedValue = targetValue
                }
            }
    }
}
