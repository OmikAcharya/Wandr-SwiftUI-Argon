---
name: swiftui-builder
description: Builds complete, zero-error multi-file SwiftUI iOS 17+ applications from a technical specification.
---

# SwiftUI Zero-Error Builder Skill

When invoked to implement a SwiftUI specification:
1. **Direct Disk Write Only:** Write every source file directly to the workspace directory tree. Never truncate or emit placeholders.
2. **Strict iOS 17+ Conventions:**
   - Use `ObservableObject`, `@Published`, `@StateObject`, and `@EnvironmentObject` consistently (do not mix with `@Observable`).
   - Use the iOS 17 `Map(position:)` and `Annotation` APIs exclusively.
   - Store coordinates as `Double` (`latitude`, `longitude`) on `Codable` models and expose `CLLocationCoordinate2D` as computed properties.
   - Decompose large SwiftUI views into smaller `@ViewBuilder` computed properties to prevent Swift type-checker timeouts.
3. **Automatic Compilation Check:**
   - Create a `project.yml` file for `xcodegen`.
   - Run `xcrun --sdk iphonesimulator swiftc -typecheck -target $(uname -m)-apple-ios17.0-simulator $(find Wandr -name "*.swift")` or `xcodebuild` if Xcode is present.
