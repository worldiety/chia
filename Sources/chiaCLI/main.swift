import chia
import Foundation

do {
    try Chia.runChecks()
} catch {
    print(error)
    exit(1)
}
