# PersonaCam

A SwiftUI/RealityKit package that floats your Persona in a head-anchored corner of the field of view on visionOS — for recording demo videos with a face cam without leaving the headset.

![PersonaCam demo](https://github.com/user-attachments/assets/39028e59-a362-4435-a2c5-6c52073d3bfb)

> visionOS only. The Apple Vision Pro **simulator does not render a Persona**; final visual verification requires the device.

> **Intended for development and demo recording, not production.** The camera-usage indicator is always visible while the panel is active, and the Persona's background is whatever the wearer has chosen in System Settings — neither is appropriate for end-user-facing experiences. Wrap your `addPersonaCam` call in `#if DEBUG` to keep it out of release builds.

## Installation

Add the package via Swift Package Manager:

```swift
.package(url: "https://github.com/robomex/PersonaCam.git", from: "0.1.0")
```

Add `PersonaCam` as a dependency of your visionOS target.

## Prerequisites

**Required** — without this `Info.plist` key, your app will crash the moment the persona capture session tries to start (visionOS hard-aborts on capture APIs invoked without a usage description):

```xml
<key>NSCameraUsageDescription</key>
<string>Records your Persona for a face-cam overlay in demo videos.</string>
```

## Integration

PersonaCam offers two integration paths. Pick the one that matches your app's structure — both are first-class.

| Your app... | Use |
|---|---|
| Already has an `ImmersiveSpace` with a `RealityView` (any other 3D content) | [**Path A**](#path-a-add-to-an-existing-realityview) |
| Is windows-only — no immersive content of its own | [**Path B**](#path-b-let-personacam-own-the-immersive-space) |

### Path A: add to an existing RealityView

Drop the persona camera into your existing immersive scene:

```swift
import PersonaCam
import RealityKit
import SwiftUI

ImmersiveSpace(id: "MyScene") {
    RealityView { content, attachments in
        // your existing 3D content…
        content.addPersonaCam(position: .bottomCenter, in: attachments)
    } attachments: {
        PersonaCamAttachment(size: .regular)
    }
}
```

Both calls are required — `RealityView` separates its `make:` and `attachments:` closures, and these are the two halves that correspond to that split. Size is declared once on `PersonaCamAttachment(size:)`; placement is size-independent so the two scopes can't disagree.

### Path B: let PersonaCam own the immersive space

If your app is windows-only, declare `PersonaCamScene` in your `App.body` and attach `.openPersonaCamOnAppear()` to your window's root view:

```swift
import PersonaCam
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .openPersonaCamOnAppear()
        }
        PersonaCamScene(position: .bottomCenter, size: .regular)
    }
}
```

Two lines, both in `App.body`. The panel appears automatically when the app launches — no button, no immersive-space state to manage.

`PersonaCamScene` owns the `ImmersiveSpace`, `RealityView`, and attachment. `.openPersonaCamOnAppear()` triggers `openImmersiveSpace` from your view context once on first appearance.

> visionOS permits one immersive space across all apps at a time. If you later add your own immersive content, switch to Path A.

## Positions

| Case | Where it appears in the field of view |
|---|---|
| `.topLeft` | Upper-left |
| `.topCenter` | Top center |
| `.topRight` | Upper-right |
| `.bottomLeft` | Lower-left |
| `.bottomCenter` | Bottom center (most common for face-cam) |
| `.bottomRight` | Lower-right |

## Sizes

| Case | Approximate width |
|---|---|
| `.small` | ~8 cm |
| `.regular` | ~12 cm |

(4:3 portrait aspect.)

## Recording demos

Use visionOS's built-in **Record My View** (Control Center → recording button) to capture your view as a video. The floating persona panel composites into the output automatically.

If you'd rather record from your Mac, Xcode's **Developer Capture** (Window → Devices and Simulators → connected Vision Pro → Take Developer Capture) is an alternative that produces a `.mov` on your Mac.

## Caveats (v0.1)

- One persona panel per app session. Multiple `addPersonaCam` calls share the same underlying capture session.
- The package starts the capture session on the first `addPersonaCam` call (including inside `PersonaCamScene`) and keeps it running for the lifetime of the process. Wrap your call in `#if DEBUG` if you don't want the camera-usage indicator in release builds.
- **The Persona's background is set by visionOS, not the package.** Whichever Persona Environment the wearer has selected in Settings → Apple Vision Pro → Persona is what the panel shows. visionOS doesn't expose an API to strip or replace the environment, so to get a cleaner backdrop change your Persona Environment in Settings.
- The wearer-facing render's aspect ratio depends on system Persona behavior; the panel uses `.resizeAspectFill` and may crop slightly to fit the configured frame.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
