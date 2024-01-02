//
//  AtomLocalViewContextView.swift
//  CaseStudies
//
//  Created by PhongND on 1/2/24.
//

import SwiftUI

@MainActor
private let value = selectorState { context in
  return 0
}

@MainActor
private let readValue = selectorValue { context in
  return context.read(value)
  
}


struct AtomLocalViewContextView: View {
  
  @LocalViewContext
  var context
  
  @LocalWatchState(context: $context, value)
  var localWathState

  
  var body: some View {
    
    
    return VStack {
      Text(localWathState.description)
        .onTap {
          localWathState += 1
        }
      Text(context.watch(readValue).description)
      Text(context.read(readValue).description)
    }
  }
}

#Preview {
  AtomLocalViewContextView()
}
