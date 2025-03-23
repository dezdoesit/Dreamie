// DreamViewModel.swift
import Foundation
import Speech
import SwiftUI

@MainActor
@Observable
class DreamViewModel {
    private let storageService = DreamStorageService()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var dreamEntries: [DreamEntry] = []
    var currentDream = DreamEntry()
    var isRecording = false
    var transcribedText = ""
    var recordingStatus = "Tap to start recording"
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    var dreamsGroupedByDay: [Date: [DreamEntry]] {
             Dictionary(grouping: dreamEntries) { dream in
                 Calendar.current.startOfDay(for: dream.date)
             }
         }
    
    init() {
        Task {
            await requestSpeechAuthorization()
            await loadDreams()
        }
    }
    
    func loadDreams() async {
        do {
            dreamEntries = try await storageService.loadDreams()
        } catch {
            print("Error loading dreams: \(error)")
        }
    }
    
    func saveDream() async {
        guard !transcribedText.isEmpty else { return }
        
        let newDream = DreamEntry(
            title: currentDream.title.isEmpty ? "Dream \(Date().formatted(date: .abbreviated, time: .shortened))" : currentDream.title,
            content: transcribedText,
            date: Date()
        )
        
        do {
            try await storageService.saveDream(newDream)
            await loadDreams()
            resetCurrentDream()
        } catch {
            print("Error saving dream: \(error)")
        }
    }
    
    func deleteDream(at indexSet: IndexSet) {
        Task {
            for index in indexSet {
                let id = dreamEntries[index].id
                do {
                    try await storageService.deleteDream(with: id)
                } catch {
                    print("Error deleting dream: \(error)")
                }
            }
            await loadDreams()
        }
    }
    
    func resetCurrentDream() {
        currentDream = DreamEntry()
        transcribedText = ""
    }
    
    private func requestSpeechAuthorization() async {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                self.authorizationStatus = status
                continuation.resume()
            }
        }
    }
    
    func toggleRecording() async {
        if isRecording {
            await stopRecording()
        } else {
            await startRecording()
        }
    }
    
    private func startRecording() async {
        guard !isRecording else { return }
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            recordingStatus = "Speech recognition not available"
            return
        }
        
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
                if error != nil {
                    Task{ @MainActor in
                        await self.stopRecording()
                        
                    }
                }
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            recordingStatus = "Recording... Tap to stop"
        } catch {
            print("Error starting recording: \(error)")
            recordingStatus = "Recording failed: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() async {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
        recordingStatus = "Tap to start recording"
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
    }
    func deleteDream(withId id: UUID) {
            Task {
                do {
                    try await storageService.deleteDream(with: id)
                    await loadDreams()
                } catch {
                    print("Error deleting dream: \(error)")
                }
            }
        }
}
