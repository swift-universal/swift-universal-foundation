// swift-tools-version:6.2
import Foundation
import PackageDescription

/// Local/remote toggle
func envBool(_ key: String) -> Bool {
  guard let raw = ProcessInfo.processInfo.environment[key] else { return false }
  let v = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

  return switch v {
    case "1", "true", "yes", "on":
      true

    case "0", "false", "no", "off":
      false

    default:
      false
  }
}

let useLocalDeps: Bool = {
  if ProcessInfo.processInfo.environment["SPM_CI_USE_LOCAL_DEPS"] != nil {
    return envBool("SPM_CI_USE_LOCAL_DEPS")
  }

  if ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] != nil {
    return envBool("SPM_USE_LOCAL_DEPS")
  }

  return true
}()

func localOrRemote(name: String,
                   path: String,
                   url: String,
                   from version: Version) -> Package.Dependency
{
  if useLocalDeps { return .package(name: name, path: path) }
  return .package(url: url, from: version)
}

let sharedSwiftSettings: [SwiftSetting] =
  useLocalDeps
    ? [.unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=20"])]
    : []

let package = Package(
  name: "SwiftUniversalFoundation",
  platforms: [
    .iOS(.v15),
    .macOS(.v11),
    .macCatalyst(.v15),
    .tvOS(.v16),
    .visionOS(.v1),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "SwiftUniversalFoundation", targets: ["SwiftUniversalFoundation"]),
  ],
  dependencies: [
    localOrRemote(
      name: "common-log",
      path: "../../../../spm/domain/system/common-log",
      url: "https://github.com/swift-universal/common-log.git",
      from: "3.0.0"),
    localOrRemote(
      name: "swift-universal-main",
      path: "../swift-universal-main",
      url: "https://github.com/swift-universal/swift-universal-main.git",
      from: "3.0.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"),
  ],
  targets: [
    .target(
      name: "SwiftUniversalFoundation",
      dependencies: [
        .product(name: "CommonLog", package: "common-log"),
        .product(name: "SwiftUniversalMain", package: "swift-universal-main"),
      ],
      path: "Sources/SwiftUniversalFoundation",
      swiftSettings: sharedSwiftSettings),
    .testTarget(
      name: "SwiftUniversalFoundationTests",
      dependencies: ["SwiftUniversalFoundation"],
      path: "Tests/SwiftUniversalFoundationTests",
      resources: [
        .process("resources"),
      ],
      swiftSettings: sharedSwiftSettings),
  ])
