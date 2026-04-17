//
//  RMCharacterDetailRow.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import SwiftUI

struct RMCharacterDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.rmTextSecondary)
            Text(value)
                .font(.body)
                .foregroundStyle(Color.rmTextPrimary)
        }
    }
}
