/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom anchor for saving a snapshot image in an ARWorldMap.
*/

import ARKit

/// - Tag: SnapshotAnchor
class SnapshotAnchor: ARAnchor {
    
    let imageData: Data
    
    convenience init?(capturing view: ARSCNView) {
        guard let frame = view.session.currentFrame
            else { return nil }

        let rotation = atan2(view.transform.b, view.transform.a)
        print(rotation, view.transform.b, view.transform.a)
        
        let image = CIImage(cgImage: view.snapshot().cgImage!)
        let orientation = CGImagePropertyOrientation(cameraOrientation: UIDevice.current.orientation)

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let data = context.jpegRepresentation(of: image,
                                                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                    options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.7])
            else { return nil }
        
        self.init(imageData: data, transform: frame.camera.transform)
    }
    
    init(imageData: Data, transform: float4x4) {
        self.imageData = imageData
        super.init(name: "snapshot", transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.imageData = (anchor as! SnapshotAnchor).imageData
        super.init(anchor: anchor)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let snapshot = aDecoder.decodeObject(forKey: "snapshot") as? Data {
            self.imageData = snapshot
        } else {
            return nil
        }
        
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
    }

}
