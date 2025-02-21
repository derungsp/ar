//
//  ContentView.swift
//  business-card
//
//  Created by Pascal Derungs on 21.02.2025.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        guard let referenceImage = UIImage(named: "visitenkarte") else {
            fatalError("Visitenkarte image not found")
        }
        let referenceImageAnchor = ARReferenceImage(referenceImage.cgImage!, orientation: .up, physicalWidth: 0.1)
        configuration.detectionImages = [referenceImageAnchor]
        
        arView.session.run(configuration)
        
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        weak var arView: ARView?

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let arView = arView else { return }

            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    let anchorEntity = AnchorEntity(anchor: imageAnchor)
                    
                    let websiteLink = createTextEntity(text: "Website", color: .blue)
                    websiteLink.position = [0, 0.05, 0]
                    anchorEntity.addChild(websiteLink)
                    
                    let instagramLink = createTextEntity(text: "Instagram", color: .purple)
                    instagramLink.position = [0, 0.1, 0]
                    anchorEntity.addChild(instagramLink)
                    
                    let linkedinLink = createTextEntity(text: "LinkedIn", color: .blue)
                    linkedinLink.position = [0, 0.15, 0]
                    anchorEntity.addChild(linkedinLink)
                    
                    arView.scene.addAnchor(anchorEntity)
                }
            }
        }
        
        private func createTextEntity(text: String, color: UIColor) -> Entity {
            let mesh = MeshResource.generateText(text, extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
            let material = SimpleMaterial(color: color, isMetallic: false)
            let model = ModelEntity(mesh: mesh, materials: [material])
            return model
        }
    }
}

#Preview {
    ContentView()
}
