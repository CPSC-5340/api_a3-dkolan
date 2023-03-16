//
//  VillagersListView.swift
//  Assignment3
//
//  Created by Dan Kolan on 3/16/23.
//

import SwiftUI

struct VillagersListView: View {
    @ObservedObject var villagersVM = VillagersViewModel()
    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(searchResults) { villager in
                NavigationLink {
                    VillagerDetail(villager: villager)
                } label: {
                    Text(villager.name.nameUsEn)
                }
            }
        }
        .task {
            await villagersVM.fetchData()
        }
        .listStyle(.grouped)
        .navigationTitle("Villagers")
        .alert(isPresented: $villagersVM.hasError, error: villagersVM.error) {
            Text("Error.")
        }
        .searchable(text: $searchText)
    }
    var searchResults: [VillagerModel] {
        if searchText.isEmpty {
            return villagersVM.villagersData
        } else {
            return villagersVM.villagersData.filter { $0.name.nameUsEn.contains(searchText) }
        }
    }
}

struct VillagersListView_Previews: PreviewProvider {
    static var previews: some View {
        VillagersListView()
    }
}
