/**
 * Exam Security & Proctoring Module
 * Main orchestrator for secure exam environment
 * Coordinates all proctoring features without modifying core exam logic
 */

class ExamSecurityWrapper {
  constructor(config = {}) {
    this.config = {
      maxViolations: 3,
      enableCamera: true,
      enableMicrophone: true,
      enableTabTracking: true,
      enableScreenSecurity: true,
      examTimeMinutes: 60,
      warningThreshold: 2,
      autoSubmitOnViolations: true,
      ...config
    };

    this.state = {
      isExamActive: false,
      violationCount: 0,
      violationLog: [],
      warningCount: 0,
      startTime: null,
      endTime: null,
      cameraPermissionGranted: false,
      micPermissionGranted: false,
      tabSwitchCount: 0,
      noFaceDetectedCount: 0,
      multipleFacesDetectedCount: 0,
      voiceDetectedCount: 0
    };

    this.modules = {};
    this.uiElements = {};
    this.isInitialized = false;
  }

  /**
   * Initialize exam environment with required permissions
   */
  async initializeExam() {
    try {
      console.log('🔐 Initializing Exam Security Environment...');

      // Request permissions if enabled
      if (this.config.enableCamera) {
        this.state.cameraPermissionGranted = await this.requestCameraPermission();
        if (!this.state.cameraPermissionGranted && this.config.enableCamera) {
          this.showPermissionDeniedError('Camera');
          return false;
        }
      }

      if (this.config.enableMicrophone) {
        this.state.micPermissionGranted = await this.requestMicrophonePermission();
        if (!this.state.micPermissionGranted && this.config.enableMicrophone) {
          this.showPermissionDeniedError('Microphone');
          return false;
        }
      }

      // Initialize UI components
      this.initializeUI();

      // Initialize modules
      await this.initializeModules();

      // Enter full-screen mode
      await this.enterFullscreen();

      // Set exam start time
      this.state.startTime = new Date();
      this.state.endTime = new Date(this.state.startTime.getTime() + this.config.examTimeMinutes * 60000);

      // Start monitoring
      this.startMonitoring();

      this.state.isExamActive = true;
      this.isInitialized = true;

      console.log('✅ Exam Security Environment Ready');
      return true;
    } catch (error) {
      console.error('❌ Initialization Error:', error);
      this.showErrorModal('Failed to initialize exam environment. Please refresh and try again.');
      return false;
    }
  }

