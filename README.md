# dev-swift-composable-architecture
A library for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind.

[swift composable architecture](https://github.com/pointfreeco/swift-composable-architecture)

# ``DocC``

### Generating Documentation for Extended Types


```
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target ComposableArchitecture --output-path ./docs
```

```
swift package --disable-sandbox preview-documentation --target ComposableArchitecture
```

### Publishing to GitHub Pages

```
sudo swift package --allow-writing-to-directory ./docs \
    generate-documentation --target ComposableArchitecture \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path ComposableArchitecture \
    --output-path ./docs
```
