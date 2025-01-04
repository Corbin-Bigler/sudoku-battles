import UIKit

extension UIImage {
    private func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data? {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            if let data = holderImage.jpegData(compressionQuality: 1.0) {
                let ratio = data.count / bytes
                if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                    complete = true
                    return data
                } else {
                    let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }

            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return nil
    }
    
    func cropToSquare() -> UIImage? {
        let originalWidth = size.width
        let originalHeight = size.height

        // Determine the shortest side to form the square
        let squareSize = min(originalWidth, originalHeight)

        // Calculate the x and y origin points to center the square
        let xOffset = (originalWidth - squareSize) / 2
        let yOffset = (originalHeight - squareSize) / 2

        let cropRect = CGRect(x: xOffset, y: yOffset, width: squareSize, height: squareSize)

        // Perform the cropping
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
