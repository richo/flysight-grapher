//
//  AerobaticView.swift
//  flysight-grapher
//
//  Created by richö butts on 5/6/20.
//  Copyright © 2020 richö butts. All rights reserved.
//


import SwiftUI
import SceneKit

struct AerobaticView: View, DataPresentable {
    @State var points = Array<Point3D>()
    @State var scene = ScenekitView()

    func loadData(_ data: DataSet) {
        let converted = convertData(data)
        self.scene.presentData(converted)
        points = converted
    }

    func clearData() {
// TODO(richo)
    }


    var body: some View {
        self.scene
    }
}

struct AerobaticView_Previews: PreviewProvider {
    static var previews: some View {
        AerobaticView()
    }
}

struct Point3D {
    let point: CGPoint
    let altitude: CGFloat
}

private let EARTH_RADIUS = 6371.0
// TODO(richo) The scale also needs to be worked out relative to altitude? We can *maybe* do something smart like at least normalise this to how far a given longitude line is
private let SCALE = 0.1
private func convertData(_ data: DataSet) -> Array<Point3D> {
    var offset_x = CGFloat(0.0)
    var offset_y = CGFloat(0.0)
    func convertPoint(_ point: DataPoint) -> Point3D {
      // We'll just naively lift everything into the positive domain and then treat them as being points on a large grid. Don't do aerobatics near the equator if you want accurate data.
      // There's for sure a universe in which we use our complete understanding of the point + altitude to construct these points in 3d space, but for now this is enough to test the hypothesis.
      var flat_x = point.position.longitude + 180
      var flat_y = point.position.latitude + 180

        var x = CGFloat(SCALE * flat_x);
        x -= offset_x;
        var y = CGFloat(SCALE * flat_y);
        y -= offset_y;

        return Point3D(point: CGPoint(x: x, y: y), altitude: CGFloat(point.altitude))
    }

    let first = convertPoint(data.data[0]);
    offset_x = first.point.x
    offset_y = first.point.y

    return data.data.map(convertPoint)
}

struct ScenekitView : UIViewRepresentable {
    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    func presentData(_ data: Array<Point3D>) {
        for point in data {
            let sphere = SCNSphere(radius: 0.1)
            sphere.firstMaterial?.diffuse.contents = UIColor.systemPink
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: Float(point.point.x), y: Float(point.altitude), z: Float(point.point.y))
            scene.rootNode.addChildNode(sphereNode)
        }
    }

    func makeUIView(context: Context) -> SCNView {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        scene.rootNode.addChildNode(sphereNode)

        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        // configure the view
        scnView.backgroundColor = UIColor.black
    }
}

#if DEBUG
struct ScenekitView_Previews : PreviewProvider {
    static var previews: some View {
        ScenekitView()
    }
}
#endif
