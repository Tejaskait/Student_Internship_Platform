/**
 * Tab Tracking Module
 * Detects tab switches and window blur events using Page Visibility API and focus events
 */

class TabTrackingModule {
  constructor(parentWrapper) {
    this.wrapper = parentWrapper;
    this.isMonitoring = false;
    this.isTabVisible = true;
    this.isFocused = true;
  }

  /**
   * Initialize tab tracking
   */
  initialize() {
    console.log('📑 Initializing Tab Tracking...');
  }

  /**
   * Start tab monitoring
   */
  startMonitoring() {
    if (this.isMonitoring) return;

    console.log('👁️ Starting Tab Tracking...');
    this.isMonitoring = true;

    // Page Visibility API - detect tab switch
    document.addEventListener('visibilitychange', (e) => this.handleVisibilityChange(e));

    // Window focus/blur events
    window.addEventListener('focus', (e) => this.handleFocus(e));
    window.addEventListener('blur', (e) => this.handleBlur(e));

    // Prevent common keyboard shortcuts
    document.addEventListener('keydown', (e) => this.handleKeyboardShortcuts(e));

    // Prevent right-click context menu
    document.addEventListener('contextmenu', (e) => this.handleContextMenu(e));

    // Prevent back/forward navigation
    window.addEventListener('popstate', (e) => this.handleNavigation(e));

    // Prevent drag/drop
    document.addEventListener('dragstart', (e) => e.preventDefault());
    document.addEventListener('drop', (e) => e.preventDefault());

    console.log('✅ Tab Tracking Ready');
  }

  /**
   * Handle visibility change (tab switch detected)
   */
  handleVisibilityChange(event) {
    if (document.hidden) {
      // Tab is now hidden
      this.isTabVisible = false;
      console.warn('⚠️ Tab hidden - likely switched to another tab');
      this.wrapper.recordViolation('tab-switch', {
        event: 'hidden'
      });
    } else {
      // Tab is now visible
      this.isTabVisible = true;
      console.log('✓ Tab visible again');
    }
  }

  /**
   * Handle window focus
   */
  handleFocus(event) {
    this.isFocused = true;
    console.log('✓ Window focused');
  }

  /**
   * Handle window blur
   */
  handleBlur(event) {
    this.isFocused = false;
    console.warn('⚠️ Window lost focus');
    this.wrapper.recordViolation('screen-blur', {
      event: 'blur'
    });
  }

  /**
   * Handle keyboard shortcuts
   */
  handleKeyboardShortcuts(event) {
    // F12 - Developer tools
    if (event.key === 'F12') {
      event.preventDefault();
      console.warn('⚠️ F12 (Developer Tools) pressed');
      this.wrapper.recordViolation('screenshot-attempt', {
        key: 'F12'
      });
      return false;
    }

    // Ctrl+Shift+I - Developer tools (Windows/Linux)
    if (event.ctrlKey && event.shiftKey && event.key === 'I') {
      event.preventDefault();
      console.warn('⚠️ Ctrl+Shift+I (Developer Tools) pressed');
      return false;
    }

    // Cmd+Option+I - Developer tools (Mac)
    if (event.metaKey && event.altKey && event.key === 'i') {
      event.preventDefault();
      return false;
    }

    // Ctrl+Shift+J - Console
    if (event.ctrlKey && event.shiftKey && event.key === 'J') {
      event.preventDefault();
      return false;
    }

    // Ctrl+Shift+C - Element inspector
    if (event.ctrlKey && event.shiftKey && event.key === 'C') {
      event.preventDefault();
      return false;
    }

    // Ctrl+Shift+K - Console (Firefox)
    if (event.ctrlKey && event.shiftKey && event.key === 'K') {
      event.preventDefault();
      return false;
    }

    // Alt+Left Arrow - Browser back
    if (event.altKey && event.key === 'ArrowLeft') {
      event.preventDefault();
      console.warn('⚠️ Browser back attempt');
      this.wrapper.recordViolation('navigation-attempt', {
        type: 'back'
      });
      return false;
    }

    // Alt+Right Arrow - Browser forward
    if (event.altKey && event.key === 'ArrowRight') {
      event.preventDefault();
      console.warn('⚠️ Browser forward attempt');
      this.wrapper.recordViolation('navigation-attempt', {
        type: 'forward'
      });
      return false;
    }

    // Prevent Ctrl+W (close tab)
    if (event.ctrlKey && event.key === 'w') {
      event.preventDefault();
      return false;
    }

    // Prevent Ctrl+Q (quit browser)
    if (event.ctrlKey && event.key === 'q') {
      event.preventDefault();
      return false;
    }

    // Prevent Cmd+Q (quit on Mac)
    if (event.metaKey && event.key === 'q') {
      event.preventDefault();
      return false;
    }

    // Prevent Ctrl+R (refresh)
    if (event.ctrlKey && event.key === 'r') {
      event.preventDefault();
      console.warn('⚠️ Page refresh attempt');
      return false;
    }

    // Prevent F5 (refresh)
    if (event.key === 'F5') {
      event.preventDefault();
      return false;
    }

    // Prevent Ctrl+L (address bar)
    if (event.ctrlKey && event.key === 'l') {
      event.preventDefault();
      return false;
    }
  }

  /**
   * Handle context menu (right-click)
   */
  handleContextMenu(event) {
    event.preventDefault();
    console.warn('⚠️ Right-click attempt');
    this.wrapper.recordViolation('copy-attempt', {
      event: 'contextmenu'
    });
    return false;
  }

  /**
   * Handle navigation attempts
   */
  handleNavigation(event) {
    event.preventDefault();
    console.warn('⚠️ Browser navigation attempt');
    return false;
  }

  /**
   * Stop tab monitoring
   */
  stopMonitoring() {
    this.isMonitoring = false;
    console.log('🛑 Tab Tracking Stopped');
  }

  /**
   * Get tab tracking state
   */
  getState() {
    return {
      isMonitoring: this.isMonitoring,
      isTabVisible: this.isTabVisible,
      isFocused: this.isFocused
    };
  }
}

// Export for use
window.TabTrackingModule = TabTrackingModule;
