import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    private let particleCount = 50
    private let colors: [Color] = [
        AppColors.accentYellow,
        AppColors.accentRed,
        AppColors.accentGreen,
        AppColors.accentBlue,
        AppColors.accentPurple,
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    var particleContext = context
                    let center = CGPoint(
                        x: particle.x * size.width,
                        y: particle.y * size.height
                    )
                    let rect = CGRect(
                        x: -particle.size / 2,
                        y: -(particle.size * particle.aspectRatio) / 2,
                        width: particle.size,
                        height: particle.size * particle.aspectRatio
                    )

                    let path: Path = switch particle.shape {
                    case .circle:
                        Path(ellipseIn: rect)
                    case .strip:
                        Path(roundedRect: rect, cornerRadius: 2)
                    }

                    particleContext.translateBy(x: center.x, y: center.y)
                    particleContext.rotate(by: .degrees(particle.rotation))
                    particleContext.fill(path, with: .color(particle.color))
                    particleContext.stroke(path, with: .color(AppColors.ink), lineWidth: 1)
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
                size: CGFloat.random(in: 8...16),
                aspectRatio: CGFloat.random(in: 0.5...2.0),
                color: colors.randomElement() ?? .blue,
                velocityX: CGFloat.random(in: -0.002...0.002),
                velocityY: CGFloat.random(in: 0.003...0.008),
                rotation: Double.random(in: -35...35),
                spin: Double.random(in: -2.8...2.8),
                shape: ConfettiShape.allCases.randomElement() ?? .strip
            )
        }
    }

    private func updateParticles() {
        for index in particles.indices {
            particles[index].x += particles[index].velocityX
            particles[index].y += particles[index].velocityY
            particles[index].velocityY += 0.0001
            particles[index].rotation += particles[index].spin
        }
    }
}

private enum ConfettiShape: CaseIterable {
    case strip
    case circle
}

private struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var aspectRatio: CGFloat
    var color: Color
    var velocityX: CGFloat
    var velocityY: CGFloat
    var rotation: Double
    var spin: Double
    var shape: ConfettiShape
}
