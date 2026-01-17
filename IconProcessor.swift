import AppKit

func processImage(inputPath: String, outputPath: String) {
    guard let image = NSImage(contentsOfFile: inputPath) else {
        print("Error: Could not load image at \(inputPath)")
        exit(1)
    }
    
    let size = NSSize(width: 1024, height: 1024)
    let outputImage = NSImage(size: size)
    
    outputImage.lockFocus()
    
    // Create Rounded Path (Squircle-ish)
    // macOS Big Sur style is roughly a rect with corner radius ~22% of width
    let rect = NSRect(origin: .zero, size: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: 225, yRadius: 225)
    path.addClip()
    
    // Draw original image filling the rect
    image.draw(in: rect, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1.0)
    
    outputImage.unlockFocus()
    
    // Save to PNG
    guard let tiffData = outputImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Error: Could not convert to PNG")
        exit(1)
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("Success: Saved masked icon to \(outputPath)")
    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

let args = CommandLine.arguments
if args.count < 3 {
    print("Usage: IconProcessor <input> <output>")
    exit(1)
}

processImage(inputPath: args[1], outputPath: args[2])
