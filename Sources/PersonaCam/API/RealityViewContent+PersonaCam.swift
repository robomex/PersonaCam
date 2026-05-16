import RealityKit
import SwiftUI

/// File-scope tracking of the active persona-cam root so repeated `addPersonaCam`
/// calls don't leak orphaned roots into the `RealityViewContent`.
@MainActor
private var currentPersonaCamRoot: Entity?

extension RealityViewContent {
    /// Adds the persona camera as a head-anchored attachment in this `RealityView`.
    ///
    /// The consumer must provide a `PersonaCamAttachment(size:)` in the view's
    /// `attachments` builder. Size is declared on `PersonaCamAttachment(size:)`;
    /// placement is independent of size.
    ///
    /// - Parameters:
    ///   - position: Where in the wearer's field of view the panel should float.
    ///   - attachments: The attachments collection from the `RealityView` builder.
    @MainActor
    public func addPersonaCam(position: PersonaCamPosition,
                              in attachments: RealityViewAttachments)
    {
        HeadFollowSystem.ensureRegistered()

        HeadPoseTracker.shared.start()
        CaptureSessionManager.shared.start()

        guard let attachmentEntity = attachments.entity(for: personaCamAttachmentID) else {
            return
        }

        // Remove the previous root (if any) before adding a new one — protects against
        // a repeated `addPersonaCam` call leaving an orphaned root in the scene that
        // `HeadFollowSystem` keeps processing every frame.
        currentPersonaCamRoot?.removeFromParent()

        let root = Entity()
        root.addChild(attachmentEntity)
        root.components.set(HeadFollowComponent(position: position))
        add(root)
        currentPersonaCamRoot = root
    }
}

