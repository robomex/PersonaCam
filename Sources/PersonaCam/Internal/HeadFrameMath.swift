import simd

enum HeadFrameMath {
    /// The head's +Z column as a unit vector in world coordinates.
    /// To project IN FRONT of the head, use `-distance * forward` — this matches
    /// Apple's head-tracking sample idiom.
    static func forward(of transform: simd_float4x4) -> SIMD3<Float> {
        SIMD3<Float>(transform.columns.2.x,
                     transform.columns.2.y,
                     transform.columns.2.z).normalized()
    }

    static func up(of transform: simd_float4x4) -> SIMD3<Float> {
        SIMD3<Float>(transform.columns.1.x,
                     transform.columns.1.y,
                     transform.columns.1.z).normalized()
    }

    static func right(of transform: simd_float4x4) -> SIMD3<Float> {
        SIMD3<Float>(transform.columns.0.x,
                     transform.columns.0.y,
                     transform.columns.0.z).normalized()
    }

    static func translation(of transform: simd_float4x4) -> SIMD3<Float> {
        SIMD3<Float>(transform.columns.3.x,
                     transform.columns.3.y,
                     transform.columns.3.z)
    }
}

extension SIMD3 where Scalar == Float {
    fileprivate func normalized() -> SIMD3<Float> {
        let lengthValue = sqrt(x * x + y * y + z * z)
        return lengthValue > 0 ? self / lengthValue : .zero
    }
}
