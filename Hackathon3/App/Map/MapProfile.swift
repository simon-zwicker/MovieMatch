//
//  MapProfile.swift
//  Hackathon3
//
//  Created by Mia Koring on 19.07.24.
//

import SwiftUI

struct MapProfile: View {
    let profile: Profile
    @State var favMovies: [FavouriteTMDBMovie] = []
    var body: some View {
        VStack {
            MeImage(name: profile.name, color: .blue)
            List {
                ForEach(favMovies, id: \.id) { movie in
                    FavouritesRow(movie: movie)
                }
            }
        }
        .padding(.top)
        .task {
            guard let favs = try? await Network.request(PocketBase<Favourite>.self, environment: .pock, endpoint: Pockethost.favourites).items else { return }
            
            let relevant = favs.first(where: {$0.profileID == profile.id})?.movieIDtmdb ?? ""
            let ids = Favourite.array(relevant)
            
            do {
                favMovies = []
                for id in ids {
                    let res = try await Network.request(FavouriteTMDBMovie.self, environment: .tmdb, endpoint: TmDB.specificMovie(id))
                    favMovies.append(res)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
