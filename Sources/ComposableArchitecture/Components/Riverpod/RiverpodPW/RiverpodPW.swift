// MARK: Expect with Riverpod review overview function in riverpod.
///
///
//MARK: FUNCION RIVERPOD
///
///create basic function riverpod
/// ```swift
///@riverpod
///func items() async -> Data {
/// let data = await ...
/// return data
///}
/// ```
///create basic function with param
///```swift
///func items(params: Param) async -> Data {
/// let data = await ...
/// return data
///}
///```
/// create basic function with context
///```swift
///@riverpod
///func items(context: Context) async -> Data {
/// let data = await ...
/// return data
///}
///```
///create basic function with parram and context
///```swift
///@riverpod
///func items(param, context: Context) async -> Data {
/// let data = await ...
/// return data
///}
///
///```
///
//MARK: VARIABLE RIVERPOD
///
///create basic variable riverpod
///```swift
///@riverpod
///var count = 0
///```
///
///create basic variable with param
///```swift
///@priverpod(params: [String])
///var count = riverpodPrams { params in
/// prams.count
///}
///```
///create basic variable with context
///```swift
///@riverpod
///var count = riverpodContext { context in
/// // Todo something with context
///}
///```
///create basic variable with param and context
///```swift
///@riverpod
///var count = riverpodBuilder { context, params in
/// // Todo something with context and params
///}
///```
///
// MARK: View Implementation.
///
///view implement
///```swift
///struct AnyView: ConsumerView {
///   func build(context: Context) -> some View {
///   let data = context.watch(boredSugestion)
///     return ...
///   }
///}
///```
///
///```swift
///struct AnyView: View {
///  var body: some View {
///    RiverpodScope { context in
///
///    }
///  }
///}
///```
///
///```swift
///struct AnyView: View {
///
///  @RiverpodContext
///  var context
///
///  var body: some View {
///  }
///}
