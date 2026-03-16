import Foundation
import Testing

@testable import SwiftUniversalFoundation

@Suite("URLTempDirectory")
struct URLTempDirectoryTests {
  @Test
  func generatesUniquePathsWithinTemporaryDirectory() {
    let first = URL.tempDirectory
    let second = URL.tempDirectory
    let basePath = FileManager.default.temporaryDirectory.path
    #expect(first.path.hasPrefix(basePath))
    #expect(second.path.hasPrefix(basePath))
    #expect(first != second)
  }
}
