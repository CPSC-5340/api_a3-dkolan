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
    @Published var searchField: VillagersViewModel.SearchField = .name
    @Published var hasError = false
    @Published var error : VillagerModelError?
//    private let url = "https://acnhapi.com/v1a/villagers/"
    private let url = "https://api.nookipedia.com/villagers?api_key=b15ac011-8ba5-4d29-974b-97118f9df0dd"
    
    enum SearchField: String, CaseIterable {
        case name
        case personality
        case species
        var displayName: String {
            switch self {
            case .name: return "Name"
            case .personality: return "Personality"
            case .species: return "Species"
            }
        }
    }

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
//                self.villagersData = results.sorted { $0.name.nameUsEn < $1.name.nameUsEn}
                let newHorizonVillagers = results.filter { result in
                    return result.appearances.contains("NH")
                }
//                self.villagersData = results.sorted { $0.name < $1.name}
                self.villagersData = newHorizonVillagers.sorted { $0.name < $1.name}
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
            switch searchField {
            case .name:
//                res = villagersData.filter { $0.name.nameUsEn.lowercased().contains(searchText.lowercased()) }
                res = villagersData.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            case .personality:
                res = villagersData.filter { $0.personality.lowercased().contains(searchText.lowercased()) }
            case .species:
                res = villagersData.filter { $0.species.lowercased().contains(searchText.lowercased()) }
            }
        }
        return res
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
