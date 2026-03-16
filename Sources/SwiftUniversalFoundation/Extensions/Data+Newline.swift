import Foundation

extension Data {
  /// Returns a copy of the data that ends with exactly one trailing newline (`\n`).
  ///
  /// - If the data is empty, the result is a single newline byte.
  /// - If the data already ends in `\n`, the original data is returned unchanged.
  /// - Otherwise, a single `\n` byte is appended.
  ///
  /// This helper is used by JSON file writers and NDJSON emitters to enforce
  /// POSIX‑style newline discipline for human‑readable logs and artifacts.
  @inlinable
  public func ensuringTrailingNewline() -> Data {
    let newline = UInt8(ascii: "\n")
    guard let lastByte = last else { return Data([newline]) }
    if lastByte == newline { return self }
    var copy = self
    copy.append(newline)
    return copy
  }

  /// Mutating variant of `ensuringTrailingNewline()`.
  @inlinable
  public mutating func ensureTrailingNewlineInPlace() {
    self = ensuringTrailingNewline()
  }
}
