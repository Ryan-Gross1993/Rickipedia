//
//  RMImageRetryView.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/16/26.
//

import SwiftUI

struct RMImageRetryView: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.rmSurface

            VStack(spacing: 6) {
                Image(systemName: "arrow.trianglehead.clockwise")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.rmPortalGreen)
                    .rotationEffect(.degrees(isPulsing ? 360 : 0))
                    .animation(
                        .linear(duration: 1.2).repeatForever(autoreverses: false),
                        value: isPulsing
                    )

                Text("Retrying")
                    .font(.caption2)
                    .foregroundStyle(Color.rmTextSecondary)
            }
        }
        .onAppear {
            isPulsing = true
        }
    }
}