  /**
   * Request camera permission
   */
  async requestCameraPermission() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 640 },
          height: { ideal: 480 }
        }
      });

      // Store stream reference for camera module
      this.cameraStream = stream;

      // Don't stop here - let camera module use it
      return true;
    } catch (error) {
      console.error('Camera permission denied:', error);
      return false;
    }
  }

  /**
   * Request microphone permission
   */
  async requestMicrophonePermission() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      // Store stream reference for audio module
      this.micStream = stream;

      return true;
    } catch (error) {
      console.error('Microphone permission denied:', error);
      return false;
    }
  }

  /**
   * Initialize UI components
   */
  initializeUI() {
    // Create container for exam UI
    const examContainer = document.createElement('div');
    examContainer.id = 'exam-security-container';
    examContainer.className = 'exam-security-container';
    document.body.appendChild(examContainer);

    // Create sticky timer
    this.createTimerUI();

    // Create violation indicator
    this.createViolationIndicator();

    // Create warning modal container
    this.createWarningModalContainer();

    // Apply screen security CSS
    this.applyScreenSecurityStyles();
  }

  /**
   * Initialize all monitoring modules
   */
  async initializeModules() {
    // Camera monitoring module
    if (this.config.enableCamera && this.state.cameraPermissionGranted) {
      this.modules.camera = new CameraMonitoringModule(this);
      await this.modules.camera.initialize(this.cameraStream);
    }

    // Audio monitoring module
    if (this.config.enableMicrophone && this.state.micPermissionGranted) {
      this.modules.audio = new AudioMonitoringModule(this);
      await this.modules.audio.initialize(this.micStream);
    }

    // Tab tracking module
    if (this.config.enableTabTracking) {
      this.modules.tabTracking = new TabTrackingModule(this);
      this.modules.tabTracking.initialize();
    }

    // Screen security module
    if (this.config.enableScreenSecurity) {
      this.modules.screenSecurity = new ScreenSecurityModule(this);
      this.modules.screenSecurity.initialize();
    }

    // Timer module
    this.modules.timer = new TimerModule(this);
    this.modules.timer.initialize();

    // Violation tracker
    this.modules.violationTracker = new ViolationTrackerModule(this);
    this.modules.violationTracker.initialize();
  }

  /**
   * Start monitoring all security features
   */
  startMonitoring() {
    if (this.modules.camera) this.modules.camera.startMonitoring();
    if (this.modules.audio) this.modules.audio.startMonitoring();
    if (this.modules.tabTracking) this.modules.tabTracking.startMonitoring();
    if (this.modules.timer) this.modules.timer.startMonitoring();

    // Listen for global exam exit
    window.addEventListener('beforeunload', (e) => this.handleExamExit(e));
  }

  /**
   * Record a violation
   */
  recordViolation(violationType, details = {}) {
    this.state.violationCount++;
    
    const violation = {
      type: violationType,
      timestamp: new Date().toISOString(),
      details
    };

    this.state.violationLog.push(violation);

    // Update UI
    this.updateViolationIndicator();

    // Log for backend
    console.warn(`⚠️ Violation Recorded: ${violationType}`, violation);

    // Show warning
    this.showViolationWarning(violationType);

    // Check auto-submit threshold
    if (this.config.autoSubmitOnViolations && this.state.violationCount >= this.config.maxViolations) {
      console.error(`❌ Max violations (${this.config.maxViolations}) exceeded. Auto-submitting...`);
      this.autoSubmitExam('Max violations exceeded');
    }
  }

  /**
   * Show violation warning modal
   */
  showViolationWarning(violationType) {
    const warningMessages = {
      'tab-switch': 'You switched tabs! This is your warning. Switching tabs again will end the exam.',
      'no-face': 'No face detected! Please ensure your camera is working and you are visible.',
      'multiple-faces': 'Multiple faces detected! Only one person should be taking the exam.',
      'voice-detected': 'Background noise/voice detected! Please maintain silence during the exam.',
      'screen-blur': 'Window lost focus! Please keep the exam window active.',
      'copy-attempt': 'Copy/Paste is disabled during the exam.',
      'screenshot-attempt': 'Screenshot attempt detected. This has been logged as a violation.'
    };

    const message = warningMessages[violationType] || 'Violation detected!';
    
    this.showWarningModal({
      title: '⚠️ Warning',
      message,
      severity: this.state.violationCount >= this.config.maxViolations ? 'critical' : 'warning',
      violationType,
      violationCount: this.state.violationCount,
      maxViolations: this.config.maxViolations
    });
  }

  /**
   * Create timer UI element
   */
  createTimerUI() {
    const timerDiv = document.createElement('div');
    timerDiv.id = 'exam-timer';
    timerDiv.className = 'exam-timer';
    timerDiv.innerHTML = `
      <div class="timer-content">
        <span class="timer-label">⏱ Time Remaining:</span>
        <span class="timer-display" id="timer-display">${this.config.examTimeMinutes}:00</span>
      </div>
    `;
    document.body.appendChild(timerDiv);
  }

  /**
   * Create violation indicator UI
   */
  createViolationIndicator() {
    const indicatorDiv = document.createElement('div');
    indicatorDiv.id = 'violation-indicator';
    indicatorDiv.className = 'violation-indicator';
    indicatorDiv.innerHTML = `
      <div class="violation-badge">
        <span class="violation-label">Violations:</span>
        <span class="violation-count" id="violation-count">0</span>
        <span class="violation-max">/ ${this.config.maxViolations}</span>
      </div>
    `;
    document.body.appendChild(indicatorDiv);
  }

  /**
   * Update violation indicator
   */
  updateViolationIndicator() {
    const countElement = document.getElementById('violation-count');
    if (countElement) {
      countElement.textContent = this.state.violationCount;
      countElement.parentElement.className = 'violation-badge ' + 
        (this.state.violationCount >= this.config.maxViolations ? 'critical' : 
         this.state.violationCount >= this.config.warningThreshold ? 'warning' : 'normal');
    }
  }

  /**
   * Create warning modal container
   */
  createWarningModalContainer() {
    const modalContainer = document.createElement('div');
    modalContainer.id = 'warning-modal-container';
    modalContainer.className = 'warning-modal-container';
    document.body.appendChild(modalContainer);
  }

  /**
   * Show warning modal
   */
  showWarningModal(config) {
    const container = document.getElementById('warning-modal-container');
    
    const modal = document.createElement('div');
    modal.className = `warning-modal ${config.severity || 'warning'}`;
    modal.innerHTML = `
      <div class="modal-backdrop"></div>
      <div class="modal-content">
        <div class="modal-header">
          <h2>${config.title}</h2>
        </div>
        <div class="modal-body">
          <p>${config.message}</p>
          <div class="violation-stats">
            <span>Violations: <strong>${config.violationCount}/${config.maxViolations}</strong></span>
          </div>
        </div>
        <div class="modal-footer">
          <button class="modal-btn modal-btn-primary" id="warning-acknowledge">Acknowledge</button>
        </div>
      </div>
    `;

    container.innerHTML = '';
    container.appendChild(modal);

    // Make modal non-dismissible by clicking outside
    const acknowledgeBtn = modal.querySelector('#warning-acknowledge');
    acknowledgeBtn.addEventListener('click', () => {
      modal.remove();
    });

    // Auto-dismiss after 5 seconds
    setTimeout(() => {
      if (modal.parentElement) modal.remove();
    }, 5000);
  }

  /**
   * Show error modal
   */
  showErrorModal(message) {
    const modal = document.createElement('div');
    modal.className = 'error-modal';
    modal.innerHTML = `
      <div class="modal-backdrop"></div>
      <div class="modal-content error">
        <div class="modal-header">
          <h2>❌ Error</h2>
        </div>
        <div class="modal-body">
          <p>${message}</p>
        </div>
        <div class="modal-footer">
          <button class="modal-btn modal-btn-danger" id="error-close">Close</button>
        </div>
      </div>
    `;

    document.body.appendChild(modal);

    modal.querySelector('#error-close').addEventListener('click', () => {
      modal.remove();
    });
  }

  /**
   * Show permission denied error
   */
  showPermissionDeniedError(permission) {
    this.showErrorModal(`
      <strong>${permission} Permission Denied</strong><br>
      ${permission} access is required for this exam. Please grant permission and refresh the page to try again.
    `);
  }

  /**
   * Apply screen security CSS
   */
  applyScreenSecurityStyles() {
    const style = document.createElement('style');
    style.textContent = `
      /* Prevent text selection */
      body.exam-mode {
        user-select: none !important;
        -webkit-user-select: none !important;
        -moz-user-select: none !important;
        -ms-user-select: none !important;
      }

      /* Prevent context menu */
      body.exam-mode * {
        pointer-events: auto;
      }

      /* Timer styling */
      .exam-timer {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
        color: white;
        padding: 12px 20px;
        z-index: 10000;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        font-weight: 600;
      }

      .timer-content {
        display: flex;
        align-items: center;
        gap: 16px;
        max-width: 1200px;
        margin: 0 auto;
      }

      .timer-label {
        font-size: 14px;
        opacity: 0.9;
      }

      .timer-display {
        font-size: 20px;
        font-family: 'Courier New', monospace;
        padding: 4px 12px;
        background: rgba(255, 0, 0, 0.2);
        border-radius: 4px;
        border: 1px solid rgba(255, 0, 0, 0.5);
      }

      .timer-display.warning {
        animation: pulse 0.5s infinite;
        background: rgba(255, 107, 107, 0.3);
        border-color: #ff6b6b;
      }

      /* Violation indicator */
      .violation-indicator {
        position: fixed;
        top: 70px;
        right: 20px;
        z-index: 9999;
      }

      .violation-badge {
        background: white;
        border: 2px solid #e2e8f0;
        border-radius: 8px;
        padding: 8px 12px;
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      }

      .violation-badge.warning {
        border-color: #fbbf24;
        background: #fef3c7;
        color: #92400e;
      }

      .violation-badge.critical {
        border-color: #ef4444;
        background: #fee2e2;
        color: #7f1d1d;
        animation: pulse 0.5s infinite;
      }

      .violation-count {
        font-size: 18px;
        font-weight: bold;
      }

      /* Modal styling */
      .warning-modal-container {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        z-index: 8000;
        pointer-events: none;
      }

      .warning-modal {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 9000;
        pointer-events: auto;
      }

      .modal-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.7);
        z-index: 8999;
      }

      .modal-content {
        position: relative;
        background: white;
        border-radius: 12px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        max-width: 500px;
        width: 90%;
        padding: 24px;
        z-index: 9001;
        animation: slideIn 0.3s ease-out;
      }

      .modal-content.error {
        background: #fee2e2;
        border: 2px solid #dc2626;
      }

      .warning-modal.warning .modal-content {
        border-left: 4px solid #fbbf24;
      }

      .warning-modal.critical .modal-content {
        border-left: 4px solid #ef4444;
        animation: shake 0.5s;
      }

      .modal-header h2 {
        margin: 0 0 12px 0;
        font-size: 20px;
        color: #1a202c;
      }

      .modal-body {
        margin-bottom: 16px;
        color: #4a5568;
        line-height: 1.6;
      }

      .violation-stats {
        margin-top: 12px;
        padding: 8px 12px;
        background: rgba(0, 0, 0, 0.05);
        border-radius: 6px;
        font-size: 13px;
      }

      .modal-footer {
        display: flex;
        gap: 12px;
        justify-content: flex-end;
      }

      .modal-btn {
        padding: 8px 16px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
      }

      .modal-btn-primary {
        background: #3b82f6;
        color: white;
      }

      .modal-btn-primary:hover {
        background: #2563eb;
      }

      .modal-btn-danger {
        background: #ef4444;
        color: white;
      }

      .modal-btn-danger:hover {
        background: #dc2626;
      }

      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translate(-50%, -60%);
        }
        to {
          opacity: 1;
          transform: translate(-50%, -50%);
        }
      }

      @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.7; }
      }

      @keyframes shake {
        0%, 100% { transform: translate(-50%, -50%) translateX(0); }
        25% { transform: translate(-50%, -50%) translateX(-5px); }
        75% { transform: translate(-50%, -50%) translateX(5px); }
      }

      body.exam-mode {
        padding-top: 70px;
      }
    `;
    document.head.appendChild(style);
    document.body.classList.add('exam-mode');
  }

  /**
   * Enter fullscreen mode
   */
  async enterFullscreen() {
    const elem = document.documentElement;
    try {
      if (elem.requestFullscreen) {
        await elem.requestFullscreen();
      } else if (elem.webkitRequestFullscreen) {
        await elem.webkitRequestFullscreen();
      }
    } catch (error) {
      console.warn('Fullscreen request failed:', error);
      // Non-critical - continue without fullscreen
    }
  }

  /**
   * Exit fullscreen mode
   */
  exitFullscreen() {
    if (document.fullscreenElement) {
      document.exitFullscreen().catch(() => {});
    }
  }

  /**
   * Handle exam exit
   */
  handleExamExit(e) {
    if (this.state.isExamActive && this.state.warningCount < 3) {
      e.preventDefault();
      this.state.warningCount++;

      const remainingWarnings = 3 - this.state.warningCount;
      if (remainingWarnings > 0) {
        this.showWarningModal({
          title: '⚠️ Warning',
          message: `Are you sure you want to leave the exam? You have ${remainingWarnings} warning(s) remaining before the exam is auto-submitted.`,
          severity: 'warning'
        });
      } else {
        this.autoSubmitExam('User attempted to leave exam');
      }

      return false;
    }
  }

  /**
   * Auto-submit exam
   */
  autoSubmitExam(reason) {
    console.error('🔴 AUTO-SUBMITTING EXAM:', reason);
    this.state.isExamActive = false;
    this.stopMonitoring();

    // Log violation data to backend
    this.submitViolationLog();

    // Trigger exam submission
    if (window.ExamForm && window.ExamForm.submit) {
      window.ExamForm.submit();
    } else {
      // Fallback: redirect to dashboard
      window.location.href = 'dashboard.jsp?exam=auto-submitted&reason=' + encodeURIComponent(reason);
    }
  }

  /**
   * Submit violation log to backend
   */
  submitViolationLog() {
    const logData = {
      violationCount: this.state.violationCount,
      violations: this.state.violationLog,
      examDuration: Math.round((new Date() - this.state.startTime) / 1000),
      timestamp: new Date().toISOString()
    };

    // Send to backend (non-blocking)
    fetch(window.location.href, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(logData),
      keepalive: true
    }).catch(() => {
      console.log('Violation log saved locally');
    });
  }

  /**
   * Stop monitoring all modules
   */
  stopMonitoring() {
    if (this.modules.camera) this.modules.camera.stopMonitoring();
    if (this.modules.audio) this.modules.audio.stopMonitoring();
    if (this.modules.tabTracking) this.modules.tabTracking.stopMonitoring();
    if (this.modules.timer) this.modules.timer.stopMonitoring();

    // Stop media streams
    if (this.cameraStream) {
      this.cameraStream.getTracks().forEach(track => track.stop());
    }
    if (this.micStream) {
      this.micStream.getTracks().forEach(track => track.stop());
    }

    this.exitFullscreen();
    document.body.classList.remove('exam-mode');
  }

  /**
   * Get violation log
   */
  getViolationLog() {
    return this.state.violationLog;
  }

  /**
   * Get current state (for debugging)
   */
  getState() {
    return { ...this.state };
  }
}

// Export for use in other modules
window.ExamSecurityWrapper = ExamSecurityWrapper;
