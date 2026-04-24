import Testing

@testable import Pickture

@Suite("BrutalistButtonStyle Tests")
struct BrutalistButtonStyleTests {
    @Test("released button keeps full raised depth")
    func releasedButtonKeepsFullRaisedDepth() {
        let metrics = BrutalistButtonPressMetrics.metrics(isPressed: false, shadowOffset: 4)

        #expect(metrics.bodyOffset == 0)
        #expect(metrics.scale == 1)
    }

    @Test("pressed button compresses toward its shadow")
    func pressedButtonCompressesTowardItsShadow() {
        let metrics = BrutalistButtonPressMetrics.metrics(isPressed: true, shadowOffset: 4)

        #expect(abs(metrics.bodyOffset - 3.6) < 0.001)
        #expect(metrics.scale == 0.995)
    }
}
