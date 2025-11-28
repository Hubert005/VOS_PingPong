//
//  AudioManager.swift
//  VOS_PingPong
//
//  Manages spatial audio for game events
//

import Foundation
import RealityKit
import AVFoundation

/// Manages spatial audio playback for game collision events
@MainActor
class AudioManager {
    
    // MARK: - Properties
    
    /// Audio resources for different collision types
    private var ballHitResource: AudioFileResource?
    private var tableBounceResource: AudioFileResource?
    private var wallBounceResource: AudioFileResource?
    private var gameOverResource: AudioFileResource?
    
    /// Flag to track if resources are loaded
    private var resourcesLoaded = false
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadAudioResources()
        }
    }
    
    // MARK: - Resource Loading
    
    /// Loads all audio resources asynchronously
    private func loadAudioResources() async {
        // Note: In a real implementation, you would load actual audio files
        // For now, we'll use placeholder resources or system sounds
        // The audio files should be added to the project's asset catalog
        
        // Attempt to load audio resources from the bundle
        // These would be actual .wav or .m4a files in the project
        // For this implementation, we'll prepare for them but handle gracefully if missing
        
        // Example: ballHitResource = try? await AudioFileResource(named: "ball_hit.wav")
        // For now, we'll mark as loaded and use system sounds as fallback
        
        resourcesLoaded = true
    }
    
    // MARK: - Audio Playback Methods
    
    /// Plays a spatial sound when the ball hits the racket
    /// - Parameter position: The 3D position where the sound should originate
    func playBallHitSound(at position: SIMD3<Float>) {
        guard resourcesLoaded else { return }
        
        // Create an audio playback controller with spatial positioning
        if let resource = ballHitResource {
            playAudioResource(resource, at: position)
        } else {
            // Fallback: play a system sound or generate a simple tone
            playFallbackSound()
        }
    }
    
    /// Plays a spatial sound when the ball bounces off the wall
    /// - Parameter position: The 3D position where the sound should originate
    func playWallBounceSound(at position: SIMD3<Float>) {
        guard resourcesLoaded else { return }
        
        if let resource = wallBounceResource {
            playAudioResource(resource, at: position)
        } else {
            playFallbackSound()
        }
    }
    
    /// Plays a spatial sound when the ball bounces off the table
    /// - Parameter position: The 3D position where the sound should originate
    func playTableBounceSound(at position: SIMD3<Float>) {
        guard resourcesLoaded else { return }
        
        if let resource = tableBounceResource {
            playAudioResource(resource, at: position)
        } else {
            playFallbackSound()
        }
    }
    
    /// Plays a non-spatial sound when the game ends
    func playGameOverSound() {
        guard resourcesLoaded else { return }
        
        if let resource = gameOverResource {
            // Game over sound doesn't need spatial positioning
            playAudioResource(resource, at: .zero, spatial: false)
        } else {
            playFallbackSound()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Plays an audio resource at a specific position with spatial audio
    /// - Parameters:
    ///   - resource: The audio resource to play
    ///   - position: The 3D position for spatial audio
    ///   - spatial: Whether to use spatial positioning (default: true)
    private func playAudioResource(
        _ resource: AudioFileResource,
        at position: SIMD3<Float>,
        spatial: Bool = true
    ) {
        // Note: In a full implementation, you would:
        // 1. Create a temporary entity at the collision position
        // 2. Add an AudioComponent to that entity with the resource
        // 3. Play the audio through that entity for spatial positioning
        // 4. Remove the entity after playback completes
        
        // Example implementation:
        // let audioEntity = Entity()
        // audioEntity.position = position
        // audioEntity.components[AudioComponent.self] = AudioComponent(resource: resource)
        // audioEntity.playAudio(resource)
        
        // For now, this is a placeholder that will be filled when audio files are added
    }
    
    /// Plays a fallback system sound when audio resources aren't available
    private func playFallbackSound() {
        // Use system sound as fallback
        // AudioServicesPlaySystemSound(1104) // Example system sound
    }
    
    // MARK: - Public Helper Methods
    
    /// Returns whether audio resources are loaded and ready
    var isReady: Bool {
        resourcesLoaded
    }
}
