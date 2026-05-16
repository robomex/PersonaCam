import Foundation
import RealityKit
import simd

/// Component attached to the root entity that should follow the wearer's head.
struct HeadFollowComponent: Component {
    let position: PersonaCamPosition
}

/// Per-frame system that drives the head-follow root with exponentially damped motion.
///
/// Damping recipe from Apple's `DisplayingA3DObjectThatMovesToStayInAPersonsView` sample:
/// `ratio = pow(dampingRate, deltaTime / 16ms)`; new = ratio·current + (1-ratio)·target.
/// The `deltaTime / 16ms` exponent normalizes for frame rate.
struct HeadFollowSystem: System {
    static let query = EntityQuery(where: .has(HeadFollowComponent.self))

    private static let distance: Float = 0.5
    private static let dampingRate: Float = 0.85
    private static let referenceDeltaSeconds: Float = 16.0 * 1e-3

    // Fires registerSystem() exactly once, the first time `ensureRegistered()` is called.
    @MainActor
    private static let _registered: Void = {
        HeadFollowSystem.registerSystem()
    }()

    @MainActor
    static func ensureRegistered() {
        _ = _registered
    }

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        guard let headTransform = HeadPoseTracker.shared.queryDeviceTransform() else {
            return
        }

        let headPosition = HeadFrameMath.translation(of: headTransform)
        let deltaSeconds = Float(context.deltaTime)
        let ratio = pow(Self.dampingRate, deltaSeconds / Self.referenceDeltaSeconds)

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let component = entity.components[HeadFollowComponent.self] else { continue }

            let offset = component.position.offset(in: headTransform,
                                                   distance: Self.distance)
            let target = headPosition + offset

            let current = entity.position(relativeTo: nil)
            let new = ratio * current + (1 - ratio) * target

            entity.look(at: headPosition,
                        from: new,
                        relativeTo: nil)
        }
    }
}
