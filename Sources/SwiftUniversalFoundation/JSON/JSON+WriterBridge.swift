import Foundation
import SwiftUniversalMain

extension JSON {  // SwiftUniversalMain.JSON namespace (preferred API)
  /// Canonical JSON formatting helpers shared by tests, formatters, and file writers.
  public enum Formatting {
    /// Canonical writing options for JSONSerialization-backed writers.
    public static let humanOptions: JSONSerialization.WritingOptions = [
      .prettyPrinted, .sortedKeys, .withoutEscapingSlashes,
    ]

    /// Lazily-initialized encoder with human-friendly formatting and common date encoding.
    public static let humanEncoder: JSONEncoder = {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .custom { date, enc in
        let s = DateFormatter.iso8601WithMillis.string(from: date)
        var c = enc.singleValueContainer()
        try c.encode(s)
      }
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
      return encoder
    }()

    /// Return canonical human-readable JSON bytes for a JSON-serializable object.
    /// Use this when tests, formatters, and file writers need to compare the same on-disk shape.
    public static func humanData(fromJSONObject object: Any,
                                 options: JSONSerialization.WritingOptions = humanOptions,
                                 newlineAtEOF: Bool = true) throws -> Data
    {
      var data = try JSONSerialization.data(withJSONObject: object, options: options)
      if newlineAtEOF { data = data.ensuringTrailingNewline() }
      return data
    }

    /// Normalize an Encodable value through JSONSerialization so in-memory formatting matches
    /// the canonical JSON bytes written by the formatter CLI and file writers.
    public static func humanData<T: Encodable>(from value: T,
                                               encoder: JSONEncoder = humanEncoder,
                                               newlineAtEOF: Bool = true) throws -> Data
    {
      let encoded = try encoder.encode(value)
      let jsonObject = try JSONSerialization.jsonObject(with: encoded)
      return try humanData(fromJSONObject: jsonObject, newlineAtEOF: newlineAtEOF)
    }
  }

  /// Atomic JSON file-writing helpers built on the canonical formatting surface.
  public enum FileWriter {
    /// Write an Encodable value to a file with atomic semantics by default.
    public static func write<T: Encodable>(_ value: T,
                                           to url: URL,
                                           encoder: JSONEncoder = JSON.Formatting.humanEncoder,
                                           atomic: Bool = true,
                                           newlineAtEOF: Bool = true) throws
    {
      try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      let data = try JSON.Formatting.humanData(
        from: value,
        encoder: encoder,
        newlineAtEOF: newlineAtEOF)
      if atomic { try data.write(to: url, options: .atomic) } else { try data.write(to: url) }
    }

    /// Write a JSON-serializable object (`Dictionary`/`Array`/primitives) to a file.
    public static func writeJSONObject(_ object: Any,
                                       to url: URL,
                                       options: JSONSerialization.WritingOptions = JSON.Formatting
                                         .humanOptions,
                                       atomic: Bool = true,
                                       newlineAtEOF: Bool = true) throws
    {
      try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      let data = try JSON.Formatting.humanData(
        fromJSONObject: object,
        options: options,
        newlineAtEOF: newlineAtEOF)
      if atomic { try data.write(to: url, options: .atomic) } else { try data.write(to: url) }
    }
  }
}
