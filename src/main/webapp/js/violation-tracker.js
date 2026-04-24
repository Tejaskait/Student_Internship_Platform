/**
 * Violation Tracker Module
 * Maintains violation log and statistics during exam
 */

class ViolationTrackerModule {
  constructor(parentWrapper) {
    this.wrapper = parentWrapper;
    this.isMonitoring = false;
  }

  /**
   * Initialize violation tracker
   */
  initialize() {
    console.log('📊 Initializing Violation Tracker...');
  }

  /**
   * Start violation tracking
   */
  startMonitoring() {
    if (this.isMonitoring) return;

    console.log('🔍 Starting Violation Tracking...');
    this.isMonitoring = true;

    // Set up violation statistics tracking
    this.setupStatistics();

    console.log('✅ Violation Tracking Ready');
  }

  /**
   * Set up violation statistics dashboard (optional)
   */
  setupStatistics() {
    // This can be extended to show detailed violation stats
    // Currently, stats are tracked in wrapper.state
  }

  /**
   * Get violation log
   */
  getViolationLog() {
    return this.wrapper.state.violationLog;
  }

  /**
   * Get violation statistics
   */
  getStatistics() {
    const violations = this.wrapper.state.violationLog;
    const stats = {
      totalViolations: violations.length,
      byType: {},
      timeline: []
    };

    violations.forEach(violation => {
      stats.byType[violation.type] = (stats.byType[violation.type] || 0) + 1;
      stats.timeline.push({
        type: violation.type,
        time: new Date(violation.timestamp),
        details: violation.details
      });
    });

    return stats;
  }

  /**
   * Export violation data
   */
  exportData() {
    return {
      violationCount: this.wrapper.state.violationCount,
      violationLog: this.getViolationLog(),
      statistics: this.getStatistics(),
      startTime: this.wrapper.state.startTime,
      endTime: this.wrapper.state.endTime || new Date(),
      examDuration: Math.round((this.wrapper.state.endTime - this.wrapper.state.startTime) / 1000)
    };
  }

  /**
   * Stop violation tracking
   */
  stopMonitoring() {
    this.isMonitoring = false;
    console.log('🛑 Violation Tracking Stopped');
  }

  /**
   * Get tracker state
   */
  getState() {
    return {
      isMonitoring: this.isMonitoring,
      violationCount: this.wrapper.state.violationCount,
      statistics: this.getStatistics()
    };
  }
}

// Export for use
window.ViolationTrackerModule = ViolationTrackerModule;
