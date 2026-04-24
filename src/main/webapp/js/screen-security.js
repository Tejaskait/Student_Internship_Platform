/**
 * Screen Security Module
 * Disables copy-paste, text selection, screenshots, and other screen attacks
 */

class ScreenSecurityModule {
  constructor(parentWrapper) {
    this.wrapper = parentWrapper;
    this.isMonitoring = false;
  }

  /**
   * Initialize screen security
   */
  initialize() {
    console.log('🔒 Initializing Screen Security...');
  }

  /**
   * Start screen security monitoring
   */
  startMonitoring() {
    if (this.isMonitoring) return;

    console.log('🛡️ Starting Screen Security...');
    this.isMonitoring = true;

    // Disable text selection globally
    this.disableTextSelection();

    // Disable copy-paste
    this.disableCopyPaste();

    // Disable drag and drop
    this.disableDragDrop();

    // Monitor for screenshots
    this.monitorScreenshots();

    // Disable print functionality
    this.disablePrinting();

    console.log('✅ Screen Security Ready');
  }

  /**
   * Disable text selection
   */
  disableTextSelection() {
    // CSS method
    const style = document.createElement('style');
    style.textContent = `
      * {
        user-select: none !important;
        -webkit-user-select: none !important;
        -moz-user-select: none !important;
        -ms-user-select: none !important;
      }
      
      input, textarea {
        user-select: text !important;
        -webkit-user-select: text !important;
      }
    `;
    document.head.appendChild(style);

    // JavaScript method - select event
    document.addEventListener('selectstart', (e) => {
      e.preventDefault();
      return false;
    });

    document.addEventListener('mousedown', (e) => {
      if (e.detail > 1) { // Prevent double-click selection
        e.preventDefault();
        return false;
      }
    });

    // Prevent selection via keyboard
    document.addEventListener('keydown', (e) => {
      if (e.ctrlKey && e.key === 'a') {
        e.preventDefault();
        return false;
      }
    });
  }

  /**
   * Disable copy-paste operations
   */
  disableCopyPaste() {
    // Disable copy
    document.addEventListener('copy', (e) => {
      e.preventDefault();
      console.warn('⚠️ Copy attempt detected');
      this.wrapper.recordViolation('copy-attempt', {
        event: 'copy'
      });
      return false;
    });

    // Disable cut
    document.addEventListener('cut', (e) => {
      e.preventDefault();
      console.warn('⚠️ Cut attempt detected');
      this.wrapper.recordViolation('copy-attempt', {
        event: 'cut'
      });
      return false;
    });

    // Disable paste
    document.addEventListener('paste', (e) => {
      e.preventDefault();
      console.warn('⚠️ Paste attempt detected');
      this.wrapper.recordViolation('copy-attempt', {
        event: 'paste'
      });
      return false;
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', (e) => {
      // Ctrl+C (Copy)
      if (e.ctrlKey && e.key === 'c') {
        e.preventDefault();
        return false;
      }

      // Ctrl+X (Cut)
      if (e.ctrlKey && e.key === 'x') {
        e.preventDefault();
        return false;
      }

      // Ctrl+V (Paste)
      if (e.ctrlKey && e.key === 'v') {
        e.preventDefault();
        return false;
      }

      // Cmd+C (Mac Copy)
      if (e.metaKey && e.key === 'c') {
        e.preventDefault();
        return false;
      }

      // Cmd+X (Mac Cut)
      if (e.metaKey && e.key === 'x') {
        e.preventDefault();
        return false;
      }

      // Cmd+V (Mac Paste)
      if (e.metaKey && e.key === 'v') {
        e.preventDefault();
        return false;
      }
    });
  }

  /**
   * Disable drag and drop
   */
  disableDragDrop() {
    document.addEventListener('dragstart', (e) => {
      e.preventDefault();
      return false;
    });

    document.addEventListener('drag', (e) => {
      e.preventDefault();
      return false;
    });

    document.addEventListener('drop', (e) => {
      e.preventDefault();
      return false;
    });

    document.addEventListener('dragover', (e) => {
      e.preventDefault();
      return false;
    });
  }

  /**
   * Monitor for screenshots
   */
  monitorScreenshots() {
    // Print Screen key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'PrintScreen') {
        e.preventDefault();
        console.warn('⚠️ Print Screen key pressed');
        this.wrapper.recordViolation('screenshot-attempt', {
          key: 'PrintScreen'
        });
        return false;
      }
    });

    // Detect screenshot tools via keyboard
    document.addEventListener('keyup', (e) => {
      if (e.key === 'PrintScreen') {
        // Clear clipboard if possible
        navigator.clipboard.writeText('').catch(() => {});
        console.warn('⚠️ Screenshot attempt - clipboard cleared');
      }
    });

    // Monitor for common screenshot key combinations
    document.addEventListener('keydown', (e) => {
      // Shift+PrintScreen
      if (e.shiftKey && e.key === 'PrintScreen') {
        e.preventDefault();
        return false;
      }

      // Ctrl+PrintScreen
      if (e.ctrlKey && e.key === 'PrintScreen') {
        e.preventDefault();
        return false;
      }

      // Cmd+Shift+3 (Mac)
      if (e.metaKey && e.shiftKey && e.key === '3') {
        e.preventDefault();
        return false;
      }

      // Cmd+Shift+4 (Mac)
      if (e.metaKey && e.shiftKey && e.key === '4') {
        e.preventDefault();
        return false;
      }

      // Windows+Shift+S (Win10 Screenshot)
      if (e.key === 'Meta' && e.shiftKey && e.key === 's') {
        e.preventDefault();
        return false;
      }
    });
  }

  /**
   * Disable printing
   */
  disablePrinting() {
    // Ctrl+P
    document.addEventListener('keydown', (e) => {
      if (e.ctrlKey && e.key === 'p') {
        e.preventDefault();
        console.warn('⚠️ Print attempt');
        this.wrapper.recordViolation('print-attempt', {
          event: 'keydown'
        });
        return false;
      }

      // Cmd+P (Mac)
      if (e.metaKey && e.key === 'p') {
        e.preventDefault();
        return false;
      }
    });

    // beforeprint event
    window.addEventListener('beforeprint', (e) => {
      console.warn('⚠️ Print initiated');
      return false;
    });
  }

  /**
   * Stop screen security monitoring
   */
  stopMonitoring() {
    this.isMonitoring = false;
    console.log('🛑 Screen Security Stopped');
  }

  /**
   * Get screen security state
   */
  getState() {
    return {
      isMonitoring: this.isMonitoring
    };
  }
}

// Export for use
window.ScreenSecurityModule = ScreenSecurityModule;
