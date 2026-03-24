import Foundation
@testable import SwiftUniversalFoundation
import SwiftUniversalMain
import Testing

struct JSONWriterTests {
  struct Link: Codable, Equatable {
    var title: String
    var url: String
  }

  private func fixtureData(named name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
    return try Data(contentsOf: url)
  }

  @Test func humanEncoderDoesNotEscapeSlashes() throws {
    let link = Link(title: "Example", url: "https://example.com/a/b")
    let data = try JSON.Formatting.humanEncoder.encode(link)
    let s = try #require(String(bytes: data, encoding: .utf8))
    #expect(s.contains("https://example.com/a/b"))
    #expect(!s.contains("https:\\/\\/example.com"))
  }

  @Test func humanDataCanonicalizesEncodableWithTrailingNewline() throws {
    let link = Link(title: "Example", url: "https://example.com/a/b")
    let data = try JSON.Formatting.humanData(from: link)
    let canonical = try fixtureData(named: "canonical-link")

    #expect(data == canonical)
  }

  @Test func humanDataCanonicalizesJSONObjectWithTrailingNewline() throws {
    let data = try JSON.Formatting.humanData(fromJSONObject: [
      "url": "https://example.com/a/b",
      "title": "Example",
    ])
    let canonical = try fixtureData(named: "canonical-link")

    #expect(data == canonical)
  }

  @Test func fileWriterWritesAtomicallyWithHumanOptions() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "json-writer-tests-\(UUID().uuidString)",
      isDirectory: true)
    let url = tmp.appendingPathComponent("out.json")
    try JSON.FileWriter.writeJSONObject(["url": "https://example.com"], to: url)
    let text = try String(contentsOf: url)
    #expect(text.contains("https://example.com"))
    #expect(!text.contains("https:\\/\\/example.com"))
  }

  @Test func fileWriterAppendsSingleFinalNewlineJSONObject() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "json-writer-tests-\(UUID().uuidString)",
      isDirectory: true)
    let url = tmp.appendingPathComponent("out.json")
    try JSON.FileWriter.writeJSONObject(["k": "v"], to: url)
    let data = try Data(contentsOf: url)
    #expect(!data.isEmpty)
    #expect(data.last == UInt8(ascii: "\n"))
    // Ensure not double newline
    if data.count >= 2 { #expect(data[data.count - 2] != UInt8(ascii: "\n")) }
  }

  @Test func fileWriterAppendsSingleFinalNewlineEncodable() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "json-writer-tests-\(UUID().uuidString)",
      isDirectory: true)
    let url = tmp.appendingPathComponent("out2.json")
    try JSON.FileWriter.write(Link(title: "X", url: "x"), to: url)
    let data = try Data(contentsOf: url)
    #expect(!data.isEmpty)
    #expect(data.last == UInt8(ascii: "\n"))
  }
}
