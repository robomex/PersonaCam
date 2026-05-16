import SwiftUI
import AVFoundation
import UIKit

/// SwiftUI view that displays the persona camera preview.
///
/// On visionOS, `AVCaptureVideoPreviewLayer` is unavailable. Instead, the package's
/// `CaptureSessionManager` enqueues per-frame `CMSampleBuffer`s into an
/// `AVSampleBufferDisplayLayer`, which this view hosts via a `UIViewRepresentable`.
public struct PersonaCamView: View {
    let size: PersonaCamSize

    @Environment(\.physicalMetrics) private var physicalMetrics

    public init(size: PersonaCamSize = .regular) {
        self.size = size
    }

    public var body: some View {
        let width = physicalMetrics.convert(CGFloat(size.widthMeters), from: .meters)
        let height = physicalMetrics.convert(CGFloat(size.heightMeters), from: .meters)

        DisplayLayerRepresentable(displayLayer: CaptureSessionManager.shared.displayLayer)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct DisplayLayerRepresentable: UIViewRepresentable {
    let displayLayer: AVSampleBufferDisplayLayer

    func makeUIView(context: Context) -> SampleBufferHostView {
        let view = SampleBufferHostView()
        view.attach(displayLayer: displayLayer)
        return view
    }

    func updateUIView(_ uiView: SampleBufferHostView, context: Context) {}
}

private final class SampleBufferHostView: UIView {
    private weak var hostedLayer: AVSampleBufferDisplayLayer?

    func attach(displayLayer: AVSampleBufferDisplayLayer) {
        // Detach from any previous host so re-mounting (or a second PersonaCamView)
        // doesn't silently re-parent the singleton layer mid-flight.
        displayLayer.removeFromSuperlayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.frame = bounds
        layer.addSublayer(displayLayer)
        hostedLayer = displayLayer
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hostedLayer?.frame = bounds
    }
}
