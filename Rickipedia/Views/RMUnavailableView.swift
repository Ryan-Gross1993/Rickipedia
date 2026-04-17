//
//  RMUnavailableView.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import SwiftUI

struct RMUnavailableView: View {
    let content: RMUnavailableContent

    var body: some View {
        ContentUnavailableView(content.title, systemImage: content.systemImage, description: Text(content.description))
    }
}
