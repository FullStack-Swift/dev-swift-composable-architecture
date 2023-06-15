@MainActor
internal struct AtomSubscription {
    let location: SourceLocation
    let requiresObjectUpdate: Bool
    let notifyUpdate: () -> Void
}
