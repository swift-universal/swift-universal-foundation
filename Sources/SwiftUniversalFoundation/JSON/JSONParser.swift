import Foundation
import SwiftUniversalMain

// Keep Foundation coupling/defaults here; core Parser lives in SwiftUniversalMain.
extension SwiftUniversalMain.JSON.Parser {
  /// Foundation-backed defaults (camelCase keys, robust date handling).
  public static var foundationDefault: SwiftUniversalMain.JSON.Parser {
    .init(encoder: JSONEncoder.commonDateFormatting, decoder: JSONDecoder.commonDateParsing)
  }
}
