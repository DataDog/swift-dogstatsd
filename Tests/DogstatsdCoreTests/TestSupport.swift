@testable import Dogstatsd

final class RecordingStatsdSender: StatsdSender {
    var globalTags: [String] = []
    private(set) var sentMetrics: [String] = []

    func sendRaw(metric: String) {
        sentMetrics.append(metric)
    }
}

final class TestDogstatsdClient: DogstatsdClient {
    let recordingSender = RecordingStatsdSender()

    var sender: StatsdSender {
        recordingSender
    }
}
