/**
 * Audio Monitoring Module
 * Detects background noise, speech, and suspicious audio patterns
 * Uses Web Audio API for real-time audio analysis
 */

class AudioMonitoringModule {
  constructor(parentWrapper) {
    this.wrapper = parentWrapper;
    this.isMonitoring = false;
    this.audioContext = null;
    this.analyser = null;
    this.dataArray = null;
    this.analysisInterval = null;
    this.consecutiveNoiseFrames = 0;
    this.noiseThreshold = 35; // dB - adjust based on testing
    this.noiseDetectionThreshold = 3; // Consecutive frames
    this.micStream = null;
  }

  /**
   * Initialize audio module
   */
  async initialize(micStream) {
    try {
      console.log('🎤 Initializing Audio Monitoring...');

      this.micStream = micStream;

      // Create audio context
      const audioContext = new (window.AudioContext || window.webkitAudioContext)();
      this.audioContext = audioContext;

      // Create analyser node
      const source = audioContext.createMediaStreamSource(micStream);
      this.analyser = audioContext.createAnalyser();
      this.analyser.fftSize = 256;
      source.connect(this.analyser);

      // Create data array for frequency data
      const bufferLength = this.analyser.frequencyBinCount;
      this.dataArray = new Uint8Array(bufferLength);

      console.log('✅ Audio Module Ready');
    } catch (error) {
      console.error('❌ Audio Module Error:', error);
      throw error;
    }
  }

  /**
   * Start audio monitoring
   */
  startMonitoring() {
    if (this.isMonitoring) return;

    console.log('🔊 Starting Audio Monitoring...');
    this.isMonitoring = true;

    this.analysisInterval = setInterval(() => {
      this.analyzeAudio();
    }, 500); // Check every 500ms
  }

  /**
   * Analyze audio frequency data
   */
  analyzeAudio() {
    if (!this.isMonitoring || !this.analyser) return;

    try {
      // Get frequency data
      this.analyser.getByteFrequencyData(this.dataArray);

      // Calculate average frequency magnitude
      const average = this.dataArray.reduce((a, b) => a + b) / this.dataArray.length;

      // Convert to decibels
      const db = 20 * Math.log10(average / 255 + 0.0001);

      // Detect noise/speech
      this.processAudioAnalysis(db, average);
    } catch (error) {
      console.error('Audio analysis error:', error);
    }
  }

  /**
   * Process audio analysis results
   */
  processAudioAnalysis(db, magnitude) {
    // Check if noise/speech detected
    if (magnitude > this.noiseThreshold) {
      this.consecutiveNoiseFrames++;

      if (this.consecutiveNoiseFrames === this.noiseDetectionThreshold) {
        console.warn('⚠️ Suspicious audio detected!', { db, magnitude });
        this.wrapper.recordViolation('voice-detected', {
          magnitude: magnitude.toFixed(2),
          db: db.toFixed(2)
        });
        this.consecutiveNoiseFrames = 0; // Reset
      }
    } else {
      // Silence or very low background noise
      this.consecutiveNoiseFrames = 0;
    }
  }

  /**
   * Stop audio monitoring
   */
  stopMonitoring() {
    this.isMonitoring = false;

    if (this.analysisInterval) {
      clearInterval(this.analysisInterval);
    }

    if (this.audioContext) {
      this.audioContext.close();
    }

    console.log('🛑 Audio Monitoring Stopped');
  }

  /**
   * Get audio state for debugging
   */
  getState() {
    return {
      isMonitoring: this.isMonitoring,
      audioContextState: this.audioContext?.state,
      analyserReady: !!this.analyser,
      consecutiveNoiseFrames: this.consecutiveNoiseFrames,
      noiseThreshold: this.noiseThreshold
    };
  }

  /**
   * Adjust noise sensitivity
   */
  setNoiseSensitivity(level) {
    // level: 1 (least sensitive) to 10 (most sensitive)
    this.noiseThreshold = 50 - (level * 1.5); // Ranges from 50 to 35
    console.log(`🎚️ Noise sensitivity adjusted to level ${level} (threshold: ${this.noiseThreshold})`);
  }
}

// Export for use
window.AudioMonitoringModule = AudioMonitoringModule;
