//
//  APIFetchingDataSearchPage.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/20/21.
//

import Foundation
import Alamofire

class APIFetchingDataSearchPage: ObservableObject {

  // TODO: Add support for all media types
  func search(for searchTerm: String, accessToken: String,
              completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void) {

    // Do not separate with spaces.
    let type = "track,playlist,album,artist,show,episode"
    let baseUrl = "https://api.spotify.com/v1/search?q=\(searchTerm)&type=\(type)"

    var urlRequest = URLRequest(url: URL(string: baseUrl)!)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    urlRequest.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad

    var mediaItems = [SpotifyModel.MediaItem]()

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: SearchEndpointResponse.self) { response in

        guard let data = response.value else {
          fatalError("Error receiving tracks from API.")
        }

        if data.tracks != nil {
          parseTracks(response.value!.tracks!)
        }

        if data.playlists != nil {
          parsePlaylists(response.value!.playlists!)
        }

        if data.albums != nil {
          parseAlbums(response.value!.albums!)
        }

        if data.artists != nil {
          parseArtists(response.value!.artists!)
        }

      }



    // MARK: - Tracks
    func parseTracks(_ data: SearchEndpointResponse.TrackSearchResponse) {

      let numberOfTracks = data.items.count

      // TODO: Handle empty responses in a better way
      guard numberOfTracks != 0 else {
        completionHandler(mediaItems)
        print("The API response was corrects but empty. We'll just return []")
        return
      }

      for trackIndex in 0 ..< numberOfTracks {
        let title = data.items[trackIndex].name
        let previewURL = data.items[trackIndex].preview_url
        let author = data.items[trackIndex].artists
        let id = data.items[trackIndex].id
        var authorName = [String]()

        let popularity = data.items[trackIndex].popularity
        let explicit = data.items[trackIndex].explicit
        let durationInMs = data.items[trackIndex].duration_ms

        let imageURL = data.items[trackIndex].album?.images?[0].url
        let albumName = data.items[trackIndex].album?.name
        let albumID = data.items[trackIndex].album?.id
        let numberOfTracks = data.items[trackIndex].album?.total_tracks
        let releaseDate = data.items[trackIndex].album?.release_date

        for artistIndex in data.items[trackIndex].artists.indices {
          authorName.append(data.items[trackIndex].artists[artistIndex].name)
        }

        let trackItem = SpotifyModel
          .MediaItem(title: title,
                     previewURL: previewURL ?? "",
                     imageURL: imageURL ?? "",
                     authorName: authorName,
                     author: author,
                     mediaType: .track,
                     id: id,
                     details: SpotifyModel.DetailTypes.tracks(
                      trackDetails: SpotifyModel.TrackDetails(popularity: popularity ?? 0,
                                                              explicit: explicit,
                                                              durationInMs: durationInMs,
                                                              id: id,
                                                              album: SpotifyModel.AlbumDetails(name: albumName ?? "",
                                                                                               numberOfTracks: numberOfTracks ?? 0,
                                                                                               releaseDate: releaseDate ?? "0",
                                                                                               id: albumID ?? ""))))
        mediaItems.append(trackItem)
      }
      completionHandler(mediaItems)
    }

    // MARK: - Playlists
    func parsePlaylists(_ data: SearchEndpointResponse.PlaylistSearchResponse) {

      let numberOfPlaylists = data.items.count

      // TODO: Handle empty responses in a better way
      guard numberOfPlaylists != 0 else {
        completionHandler(mediaItems)
        print("The API response was corrects but empty. We'll just return []")
        return
      }

      for playlistIndex in 0 ..< numberOfPlaylists {
        let title = data.items[playlistIndex].name
        let imageURL = data.items[playlistIndex].images[0].url
        let id = data.items[playlistIndex].id

        let description = data.items[playlistIndex].description
        let playlistTracks = data.items[playlistIndex].tracks
        let mediaOwner = data.items[playlistIndex].owner

        let playlistItem = SpotifyModel.MediaItem(title: title,
                                                  previewURL: "",
                                                  imageURL: imageURL,
                                                  authorName: [mediaOwner.display_name],
                                                  mediaType: .playlist,
                                                  id: id,
                                                  details: SpotifyModel.DetailTypes.playlists(
                                                    playlistDetails: SpotifyModel.PlaylistDetails(description: description,
                                                                                                  playlistTracks: SpotifyModel.PlaylistTracks(numberOfSongs: playlistTracks.total,
                                                                                                                                              href: playlistTracks.href),
                                                                                                  owner: SpotifyModel.MediaOwner(displayName: mediaOwner.display_name,
                                                                                                                                 id: mediaOwner.id),
                                                                                                  id: id)))
        mediaItems.append(playlistItem)
      }
      completionHandler(mediaItems)
    }

