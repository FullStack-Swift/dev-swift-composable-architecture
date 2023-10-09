#if canImport(Network)
import Foundation
import Network

public func useNetworkState(every seconds: TimeInterval = 3) -> Bool {
  let timerPhase = usePublisher(.once) {
    Timer.publish(every: seconds, on: .main, in: .common)
      .autoconnect()
      .prepend(Date())
  }
  let phase = useAsyncSequence(.preserved(by: timerPhase.value)) {
    AsyncStream { continuation in
      let monitor = NWPathMonitor()
      monitor.pathUpdateHandler = { path in
        let isConnected = path.status == .satisfied
        continuation.yield(isConnected)
      }
      continuation.onTermination = { @Sendable _ in
        monitor.cancel()
      }
      monitor.start(queue: DispatchQueue(label: "Monitor"))
    }
  }
  return phase.value ?? false
}

#endif
