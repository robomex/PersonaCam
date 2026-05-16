import simd

/// Where the floating persona panel sits within the wearer's field of view.
///
/// All positions are interpreted in head-local coordinates and follow the wearer's
/// head pose with damped motion.
public enum PersonaCamPosition: Sendable {
    case topLeft, topCenter, topRight
    case bottomLeft, bottomCenter, bottomRight
}

extension PersonaCamPosition {
    /// World-space offset from the head's origin where the panel should sit.
    /// - Parameters:
    ///   - headTransform: Device-anchor transform from `WorldTrackingProvider`.
    ///   - distance: Forward distance in meters.
    func offset(in headTransform: simd_float4x4,
                distance: Float) -> SIMD3<Float>
    {
        let forward = HeadFrameMath.forward(of: headTransform)
        let up = HeadFrameMath.up(of: headTransform)
        let right = HeadFrameMath.right(of: headTransform)

        // Project ahead of the head; the head's +Z column points behind in world space,
        // so we negate to go forward (matches Apple's head-tracking sample idiom).
        let forwardComponent = -distance * forward

        // Each constant below = where the panel center sits, in meters from the gaze line.
        let verticalComponent: SIMD3<Float>
        switch self {
        case .topLeft, .topCenter, .topRight:
            verticalComponent = 0.10 * up
        case .bottomLeft, .bottomCenter, .bottomRight:
            verticalComponent = -0.14 * up
        }

        // Left positions are nudged slightly further out than right to compensate for the
        // left-eye perspective used by Developer Capture / Record My View — parallax
        // shifts left-side content toward center in the captured video.
        let horizontalComponent: SIMD3<Float>
        switch self {
        case .topLeft, .bottomLeft:
            horizontalComponent = -0.27 * right
        case .topRight, .bottomRight:
            horizontalComponent = 0.23 * right
        case .topCenter, .bottomCenter:
            horizontalComponent = .zero
        }

        return forwardComponent + verticalComponent + horizontalComponent
    }
}
