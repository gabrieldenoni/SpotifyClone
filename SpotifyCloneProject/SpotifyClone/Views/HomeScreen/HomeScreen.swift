//
//  HomeScreen.swift
//  SpotifyClone
//
//  Created by Gabriel on 8/31/21.
//

// TODO: Reduce duplicated code
// TODO: Convert to arrays and render using ForEach
// TODO: Separate into different items

import SwiftUI

struct HomeScreen: View {
  @StateObject var homeViewModel: HomeViewModel

  var body: some View {
    RadialGradientBackground()

    if didEverySectionLoaded() == false {
      ProgressView().onAppear {
        homeViewModel.fetchHomeData()
      }
    } else {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading) {
          SmallSongCardsGrid(medias: getTracksFor(.userFavoriteTracks))
            .padding(.horizontal, lateralPadding)
            .padding(.bottom, paddingSectionSeparation)

          RecentlyPlayedScrollView(medias: getTracksFor(.recentlyPlayed))
            .padding(.bottom, paddingSectionSeparation)

          BigSongCoversScrollView(medias: getTracksFor(.newReleases),
                                  sectionTitle: HomeViewModel.Section.newReleases.rawValue)
            .padding(.bottom, paddingSectionSeparation)

          BigSongCoversScrollView(medias: getTracksFor(.topPodcasts),
                                  sectionTitle: HomeViewModel.Section.topPodcasts.rawValue)
            .padding(.bottom, paddingSectionSeparation)

          RecommendedArtistScrollView(medias: getTracksFor(.artistTopTracks),
                                      sectionTitle: HomeViewModel.Section.artistTopTracks.rawValue)
            .padding(.bottom, paddingSectionSeparation)

          Spacer(minLength: paddingBottomSection)
        }.padding(.vertical, lateralPadding)
      }
    }
  }

  func didEverySectionLoaded() -> Bool {
    for key in homeViewModel.isLoading.keys {
      // If any section still loading, return false
      guard homeViewModel.isLoading[key] != true else {
        return false
      }
    }
    // else, return true
    return true
  }

  func getTracksFor(_ section: HomeViewModel.Section) -> [SpotifyModel.MediaItem] {
    return !homeViewModel.isLoading[section.rawValue]! ? homeViewModel.medias[section.rawValue]! : []
  }

}



// MARK: - Constants

var lateralPadding: CGFloat = 25
var titleFontSize: CGFloat = 26
var paddingBottomSection: CGFloat = 135
var spacingSmallItems: CGFloat = 12
var spacingBigItems: CGFloat = 20

fileprivate var paddingSectionSeparation: CGFloat = 50

