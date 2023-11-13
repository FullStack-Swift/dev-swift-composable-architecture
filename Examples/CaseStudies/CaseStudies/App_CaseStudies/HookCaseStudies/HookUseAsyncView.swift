import SwiftUI
import Combine

struct HookUseAsyncView: View {
  var body: some View {
    VStack {
      content
      contentOther
    }
    .navigationBarTitle(Text("Hook Async"), displayMode: .inline)
  }
  
  var content: some View {
    VStack {
      viewHUseAsync
      viewHUseThrowingAsync
      viewHUsePublisher
    }
  }
  
  var contentOther: some View {
    VStack {
      viewHUseAsync
      viewHUseThrowingAsync
      viewHUsePublisher
    }
  }
  
  var viewHUseAsync: some View {
    HookScope {
      
      @HState var state = false
      
      @HUseAsync(.preserved(by: state))
      var phase = blockBuilder { () -> Int in
        try? await Task.sleep(seconds: 2)
        return Int.random(in: 1...1000)
      }
      
      VStack {
        Toggle("Use HUseAsync", isOn: $state)
        viewBuilder {
          switch $phase.value {
            case .success(let value):
              Text(value.description)
            case .running:
              ProgressView()
            default:
              ProgressView()
          }
        }
        .frame(height: 50)
      }
      .padding()
      .alignment(.center)
    }
  }
  
  var viewHUseThrowingAsync: some View {
    HookScope {
      
      @HState var state = false
      
      @HUseThrowingAsync(.preserved(by: state))
      var phase = blockBuilder { () -> Int in
        try await Task.sleep(seconds: 2)
        return Int.random(in: 1...1000)
      }
      
      VStack {
        Toggle("Use HUseThrowingAsync", isOn: $state)
        viewBuilder {
          switch $phase.value {
            case .success(let value):
              Text(value.description)
            case .running:
              ProgressView()
            default:
              ProgressView()
          }
        }
        .frame(height: 50)
      }
      .padding()
      .alignment(.center)
    }
  }
  
  var viewHUsePublisher: some View {
    HookScope {
      @HState var state = false
      
      @HUsePublisher(.preserved(by: state))
      var phase = blockBuilder { () -> AnyPublisher<Int, Never> in
        Just(Int.random(in: 1...1000))
          .delay(for: 2, scheduler: DispatchQueue.main)
          .eraseToAnyPublisher()
      }

      VStack {
        Toggle("Use HUsePublisher", isOn: $state)
        viewBuilder {
          switch $phase.value {
            case .success(let value):
              Text(value.description)
            case .running:
              ProgressView()
            default:
              ProgressView()
          }
        }
        .frame(height: 50)
      }
      .padding()
      .alignment(.center)
    }
  }
  
}
#Preview {
  HookUseAsyncView()
}
