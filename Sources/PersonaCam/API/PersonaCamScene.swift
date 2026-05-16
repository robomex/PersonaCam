import SwiftUI
import RealityKit

/// A standalone `ImmersiveSpace` scene containing just the head-anchored persona camera.
///
/// Use this in your `App.body` when your app doesn't already manage an immersive space.
/// Open it from any view via `openImmersiveSpace(id: PersonaCamScene.defaultID)`.
public struct PersonaCamScene: SwiftUI.Scene {
    public static let defaultID = "PersonaCamScene"

    let id: String
    let position: PersonaCamPosition
    let size: PersonaCamSize

    public init(id: String = PersonaCamScene.defaultID,
                position: PersonaCamPosition,
                size: PersonaCamSize)
    {
        self.id = id
        self.position = position
        self.size = size
    }

    public var body: some SwiftUI.Scene {
        ImmersiveSpace(id: id) {
            RealityView { content, attachments in
                content.addPersonaCam(position: position, in: attachments)
            } attachments: {
                PersonaCamAttachment(size: size)
            }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

extension View {
    /// Auto-opens `PersonaCamScene` when this view first appears.
    /// Pair with a `PersonaCamScene(position:size:)` declaration in your `App.body`.
    public func openPersonaCamOnAppear(id: String = PersonaCamScene.defaultID) -> some View {
        modifier(OpenPersonaCamOnAppearModifier(id: id))
    }
}

@MainActor
private struct OpenPersonaCamOnAppearModifier: ViewModifier {
    let id: String

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var hasOpened = false

    func body(content: Content) -> some View {
        content.task {
            guard !hasOpened else { return }
            hasOpened = true
            _ = await openImmersiveSpace(id: id)
        }
    }
}
