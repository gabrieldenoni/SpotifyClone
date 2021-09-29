//
//  BackButton.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/25/21.
//

import SwiftUI

struct BackButton: View {
  var homeViewModel: HomeViewModel

  var body: some View {
    VStack {
      HStack {
        Image("down-arrow")
          .resizeToFit()
          .rotationEffect(Angle.degrees(90))
        Spacer()
      }
      .frame(height: 20)
      .onTapGesture {
        homeViewModel.goToNoneSubpage()
      }
    }
  }
}