//
//  BookmarkTableView.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/1/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//

import SwiftUI

struct BookmarkTableView: View {
    var body: some View {
        HStack {
            Spacer()
            NavigationView {
                VStack {
                    ScrollView {
                        Text("World")
                        Text("World")
                        Text("World")
                        Text("World")
                        Text("World")
                        Text("World")
                        Text("World")
                    }
                    HStack { Spacer() }
                }.background(Color.gray)
            }.frame(width: 300)
            
        }
    }
}

struct BookmarkTableView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkTableView()
    }
}
