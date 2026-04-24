<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mitwpu.lca.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !"STUDENT".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Exams - InternshipHub</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/exam-ui.css">
    <style>
        .exam-dashboard {
            max-width: 1000px;
            margin: 24px auto;
            padding: 0 16px;
        }

        .exam-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 12px;
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
        }

        .exam-header h1 {
            margin: 0 0 8px 0;
            font-size: 28px;
        }

        .exam-header p {
            margin: 0;
            opacity: 0.95;
        }

        .exam-list {
            display: grid;
            gap: 16px;
            margin-bottom: 32px;
        }

        .exam-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
            transition: all 0.3s ease;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .exam-card:hover {
            border-color: #667eea;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.15);
        }

        .exam-info h3 {
            margin: 0 0 8px 0;
            color: #0f172a;
            font-size: 18px;
        }

        .exam-info p {
            margin: 0 0 6px 0;
            color: #64748b;
            font-size: 13px;
        }

        .exam-meta {
            display: flex;
            gap: 16px;
            margin-top: 8px;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #475569;
        }

        .start-exam-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
        }

        .start-exam-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(102, 126, 234, 0.4);
        }

        .start-exam-btn:active {
            transform: translateY(0);
        }

        .start-exam-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
            background: white;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
        }

        .empty-state svg {
            width: 48px;
            height: 48px;
            margin-bottom: 16px;
            opacity: 0.5;
        }

        .empty-state h2 {
            color: #0f172a;
            margin: 0 0 8px 0;
        }

        .empty-state p {
            color: #64748b;
            margin: 0;
        }

        .permission-warning {
            background: #fef3c7;
            border: 1px solid #fbbf24;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 24px;
            color: #92400e;
            font-size: 14px;
            line-height: 1.6;
        }

        .permission-warning strong {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .exam-requirements {
            background: #ecf0f1;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 24px;
        }

        .exam-requirements h3 {
            margin: 0 0 12px 0;
            color: #0f172a;
            font-size: 16px;
        }

        .requirements-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .requirements-list li {
            padding: 8px 0;
            padding-left: 28px;
            position: relative;
            color: #475569;
            font-size: 14px;
        }

        .requirements-list li:before {
            content: '✓';
            position: absolute;
            left: 0;
            color: #10b981;
            font-weight: bold;
        }

        .debug-info {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.8);
            color: #00ff00;
            padding: 12px;
            border-radius: 6px;
            font-size: 11px;
            font-family: monospace;
            max-width: 300px;
            max-height: 150px;
            overflow-y: auto;
            display: none;
            z-index: 5000;
        }

        @media (max-width: 768px) {
            .exam-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .start-exam-btn {
                align-self: flex-start;
                margin-top: 12px;
            }

            .exam-header {
                padding: 24px;
            }

            .exam-header h1 {
                font-size: 22px;
            }
        }
    </style>
