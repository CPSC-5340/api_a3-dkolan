//
//  VillagersViewModel.swift
//  Assignment3
//
//  Created by Dan Kolan on 3/15/23.
//

import Foundation

class VillagersViewModel : ObservableObject {
    @Published private(set) var villagersData = [VillagerModel]()
    @Published var searchText: String = ""
    @Published var selectedFilter: String = ""
    @Published var hasError = false
    @Published var error : VillagerModelError?
    private let url = "https://acnhapi.com/v1a/villagers/"
    
    @MainActor
    func fetchData() async {
        if let url = URL(string: self.url) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let results = try JSONDecoder().decode([VillagerModel]?.self, from: data) else {
                    self.hasError.toggle()
                    self.error = VillagerModelError.decodeError
                    return
                }
                self.villagersData = results.sorted { $0.name.nameUsEn < $1.name.nameUsEn}
            } catch {
                self.hasError.toggle()
                self.error = VillagerModelError.customError(error: error)
            }
        }

    }

    var searchResults: [VillagerModel] {
        var res: [VillagerModel]
        if searchText.isEmpty {
            res = villagersData
        } else {
            res = villagersData.filter { $0.name.nameUsEn.contains(searchText) }
        }

        if !selectedFilter.isEmpty {
            res = res.filter { $0.species == selectedFilter }
        }

        return res
    }

    func filterSpecies(by: VillagerSpecies?) {
        if let species = by {
            selectedFilter = species.rawValue
        } else {
            selectedFilter = ""
        }
    }

    enum VillagerSpecies: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case Alligator, Anteater, Bear, Bird, Bull, Cat, Chicken, Cow, Cub, Deer, Dog, Duck, Eagle, Elephant, Frog, Goat, Gorilla, Hamster, Hippo, Horse, Kangaroo, Koala, Lion, Monkey, Mouse, Octopus, Ostrich, Penguin, Pig, Rabbit, Rhino, Sheep, Squirrel, Tiger, Wolf
    }
}

extension VillagersViewModel {
    enum VillagerModelError : LocalizedError {
        case decodeError
        case customError(error: Error)
        
        var errorDescription: String? {
            switch self {
            case .decodeError:
                return "Decoding error."
            case .customError(let error):
                return error.localizedDescription
                
            }
        }
    }
}
