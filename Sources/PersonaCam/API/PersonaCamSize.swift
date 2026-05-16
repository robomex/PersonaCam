/// The size of the floating persona panel.
public enum PersonaCamSize: Sendable {
    case small
    case regular
}

extension PersonaCamSize {
    /// Approximate physical width of the panel in meters at the package's default forward distance.
    public var widthMeters: Float {
        switch self {
        case .small:   return 0.08
        case .regular: return 0.12
        }
    }

    /// Approximate physical height of the panel in meters (4:3 portrait aspect).
    public var heightMeters: Float {
        widthMeters * (4.0 / 3.0)
    }
}
