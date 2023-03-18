//
//  FilterRowView.swift
//  Assignment3
//
//  Created by Dan Kolan on 3/17/23.
//

import SwiftUI

struct FilterRowView<T>: View
    where T: RawRepresentable, T: CaseIterable, T: Identifiable, T.AllCases == [T], T.RawValue == String {

    let block: (T) -> Void
    @State private var selectedFilter: T? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 15) {
                ForEach(T.allCases) { filter in
                    Button(action: {
                        withAnimation(Animation.spring().speed(1.5)) {
                            selectedFilter = filter
                        }
                        if let filterValue = selectedFilter {
                            block(filterValue)
                        }
                    }) {
                        Text(filter.rawValue.capitalized)
                            .font(.subheadline)
                    }
                    .buttonStyle(FilterButtonStyle(
                        isSelected: selectedFilter == nil && filter == T.allCases[0]
                            ? false
                            : (selectedFilter != nil && selectedFilter! == filter)
                    ))
                }
            }
        }
        .frame(height: 40)
    }
}

// Using Villager species to test component
struct FilterRowView_Previews: PreviewProvider {
    @ObservedObject static var villagersVM = VillagersViewModel()
    static var previews: some View {
        FilterRowView<VillagersViewModel.VillagerSpecies>(block: { species in
            villagersVM.filterSpecies(by: species)
        })
    }
}


struct FilterButtonStyle: ButtonStyle {

    let isSelected: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(
        isSelected ? .white : .black
      )
      .padding()
      .frame(maxWidth: .infinity, maxHeight: 30)
      .background(
        isSelected ? .black : .white
      )
      .cornerRadius(24)
      .overlay(
        RoundedRectangle(cornerRadius: 24)
            .stroke(isSelected ? .white : .black, lineWidth: 0.3)
      )
  }
}
