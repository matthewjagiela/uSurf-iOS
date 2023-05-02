//
//  BookmarkTableView.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/1/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//

import SwiftUI

struct BookmarkTableView: View {
    @ObservedObject var vm: BookmarkViewModel
    @State var searchText: String = ""
    var body: some View {
        HStack {
            Spacer()
            NavigationView {
                VStack {
                    List {
                        ForEach(vm.filteredBookmarks, id: \.self) { bookmark in
                            HStack {
                                AsyncImage(url: vm.getFavIconURL(webURL: bookmark.url))
                                    .frame(minWidth: 32, minHeight: 32)
                                
                                Text(bookmark.name)
                                    .padding(.leading, 10)
                            }
                        }
                    }.searchable(text: $searchText)
                        .onChange(of: searchText) { searchValue in
                            vm.filterBookmarks(searchText: searchValue)
                    }
                    
                    HStack { Spacer() }
                }.navigationTitle("Bookmarks")
            }.frame(width: 300)
            
        }
    }
}

struct BookmarkTableView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkTableView(vm: BookmarkViewModel(coreDataService: MockBookmarkDataFetcher()))
    }
}
