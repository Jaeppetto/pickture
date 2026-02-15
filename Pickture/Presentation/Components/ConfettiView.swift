import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTick: Int = 0

    private let particleCount = 50
    private let colors: [Color] = [
        AppColors.primary,
        AppColors.video,
        AppColors.screenshot,
        AppColors.keep,
        AppColors.delete,
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x * size.width - particle.size / 2,
                        y: particle.y * size.height - particle.size / 2,
                        width: particle.size,
                        height: particle.size * particle.aspectRatio
                    )
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 2),
                        with: .color(particle.color)
                    )
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            generateParticles()
        }
    }

    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0.1...0.9),
                y: CGFloat.random(in: -0.3...(-0.05)),
                size: CGFloat.random(in: 4...10),
                aspectRatio: CGFloat.random(in: 0.5...2.0),
                color: colors.randomElement() ?? .blue,
                velocityX: CGFloat.random(in: -0.002...0.002),
                velocityY: CGFloat.random(in: 0.003...0.008)
            )
        }
    }

    private func updateParticles() {
        for index in particles.indices {
            particles[index].x += particles[index].velocityX
            particles[index].y += particles[index].velocityY
            particles[index].velocityY += 0.0001 // gravity
        }
    }
}

private struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var aspectRatio: CGFloat
    var color: Color
    var velocityX: CGFloat
    var velocityY: CGFloat
}
