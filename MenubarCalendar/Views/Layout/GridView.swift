//
//  GridView.swift
//  MenubarCalendar
//
//  Created by listennn on 2021/9/25.
//

import SwiftUI

/// Calendar body of dates
struct GridView<Content: View, T: Hashable>: View {
    private let columns: Int
    private var list: [[T]] = []
    private let content: (T) -> Content
    
    init(columns: Int, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.columns = columns
        self.content = content
        self.setupList(list)
    }
    
    private mutating func setupList(_ list: [T]) {
        var column = 0
        var columnIndex = 0
        
        for object in list {
            if columnIndex < self.columns {
                if columnIndex == 0 {
                    self.list.insert([object], at: column)
                    columnIndex += 1
                } else {
                    self.list[column].append(object)
                    columnIndex += 1
                }
            } else {
                column += 1
                self.list.insert([object], at: column)
                columnIndex = 1
            }
        }
    }
    
    var body: some View {
        VStack() {
            ForEach(0 ..< self.list.count, id: \.self) { i in
                HStack(spacing: 24.0) {
                    ForEach(self.list[i], id: \.self) { object in
                        self.content(object)
                            .frame(width: 32)
                    }
                }
                .padding([.leading, .bottom, .trailing], 5.0)
                .frame(width: 400.0)
            }
            Spacer()
        }
    }
    
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(columns: 7, list: Array(1...30)) { item in
            Text(String(item))
        }
    }
}
