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
    var body: some View {
        HStack {
            Spacer()
            NavigationView {
                VStack {
                    List {
                        ForEach(vm.bookmarks, id: \.self) { bookmark in
                            HStack {
                                AsyncImage(url: vm.getFavIconURL(webURL: bookmark.url)).frame(minWidth: 32, minHeight: 32)
                                Text(bookmark.name)
                                    .padding(.leading, 10)
                            }
                        }
                    }
                    HStack { Spacer() }
                }
            }.frame(width: 300)
            
        }
    }
}

struct BookmarkTableView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkTableView(vm: BookmarkViewModel(coreDataService: MockBookmarkDataFetcher()))
    }
}
