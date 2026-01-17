import AppKit
import CoreGraphics

func makeTransparent(inputPath: String, outputPath: String) {
    guard let image = NSImage(contentsOfFile: inputPath) else {
        print("Error: Could not load image at \(inputPath)")
        exit(1)
    }
    
    var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    guard let cgImage = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
        print("Error: Could not create CGImage")
        exit(1)
    }
    
    let width = cgImage.width
    let height = cgImage.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
    
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("Error: Could not create CGContext")
        exit(1)
    }
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let buffer = context.data else {
        print("Error: No data in context")
        exit(1)
    }
    
    let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
    
    for y in 0..<height {
        for x in 0..<width {
            let offset = (y * width + x) * bytesPerPixel
            let r = pixelBuffer[offset]
            let g = pixelBuffer[offset + 1]
            let b = pixelBuffer[offset + 2]
            
            // Check if pixel is "white" (R, G, B > 240)
            if r > 240 && g > 240 && b > 240 {
                pixelBuffer[offset] = 0
                pixelBuffer[offset + 1] = 0
                pixelBuffer[offset + 2] = 0
                pixelBuffer[offset + 3] = 0 // Transparent
            }
        }
    }
    
    guard let outputCgImage = context.makeImage() else {
        print("Error: Could not create output CGImage")
        exit(1)
    }
    
    let newImage = NSImage(cgImage: outputCgImage, size: NSSize(width: width, height: height))
    
    guard let tiffData = newImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Error: Could not convert to PNG")
        exit(1)
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("Success: Saved transparent image to \(outputPath)")
    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

let args = CommandLine.arguments
if args.count < 3 {
    print("Usage: TransparentMaker <input> <output>")
    exit(1)
}

makeTransparent(inputPath: args[1], outputPath: args[2])
