import Foundation
import SwiftUniversalMain

extension StringError: @retroactive CustomNSError {

  // CustomNSError to surface the message via localizedDescription
  public static var errorDomain: String { "SwiftUniversalMain.StringError" }

  public var errorCode: Int { 1 }

  public var errorUserInfo: [String: Any] { [NSLocalizedDescriptionKey: message] }
}
