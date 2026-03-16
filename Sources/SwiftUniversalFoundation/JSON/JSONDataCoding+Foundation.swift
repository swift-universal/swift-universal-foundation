@preconcurrency import Foundation
import SwiftUniversalMain

// Default conformances for Foundation JSON coders to top-level protocols.
extension JSONEncoder: JSONDataEncoding {}
extension JSONDecoder: JSONDataDecoding {}
