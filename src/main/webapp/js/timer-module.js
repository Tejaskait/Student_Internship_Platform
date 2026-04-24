/**
 * Timer Module
 * Manages exam countdown and auto-submission on time expiry
 */

class TimerModule {
  constructor(parentWrapper) {
    this.wrapper = parentWrapper;
    this.isMonitoring = false;
    this.timerInterval = null;
    this.remainingMs = 0;
    this.warningShown = false;
  }

  /**
   * Initialize timer module
   */
  initialize() {
    console.log('⏱️ Initializing Timer Module...');
    
    // Calculate remaining time in milliseconds
    this.remainingMs = this.wrapper.config.examTimeMinutes * 60 * 1000;
  }

  /**
   * Start timer monitoring
   */
  startMonitoring() {
    if (this.isMonitoring) return;

    console.log('▶️ Starting Exam Timer...');
    this.isMonitoring = true;

    const startTime = Date.now();
    const endTime = startTime + this.remainingMs;

    this.timerInterval = setInterval(() => {
      const now = Date.now();
      const remainingMs = endTime - now;

      if (remainingMs <= 0) {
        this.handleTimeExpired();
      } else {
        this.updateTimerDisplay(remainingMs);
      }
    }, 1000); // Update every second

    console.log('✅ Timer Started');
  }

  /**
   * Update timer display
   */
  updateTimerDisplay(remainingMs) {
    const totalSeconds = Math.floor(remainingMs / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;

    const timerDisplay = document.getElementById('timer-display');
    if (timerDisplay) {
      timerDisplay.textContent = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

      // Add warning styling if time running low
      if (minutes <= 5) {
        timerDisplay.parentElement.classList.add('warning');
      }

      if (minutes === 0 && seconds === 30 && !this.warningShown) {
        this.warningShown = true;
        this.wrapper.showWarningModal({
          title: '⏰ Time Warning',
          message: 'You have 30 seconds remaining! Your exam will be auto-submitted when time expires.',
          severity: 'critical'
        });
      }
    }
  }

  /**
   * Handle time expired
   */
  handleTimeExpired() {
    console.error('⏰ TIME EXPIRED - Auto-submitting exam');
    this.stopMonitoring();
    this.wrapper.autoSubmitExam('Time limit exceeded');
  }

  /**
   * Stop timer monitoring
   */
  stopMonitoring() {
    this.isMonitoring = false;

    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }

    console.log('🛑 Timer Stopped');
  }

  /**
   * Get remaining time in seconds
   */
  getRemainingSeconds() {
    const timerDisplay = document.getElementById('timer-display');
    if (!timerDisplay) return 0;

    const text = timerDisplay.textContent;
    const [minutes, seconds] = text.split(':').map(Number);
    return minutes * 60 + seconds;
  }

  /**
   * Pause timer
   */
  pauseTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      console.log('⏸️ Timer Paused');
    }
  }

  /**
   * Resume timer
   */
  resumeTimer() {
    if (!this.isMonitoring) {
      this.startMonitoring();
      console.log('▶️ Timer Resumed');
    }
  }

  /**
   * Get timer state
   */
  getState() {
    return {
      isMonitoring: this.isMonitoring,
      remainingMs: this.remainingMs,
      remainingSeconds: this.getRemainingSeconds()
    };
  }
}

// Export for use
window.TimerModule = TimerModule;
