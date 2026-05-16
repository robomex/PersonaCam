import AVFoundation
import CoreMedia
import Foundation
import OSLog

/// Owns the `AVCaptureSession` configured with the front-facing camera device.
///
/// On visionOS, `AVCaptureVideoPreviewLayer` is unavailable, so the session is wired
/// to an `AVCaptureVideoDataOutput` whose sample-buffer delegate forwards each frame
/// into an `AVSampleBufferDisplayLayer`. The system renders the wearer's Persona into
/// the front-device's frame stream; the package forwards those frames to the display
/// layer for `PersonaCamView` to host.
///
/// `@unchecked Sendable` (rather than `actor`, which is the AVCam pattern) because
/// `PersonaCamView`'s SwiftUI body reads `displayLayer` synchronously and the actor
/// equivalent would require restructuring the consumer-facing view.
final class CaptureSessionManager: NSObject, @unchecked Sendable {
    static let shared = CaptureSessionManager()

    let displayLayer = AVSampleBufferDisplayLayer()

    private let session = AVCaptureSession()
    private let dataOutput = AVCaptureVideoDataOutput()
    private let logger = Logger(subsystem: "com.personacam", category: "capture")
    private let sessionQueue = DispatchQueue(label: "com.personacam.capture", qos: .userInitiated)
    private let stateLock = NSLock()
    private var hasStarted = false

    func start() {
        stateLock.lock()
        let alreadyStarted = hasStarted
        hasStarted = true
        stateLock.unlock()
        guard !alreadyStarted else { return }

        Task {
            guard #available(visionOS 2.1, *) else {
                logger.error("AVCaptureSession on visionOS requires 2.1 or later; persona panel will remain empty.")
                return
            }
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else {
                logger.error("Camera permission denied; persona panel will remain empty.")
                return
            }
            sessionQueue.async { self.configureAndStart() }
        }
    }

    @available(visionOS 2.1, *)
    private func configureAndStart() {
        guard !session.isRunning else { return }

        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(for: .video) else {
            logger.error("No front-facing capture device available.")
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else {
                logger.error("Capture session refused front-camera input.")
                session.commitConfiguration()
                return
            }
            session.addInput(input)

            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            guard session.canAddOutput(dataOutput) else {
                logger.error("Capture session refused video data output.")
                session.commitConfiguration()
                return
            }
            session.addOutput(dataOutput)

            session.commitConfiguration()
            session.startRunning()
        } catch {
            logger.error("Failed to build capture device input: \(error.localizedDescription, privacy: .private)")
            session.commitConfiguration()
        }
    }
}

extension CaptureSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        let renderer = displayLayer.sampleBufferRenderer
        guard renderer.isReadyForMoreMediaData else { return }
        renderer.enqueue(sampleBuffer)
    }
}
