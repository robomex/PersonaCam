import SwiftUI
import RealityKit

/// Identifier the package uses to look up the persona camera attachment in a `RealityView`.
internal let personaCamAttachmentID = "com.personacam.attachment"

/// Convenience for placing the persona camera view into a `RealityView`'s attachments builder.
///
/// Equivalent to writing:
/// ```swift
/// Attachment(id: "...") {
///     PersonaCamView(size: size)
/// }
/// ```
@MainActor
@AttachmentContentBuilder
public func PersonaCamAttachment(size: PersonaCamSize = .regular) -> some AttachmentContent {
    Attachment(id: personaCamAttachmentID) {
        PersonaCamView(size: size)
    }
}
