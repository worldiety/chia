import chiaLib
import Foundation

do {
    // TODO: add this to cli
    let config = try Chia.getConfig(from: URL(string: "https://raw.githubusercontent.com/PDF-Archiver/PDF-Archive-Viewer/develop/.swiftlint.yml")!)
    try Chia.runChecks(with: config)
} catch {
    print(error)
    exit(1)
}
