# PersonaCam

A Swift package that floats your Persona in a corner of your field of view on visionOS. PersonaCam's primary use is for developers to record demo videos with a facecam on their Apple Vision Pro.

![PersonaCam demo](https://github.com/user-attachments/assets/39028e59-a362-4435-a2c5-6c52073d3bfb)

> **PersonaCam is not intended to be used in production apps.** Wrap your PersonaCam calls in `#if DEBUG` to keep them out of release builds.

## Installation

In XCode: **File → Add Package Dependencies…** → paste `https://github.com/robomex/PersonaCam` → "Up to Next Major Version" from `0.2.1`

## Prerequisites

**Required** — add the camera usage description to your `Info.plist`, without it your app will crash the moment the persona capture session tries to start. For example:

```xml
<key>NSCameraUsageDescription</key>
<string>Records your Persona for a face-cam overlay in demo videos.</string>
```

## Integration

PersonaCam offers two integration paths, depending on your app structure:

| If your app... | Use |
|---|---|
| Has an `ImmersiveSpace` with a `RealityView` | [**Path A**](#path-a-add-to-an-existing-realityview) |
| Is windows-only | [**Path B**](#path-b-let-personacam-own-the-immersive-space) |

### Path A: add to an existing RealityView

If your app uses an `ImmersiveSpace`: 
1. `.addPersonaCam(position: [chosen position], in: attachments)` to your `content` in the `make:` closure
2. Call `PersonaCamAttachment(size: [chosen size])` in the `attachments:` closure

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

### Path B: let PersonaCam own the immersive space

If your app does not use an `ImmersiveSpace`: 
1. Declare `PersonaCamScene` in your `App.body`
2. Attach `.openPersonaCamOnAppear()` to your window's root view:

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

> visionOS permits one immersive space across all apps at a time. If you later add your own immersive content, switch to Path A.

## Positions

| Case | Where it appears in the field of view |
|---|---|
| `.topLeft` | Upper-left |
| `.topCenter` | Top center |
| `.topRight` | Upper-right |
| `.bottomLeft` | Lower-left |
| `.bottomCenter` | Bottom center |
| `.bottomRight` | Lower-right |

## Sizes

| Case | 
|---|
| `.small` | 
| `.regular` | 

## Recording demos

Use visionOS's built-in **Record My View** (Control Center → recording button) to capture your view as a video. 

Reality Composer Pro's **Developer Capture** is another option.

## Limitations and Pitfalls

- The virtual camera always faces "from" the primary `WindowGroup`. If you walk past the primary `WindowGroup`, the camera will aim towards the nonexistent back of your Persona's head. A potential (untested) remedy is the `Window Follow Mode` enterprise API.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
