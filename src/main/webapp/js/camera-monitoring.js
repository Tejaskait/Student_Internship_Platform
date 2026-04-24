/**
 * Camera Monitoring Module
 * Detects face presence, multiple faces, and other camera-related violations
 * Uses face-api.js for lightweight face detection
 */

class CameraMonitoringModule {
  constructor(parentWrapper) {
    this.wrapper = parentWrapper;
    this.isMonitoring = false;
    this.videoElement = null;
    this.canvasElement = null;
    this.modelsLoaded = false;
    this.detectionInterval = null;
    this.consecutiveNoFaceFrames = 0;
    this.consecutiveMultipleFacesFrames = 0;
    this.noFaceThreshold = 5; // Frames before triggering violation
    this.multipleFaceThreshold = 3;
  }

  /**
   * Initialize camera module
   */
  async initialize(cameraStream) {
    try {
      console.log('📷 Initializing Camera Monitoring...');

      // Create video element
      this.createVideoElement(cameraStream);

      // Load face-api.js models
      await this.loadModels();

      console.log('✅ Camera Module Ready');
    } catch (error) {
      console.error('❌ Camera Module Error:', error);
      throw error;
    }
  }

  /**
   * Create hidden video element for camera stream
   */
  createVideoElement(stream) {
    this.videoElement = document.createElement('video');
    this.videoElement.id = 'exam-camera-feed';
    this.videoElement.srcObject = stream;
    this.videoElement.autoplay = true;
    this.videoElement.playsinline = true;
    this.videoElement.style.display = 'none';
    document.body.appendChild(this.videoElement);

    // Create canvas for face detection visualization (optional)
    this.canvasElement = document.createElement('canvas');
    this.canvasElement.id = 'exam-camera-canvas';
    this.canvasElement.style.display = 'none';
    document.body.appendChild(this.canvasElement);
  }

  /**
   * Load face-api.js models
   */
  async loadModels() {
    const MODEL_URL = 'https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/';

    try {
      await Promise.all([
        faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
        faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
        faceapi.nets.faceExpressionNet.loadFromUri(MODEL_URL)
      ]);

      this.modelsLoaded = true;
      console.log('✅ Face Detection Models Loaded');
    } catch (error) {
      console.error('❌ Failed to load face-api models:', error);
      // Fallback: Use basic motion detection if face-api fails
      this.useFallbackDetection = true;
    }
  }

  /**
   * Start camera monitoring
   */
  startMonitoring() {
    if (this.isMonitoring) return;

    console.log('🎥 Starting Camera Monitoring...');
    this.isMonitoring = true;

    // Wait for video to be ready
    this.videoElement.onloadedmetadata = () => {
      console.log('📹 Camera feed ready');
      this.startDetection();
    };
  }

  /**
   * Start detection loop
   */
  startDetection() {
    this.detectionInterval = setInterval(async () => {
      if (!this.isMonitoring || !this.videoElement.srcObject) return;

      try {
        await this.detectFaces();
      } catch (error) {
        console.error('Detection error:', error);
      }
    }, 500); // Check every 500ms
  }

  /**
   * Detect faces in camera feed
   */
  async detectFaces() {
    if (!this.videoElement || !this.videoElement.srcObject) return;

    try {
      // Get video dimensions
      const displaySize = {
        width: this.videoElement.videoWidth || 640,
        height: this.videoElement.videoHeight || 480
      };

      if (this.canvasElement) {
        this.canvasElement.width = displaySize.width;
        this.canvasElement.height = displaySize.height;
      }

      // Detect faces using face-api
      const detections = await faceapi
        .detectAllFaces(this.videoElement, new faceapi.TinyFaceDetector({ inputSize: 416 }))
        .withFaceLandmarks()
        .withFaceExpressions();

      // Process detection results
      this.processFaceDetection(detections);

      // Optional: Draw detections on canvas for debugging
      // this.drawDetections(detections, displaySize);
    } catch (error) {
      console.error('Face detection error:', error);
    }
  }

  /**
   * Process face detection results
   */
  processFaceDetection(detections) {
    const faceCount = detections.length;

    // No face detected
    if (faceCount === 0) {
      this.consecutiveNoFaceFrames++;
      this.consecutiveMultipleFacesFrames = 0;

      if (this.consecutiveNoFaceFrames === this.noFaceThreshold) {
        console.warn('⚠️ No face detected!');
        this.wrapper.recordViolation('no-face', {
          frameCount: this.consecutiveNoFaceFrames
        });
        this.consecutiveNoFaceFrames = 0; // Reset
      }
    }
    // Multiple faces detected
    else if (faceCount > 1) {
      this.consecutiveMultipleFacesFrames++;
      this.consecutiveNoFaceFrames = 0;

      if (this.consecutiveMultipleFacesFrames === this.multipleFaceThreshold) {
        console.warn('⚠️ Multiple faces detected!');
        this.wrapper.recordViolation('multiple-faces', {
          faceCount: faceCount,
          frameCount: this.consecutiveMultipleFacesFrames
        });
        this.consecutiveMultipleFacesFrames = 0; // Reset
      }
    }
    // Normal: one face detected
    else {
      this.consecutiveNoFaceFrames = 0;
      this.consecutiveMultipleFacesFrames = 0;
    }
  }

  /**
   * Draw face detections on canvas (for debugging)
   */
  drawDetections(detections, displaySize) {
    if (!this.canvasElement) return;

    const ctx = this.canvasElement.getContext('2d');
    ctx.clearRect(0, 0, displaySize.width, displaySize.height);

    // Draw bounding boxes
    detections.forEach(detection => {
      const box = detection.detection.box;
      ctx.strokeStyle = 'green';
      ctx.lineWidth = 2;
      ctx.strokeRect(box.x, box.y, box.width, box.height);

      // Draw landmarks
      if (detection.landmarks) {
        ctx.fillStyle = 'red';
        detection.landmarks.positions.forEach(point => {
          ctx.beginPath();
          ctx.arc(point.x, point.y, 2, 0, 2 * Math.PI);
          ctx.fill();
        });
      }
    });
  }

  /**
   * Stop camera monitoring
   */
  stopMonitoring() {
    this.isMonitoring = false;

    if (this.detectionInterval) {
      clearInterval(this.detectionInterval);
    }

    if (this.videoElement) {
      this.videoElement.pause();
      this.videoElement.srcObject = null;
    }

    console.log('🛑 Camera Monitoring Stopped');
  }

  /**
   * Get camera state for debugging
   */
  getState() {
    return {
      isMonitoring: this.isMonitoring,
      modelsLoaded: this.modelsLoaded,
      videoElement: !!this.videoElement,
      consecutiveNoFaceFrames: this.consecutiveNoFaceFrames,
      consecutiveMultipleFacesFrames: this.consecutiveMultipleFacesFrames
    };
  }
}

// Export for use
window.CameraMonitoringModule = CameraMonitoringModule;
