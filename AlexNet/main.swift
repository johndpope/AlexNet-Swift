import TensorFlow
import Foundation

//let arguments = CommandLine.arguments
//guard (arguments.count > 2) else { fatalError("Usage: AlexNet [image directory] [weights directory]") }
//let imageDirectory = arguments[1]
//let weightsDirectory = arguments[2]
let imageDirectory = "images"
let weightsDirectory = "weights"

//let batchSize: Int32 = 60
//let classCount = 2
//let fakeImageBatch = Tensor<Float>(zeros: [batchSize, 227, 227, 3])
//let fakeLabelBatch = Tensor<Int32>(zeros: [batchSize])

// Load image dataset
let trainingImageDirectoryURL = URL(fileURLWithPath:"\(imageDirectory)/train")
let trainingImageDataset = try! ImageDataset(imageDirectory: trainingImageDirectoryURL, imageSize: (227, 227))
let classCount = trainingImageDataset.classes
let batchSize = trainingImageDataset.imageData.shape[0]
let validationImageDirectoryURL = URL(fileURLWithPath:"\(imageDirectory)/val")
let validationImageDataset = try! ImageDataset(imageDirectory: validationImageDirectoryURL, imageSize: (227, 227))
print("Dataset classes: \(trainingImageDataset.classes), labels: \(trainingImageDataset.labels)")

// Initialize network
let weightsDirectoryURL = URL(fileURLWithPath:weightsDirectory)
let learningPhaseIndicator = LearningPhaseIndicator()
var alexNet = try! AlexNet(classCount: classCount, learningPhaseIndicator: learningPhaseIndicator, weightDirectory: weightsDirectoryURL)

// Train
let optimizer = SGD<AlexNet, Float>(learningRate: 0.001, momentum: 0.9)
let validationInterval = 10

print("Start of training process")

let startTime = NSDate()
for epochNumber in 0..<220 {
    var currentLoss = Tensor<Float>(zeros: [1])
    let gradients = gradient(at: alexNet) { model -> Tensor<Float> in
        currentLoss = loss(model: model, images: trainingImageDataset.imageData, labels: trainingImageDataset.imageLabels)
        return currentLoss
    }
    let currentTrainingAccuracy = accuracy(model: alexNet, images: trainingImageDataset.imageData, labels: trainingImageDataset.imageLabels)

    optimizer.update(&alexNet.allDifferentiableVariables, along: gradients)
    print("Completed epoch \(epochNumber), loss: \(currentLoss), training accuracy: \(currentTrainingAccuracy)")

    if ((epochNumber % validationInterval) == 0) {
        let currentValidationAccuracy = accuracy(model: alexNet, images: validationImageDataset.imageData, labels: validationImageDataset.imageLabels)
        print("Validation accuracy: \(currentValidationAccuracy)")
    }
}
let endTime = -startTime.timeIntervalSinceNow

print("End of training process, took \(endTime)s")