</head>
<body class="app-layout" data-page="exams">
    <%@ include file="../components/navbar.jsp" %>

    <main class="exam-dashboard">
        <div class="exam-header">
            <h1>📋 Exams Dashboard</h1>
            <p>Access and take your scheduled examinations with secure proctoring</p>
        </div>

        <!-- Exam Requirements & Info -->
        <div class="exam-requirements">
            <h3>📌 Before You Start an Exam</h3>
            <ul class="requirements-list">
                <li>Ensure you have a stable internet connection</li>
                <li>Make sure your webcam and microphone are working</li>
                <li>Use a quiet environment for best audio quality</li>
                <li>Close all other tabs and applications</li>
                <li>Allow camera and microphone permissions when prompted</li>
                <li>Exams are monitored for security and integrity</li>
            </ul>
        </div>

        <!-- Permission Warning (hidden by default) -->
        <div class="permission-warning" id="permissionWarning" style="display: none;">
            <strong>⚠️ Permissions Required</strong>
            Your browser's camera and microphone permissions are needed for this exam. 
            If you denied access, please reset your browser permissions and refresh this page.
        </div>

        <!-- Exam List -->
        <div class="exam-list" id="examList">
            <!-- Sample exam card -->
            <div class="exam-card">
                <div class="exam-info">
                    <h3>Java Programming Assessment</h3>
                    <p>Test your knowledge of core Java concepts and best practices</p>
                    <div class="meta-item">
                        <span>⏱️ Duration: 60 minutes</span>
                    </div>
                    <div class="meta-item">
                        <span>📊 Questions: 50</span>
                    </div>
                    <div class="meta-item">
                        <span>📅 Available: All days</span>
                    </div>
                </div>
                <button class="start-exam-btn" onclick="startExamMode(this, {examId: 1, examName: 'Java Programming Assessment', duration: 60})">
                    Start Exam
                </button>
            </div>

            <div class="exam-card">
                <div class="exam-info">
                    <h3>Web Development Quiz</h3>
                    <p>HTML, CSS, JavaScript, and modern web technologies</p>
                    <div class="meta-item">
                        <span>⏱️ Duration: 45 minutes</span>
                    </div>
                    <div class="meta-item">
                        <span>📊 Questions: 40</span>
                    </div>
                    <div class="meta-item">
                        <span>📅 Available: All days</span>
                    </div>
                </div>
                <button class="start-exam-btn" onclick="startExamMode(this, {examId: 2, examName: 'Web Development Quiz', duration: 45})">
                    Start Exam
                </button>
            </div>
        </div>

        <!-- Empty state (shown if no exams) -->
        <div class="empty-state" id="emptyState" style="display: none;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"></path>
                <polyline points="9 12 11 14 15 10"></polyline>
            </svg>
            <h2>No Exams Available</h2>
            <p>There are currently no exams available for you. Check back later for new assessments.</p>
        </div>
    </main>

    <!-- Debug Info Panel -->
    <div class="debug-info" id="debugInfo"></div>

    <!-- Include all exam security modules -->
    <!-- Face API Library (from CDN for lightweight performance) -->
    <script async src="https://cdn.jsdelivr.net/npm/@vladmandic/face-api/dist/face-api.js"></script>

    <!-- Core Exam Security Modules -->
    <script src="<%= request.getContextPath() %>/js/exam-security.js"></script>
    <script src="<%= request.getContextPath() %>/js/camera-monitoring.js"></script>
    <script src="<%= request.getContextPath() %>/js/audio-monitoring.js"></script>
    <script src="<%= request.getContextPath() %>/js/tab-tracking.js"></script>
    <script src="<%= request.getContextPath() %>/js/screen-security.js"></script>
    <script src="<%= request.getContextPath() %>/js/timer-module.js"></script>
    <script src="<%= request.getContextPath() %>/js/violation-tracker.js"></script>
    <script src="<%= request.getContextPath() %>/js/exam-mode-init.js"></script>
    <script src="<%= request.getContextPath() %>/js/navbar.js"></script>

    <script>
        /**
         * Start exam mode with secure proctoring
         */
        async function startExamMode(button, examConfig) {
            try {
                // Disable button
                button.disabled = true;
                button.textContent = 'Initializing...';

                console.log('🚀 Starting exam:', examConfig);

                // Configure exam security settings
                const securityConfig = {
                    examTimeMinutes: examConfig.duration || 60,
                    maxViolations: 3,
                    enableCamera: true,
                    enableMicrophone: true,
                    enableTabTracking: true,
                    enableScreenSecurity: true,
                    autoSubmitOnViolations: true,
                    warningThreshold: 2
                };

                // Initialize exam mode
                const exam = await ExamModeInitializer.startExamMode(securityConfig);

                if (exam) {
                    // Store exam config for reference
                    window.currentExamConfig = examConfig;

                    // Show success message
                    console.log('✅ Exam mode activated successfully');

                    // Load actual exam content (placeholder for now)
                    loadExamContent(examConfig);
                } else {
                    throw new Error('Failed to initialize exam mode');
                }
            } catch (error) {
                console.error('❌ Exam initialization failed:', error);

                // Re-enable button
                button.disabled = false;
                button.textContent = 'Start Exam';

                // Show error
                alert('Failed to start exam. Please ensure:\n1. Camera permission is granted\n2. Microphone permission is granted\n3. Your browser supports the required features\n\nError: ' + error.message);
            }
        }

        /**
         * Load exam content (placeholder)
         */
        function loadExamContent(examConfig) {
            // This would be replaced with actual exam content loading
            alert('Exam loaded: ' + examConfig.examName + '\n\nYour exam is secure and monitored.\n\nFull exam questions would load here.');
            
            // For demo, show violation log after 5 seconds
            setTimeout(() => {
                const log = ExamModeInitializer.getViolationLog();
                console.log('Current violation log:', log);
                
                // Show current state
                const state = ExamModeInitializer.getExamState();
                console.log('Exam state:', state);
            }, 5000);
        }

        /**
         * Debug helper - press D to toggle debug info
         */
        document.addEventListener('keydown', (e) => {
            if (e.key === 'd' && e.ctrlKey) {
                e.preventDefault();
                const debugInfo = document.getElementById('debugInfo');
                debugInfo.style.display = debugInfo.style.display === 'none' ? 'block' : 'none';

                if (debugInfo.style.display === 'block' && window.currentExam) {
                    const state = window.currentExam.getState();
                    debugInfo.innerHTML = `
                        <strong>Exam State Debug Info</strong><br>
                        Violations: ${state.violationCount}/${state.maxViolations}<br>
                        Active: ${state.isExamActive}<br>
                        Time: ${new Date().toLocaleTimeString()}<br>
                        Modules: ${Object.keys(window.currentExam.modules).join(', ')}
                    `;
                }
            }
        });

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', () => {
            console.log('📋 Exam Dashboard Loaded');
            
            // Check browser permissions (non-blocking)
            checkBrowserCapabilities();
        });

        /**
         * Check browser capabilities
         */
        function checkBrowserCapabilities() {
            const hasMediaDevices = !!navigator.mediaDevices && !!navigator.mediaDevices.getUserMedia;
            const hasVisibilityAPI = typeof document.hidden !== 'undefined';
            const hasWebAudio = !!(window.AudioContext || window.webkitAudioContext);

            console.log('📊 Browser Capabilities:', {
                mediaDevices: hasMediaDevices,
                visibilityAPI: hasVisibilityAPI,
                webAudio: hasWebAudio,
                fullscreen: !!document.documentElement.requestFullscreen
            });

            if (!hasMediaDevices) {
                document.getElementById('permissionWarning').style.display = 'block';
                document.getElementById('permissionWarning').innerHTML = 
                    '<strong>⚠️ Browser Not Supported</strong>Your browser does not support camera/microphone access. Please use a modern browser like Chrome, Firefox, Safari, or Edge.';
            }
        }

        // Listen for exam mode activation
        window.addEventListener('exam-mode-activated', (e) => {
            console.log('✅ Exam mode activated event received');
        });

        // Handle page unload during exam
        window.addEventListener('beforeunload', (e) => {
            if (ExamModeInitializer.isExamActive()) {
                e.preventDefault();
                e.returnValue = 'Your exam is in progress. Are you sure you want to leave?';
            }
        });
    </script>
</body>
</html>
