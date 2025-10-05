//
//  View+Extensions.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import SwiftUI

extension View {
    /// Custom modifier to show error alerts
    func errorAlert(error: Binding<String?>) -> some View {
        self.alert("Error", isPresented: .constant(error.wrappedValue != nil), presenting: error.wrappedValue) { _ in
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: { errorMessage in
            Text(errorMessage)
        }
    }
    
    /// Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