    // MARK: - Playlists
    func parseAlbums(_ data: SearchEndpointResponse.AlbumSearchResponse) {

      let numberOfAlbums = data.items.count

      // TODO: Handle empty responses in a better way
      guard numberOfAlbums != 0 else {
        completionHandler(mediaItems)
        print("The API response was corrects but empty. We'll just return []")
        return
      }

      for albumIndex in 0 ..< numberOfAlbums {
        let title = data.items[albumIndex].name
        let imageURL = data.items[albumIndex].images?[0].url
        let author = data.items[albumIndex].artists
        let id = data.items[albumIndex].id
        var authorName = [String]()

        let albumID = data.items[albumIndex].id
        let numberOfTracks = data.items[albumIndex].total_tracks
        let releaseDate = data.items[albumIndex].release_date

        for artistIndex in data.items[albumIndex].artists.indices {
          authorName.append(data.items[albumIndex].artists[artistIndex].name)
        }

        let albumItem = SpotifyModel.MediaItem(title: title,
                                               previewURL: "",
                                               imageURL: imageURL ?? "",
                                               authorName: authorName,
                                               author: author,
                                               mediaType: .album,
                                               id: id,
                                               details: SpotifyModel.DetailTypes.album(albumDetails: SpotifyModel.AlbumDetails(name: title,
                                                                                                                               numberOfTracks: numberOfTracks,
                                                                                                                               releaseDate: releaseDate,
                                                                                                                               id: albumID)))

        mediaItems.append(albumItem)
      }
      completionHandler(mediaItems)
    }

    // MARK: - Artists
    func parseArtists(_ data: SearchEndpointResponse.ArtistSearchResponse) {

      let numberOfArtists = data.items.count

      // TODO: Handle empty responses in a better way
      guard numberOfArtists != 0 else {
        completionHandler(mediaItems)
        print("The API response was corrects but empty. We'll just return []")
        return
      }

      for artistIndex in 0 ..< numberOfArtists {
        let title = data.items[artistIndex].name
        let id = data.items[artistIndex].id

        let followers = data.items[artistIndex].followers!.total
        let genres = data.items[artistIndex].genres
        let popularity = data.items[artistIndex].popularity

        var imageURL: String {
          if data.items[artistIndex].images != nil {
            return data.items[artistIndex].images!.count > 0 ? data.items[artistIndex].images![0].url : ""
          }
          return "" // TODO: Return a avatar placeholder image
        }

        let artistItem = SpotifyModel.MediaItem(title: title,
                                                previewURL: "",
                                                imageURL: imageURL,
                                                authorName: [title],
                                                mediaType: .artist,
                                                id: id,
                                                details: SpotifyModel.DetailTypes.artists(artistDetails: SpotifyModel.ArtistDetails(followers: followers,
                                                                                                                                    genres: genres!,
                                                                                                                                    popularity: popularity!,
                                                                                                                                    id: id)))
        mediaItems.append(artistItem)
      }
      completionHandler(mediaItems)
    }

  }










  // TODO: Separate this func into a different file

  func getPlaylists(accessToken: String,
                    completionHandler: @escaping ([SpotifyModel.PlaylistItem]) -> Void) {

    let country = "US"
    let limit = 10

    let baseUrl = "https://api.spotify.com/v1/browse/featured-playlists?country=\(country)&limit=\(limit)"

    var urlRequest = URLRequest(url: URL(string: baseUrl)!)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    urlRequest.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: PlaylistResponse.self) { response in
        guard let data = response.value else {
          fatalError("Error receiving playlists from API.")
        }

        let numberOfPlaylists = data.playlists.items.count

        var playlists = [SpotifyModel.PlaylistItem]()

        guard numberOfPlaylists != 0 else {
          fatalError("The API response was corrects but empty. We don't have a way to handle this yet.")
        }

        for index in 0 ..< numberOfPlaylists {
          let sectionTitle = data.message
          let name = data.playlists.items[index].name
          let imageURL = data.playlists.items[index].images[0].url
          let id = data.playlists.items[index].id

          let playlistItem = SpotifyModel.PlaylistItem(sectionTitle: sectionTitle ?? "Playlist",
                                                       name: name,
                                                       imageURL: imageURL,
                                                       id: id)
          playlists.append(playlistItem)
        }
        completionHandler(playlists)
      }

  }

}