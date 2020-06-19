
import UIKit
import SocketIO
import FRadioPlayer
import Foundation
import MediaPlayer
import AVFoundation

class AudioController: UIViewController, StreamDelegate{

    
    struct connectionStream {
          static var inp :InputStream?
          static var out :OutputStream?
      }
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    
    func getConnection(url: String) {
        print("playing \(url)")
        
        let addr = url
        let port = 8888

        Stream.getStreamsToHost(withName: addr, port: port, inputStream: &connectionStream.inp, outputStream: &connectionStream.out)

        inputStream = connectionStream.inp!
        outputStream = connectionStream.out!

        self.inputStream.delegate = self
        self.outputStream.delegate = self

        self.inputStream.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        self.outputStream.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)

        self.inputStream.open()
        self.outputStream.open()

        
    }
    
     func sendToHololens(_ messageValue : String) {

         let length_message = messageValue.count

         self.outputStream!.write(messageValue, maxLength: length_message)


     }
    
     func disconnect() {
         self.inputStream.close()
         self.outputStream.close()
     }
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
          if aStream === inputStream {
              switch eventCode {
                  case Stream.Event.hasBytesAvailable:
                    print("recieve bytes")
                    readStream()
                  default:
                      break
              }
          }
      }
    
    func readStream() {
        
        var buffer = [UInt8](repeating: 0, count: 1000)

        while (inputStream!.hasBytesAvailable) {
            
            let length = inputStream!.read(&buffer, maxLength: buffer.count)

            if (length > 0) {

                print("\(#file) > \(#function) > \(length) bytes read")
                print(buffer)


                let audioBuffer = bytesToAudioBuffer(buffer)
                playMusicFromBuffer(PCMBuffer: audioBuffer)
 
            }
        }
    }
    //Audio
    
    
    //Convert bytes to AVAudioPCMBuffer
    
    func bytesToAudioBuffer(_ buf: [UInt8]) -> AVAudioPCMBuffer {

         let fmt = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: true)
         let frameLength = UInt32(buf.count) / (fmt?.streamDescription.pointee.mBytesPerFrame)!

         let audioBuffer = AVAudioPCMBuffer(pcmFormat: fmt!, frameCapacity: frameLength)
         audioBuffer!.frameLength = frameLength

         let dstLeft = audioBuffer?.floatChannelData![0]

         buf.withUnsafeBufferPointer {
             let src = UnsafeRawPointer($0.baseAddress!).bindMemory(to: Float.self, capacity: Int(frameLength))
             dstLeft!.initialize(from: src, count: Int(frameLength))
         }
         print("Convert to AVAudioPCMBuffer")

         return audioBuffer!
     }
    
    
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var audioFilePlayer: AVAudioPlayerNode = AVAudioPlayerNode()

    func playMusicFromBuffer(PCMBuffer: AVAudioPCMBuffer) {

        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioFilePlayer)
        audioEngine.connect(audioFilePlayer, to:mainMixer, format: PCMBuffer.format)
        try? audioEngine.start()
        audioFilePlayer.play()
        audioFilePlayer.scheduleBuffer(PCMBuffer, at: nil, options:AVAudioPlayerNodeBufferOptions.loops)
    }

    
    /*
    func playMusic(url: URL) {

        guard let filePath: String = Bundle.main.path(forResource: "myMusic", ofType: "mp3") else{ return }
        print("\(filePath)")
        let fileURL: URL = URL(fileURLWithPath: filePath)
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else{ return }

        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(audioFrameCount))  else{ return }
        do{
            try audioFile.read(into: audioFileBuffer)
        } catch{
            print("over")
        }
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioFilePlayer)
        audioEngine.connect(audioFilePlayer, to:mainMixer, format: audioFileBuffer.format)
        try? audioEngine.start()
        audioFilePlayer.play()
        audioFilePlayer.scheduleBuffer(audioFileBuffer, at: nil, options:AVAudioPlayerNodeBufferOptions.loops)
    }
    */
    
    
}
