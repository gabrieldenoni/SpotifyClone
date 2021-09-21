//
//  BigSongCoverScrollView.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/3/21.
//

import SwiftUI

struct BigSongCoversScrollView: View {
  @StateObject var homeViewModel: HomeViewModel
  let section: HomeViewModel.Section
  var sectionTitle = ""
  var medias: [SpotifyModel.MediaItem] {
    homeViewModel.medias[section.rawValue]!
  }

  
  var body: some View {
    VStack(spacing: spacingSmallItems) {
      Text(sectionTitle.isEmpty ? section.rawValue : sectionTitle)
        .spotifyTitle(withPadding: true)
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(alignment: .top,spacing: spacingBigItems) {
          ForEach(medias) { media in
            BigSongItem(imageURL: media.imageURL,
                        title: media.title,
                        artist: "",
                        isArtistProfile: media.isArtist,
                        isPodcast: media.isPodcast)
              .onAppear {
                if medias.count > 6 {
                  if media.id == medias[medias.count - 4].id {
                    homeViewModel.fetchDataFor(section,
                                               with: homeViewModel.mainViewModel.authKey!.accessToken,
                                               loadingMore: true)
                  }
                }
              }
          }
        }.padding(.horizontal, 25)
      }
    }
  }
}
