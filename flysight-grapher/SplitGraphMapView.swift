//
//  SplitGraphMapView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/20/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI

struct SplitGraphMapView : View {
    var graph: GraphView
    var map: MapView
    
    var body: some View {
        VStack {
            map;
            graph;
        }

    }
}

//#if DEBUG
//struct SplitGraphMapView_Previews : PreviewProvider {
//    static var previews: some View {
//        SplitGraphMapView()
//    }
//}
//#endif
