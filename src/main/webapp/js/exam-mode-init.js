/**
 * Exam Mode Initialization Helper
 * Simple wrapper to start exam with predefined configuration
 */

class ExamModeInitializer {
  /**
   * Initialize exam with default configuration
   */
  static async startExamMode(config = {}) {
    try {
      // Merge user config with defaults
      const defaultConfig = {
        examTimeMinutes: 60,
        maxViolations: 3,
        enableCamera: true,
        enableMicrophone: true,
        enableTabTracking: true,
        enableScreenSecurity: true,
        autoSubmitOnViolations: true,
        warningThreshold: 2
      };

      const finalConfig = { ...defaultConfig, ...config };

      console.log('🚀 Starting Exam Mode with config:', finalConfig);

      // Create security wrapper instance
      const examSecurity = new ExamSecurityWrapper(finalConfig);

      // Initialize exam environment
      const initialized = await examSecurity.initializeExam();

      if (initialized) {
        // Store global reference for access from exam page
        window.currentExam = examSecurity;

        // Emit custom event for page to react
        window.dispatchEvent(new CustomEvent('exam-mode-activated', {
          detail: { exam: examSecurity }
        }));

        console.log('✅ Exam Mode Activated Successfully');
        return examSecurity;
      } else {
        console.error('❌ Failed to initialize exam mode');
        return null;
      }
    } catch (error) {
      console.error('❌ Exam Mode Initialization Error:', error);
      throw error;
    }
  }

  /**
   * End exam and cleanup
   */
  static endExamMode() {
    if (window.currentExam) {
      window.currentExam.stopMonitoring();
      window.currentExam = null;
      console.log('✅ Exam Mode Ended');
    }
  }

  /**
   * Get current exam instance
   */
  static getCurrentExam() {
    return window.currentExam;
  }

  /**
   * Check if exam is active
   */
  static isExamActive() {
    return window.currentExam && window.currentExam.state.isExamActive;
  }

  /**
   * Get violation log
   */
  static getViolationLog() {
    if (window.currentExam) {
      return window.currentExam.getViolationLog();
    }
    return [];
  }

  /**
   * Get exam state for debugging
   */
  static getExamState() {
    if (window.currentExam) {
      return window.currentExam.getState();
    }
    return null;
  }

  /**
   * Format violation log for submission
   */
  static formatViolationData() {
    if (!window.currentExam) return null;

    const data = window.currentExam.modules.violationTracker.exportData();
    return {
      success: true,
      data: {
        violationCount: data.violationCount,
        violationLog: data.violationLog,
        statistics: data.statistics,
        examDuration: data.examDuration,
        timestamp: new Date().toISOString()
      }
    };
  }
}

// Export for use
window.ExamModeInitializer = ExamModeInitializer;
