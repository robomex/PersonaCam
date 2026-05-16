import ARKit
import Foundation
import OSLog
import QuartzCore
import simd

/// Wraps `ARKitSession` + `WorldTrackingProvider` to deliver the device's pose each frame.
///
/// Matches Apple's `HeadPositionTracker` sample shape — a plain class accessed from
/// RealityKit's main-thread render callbacks. `@MainActor` here is the strict-concurrency
/// equivalent of the sample's annotation-free declaration: all our access points
/// (`HeadFollowSystem.update`, `addPersonaCam`) already run on the main actor.
@MainActor
final class HeadPoseTracker {
    static let shared = HeadPoseTracker()

    private let session = ARKitSession()
    private let provider = WorldTrackingProvider()
    private let logger = Logger(subsystem: "com.personacam", category: "head-tracking")
    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        Task {
            guard WorldTrackingProvider.isSupported else {
                logger.error("WorldTrackingProvider not supported on this device.")
                return
            }
            do {
                try await session.run([provider])
            } catch {
                logger.error("ARKitSession failed: \(error.localizedDescription, privacy: .private)")
            }
        }
    }

    /// The current device anchor transform, or nil if tracking is unavailable.
    func queryDeviceTransform() -> simd_float4x4? {
        provider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())?.originFromAnchorTransform
    }
}
