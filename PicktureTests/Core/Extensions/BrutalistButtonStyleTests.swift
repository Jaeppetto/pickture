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

@Suite("SessionSummaryRevealTimeline Tests")
struct SessionSummaryRevealTimelineTests {
    @Test("standard timing reveals icon title stats and actions in order")
    func standardTimingRevealsPhasesInOrder() {
        let timeline = SessionSummaryRevealTimeline(reduceMotion: false)

        #expect(timeline.delay(for: .icon) == 0.1)
        #expect(timeline.delay(for: .title) == 0.24)
        #expect(timeline.delay(for: .stats) == 0.38)
        #expect(timeline.delay(for: .actions) == 0.52)
    }

    @Test("reduced motion uses shorter timing while preserving order")
    func reducedMotionUsesShorterTimingWhilePreservingOrder() {
        let timeline = SessionSummaryRevealTimeline(reduceMotion: true)

        #expect(timeline.delay(for: .icon) == 0)
        #expect(timeline.delay(for: .title) == 0.08)
        #expect(timeline.delay(for: .stats) == 0.16)
        #expect(timeline.delay(for: .actions) == 0.24)
    }
}
