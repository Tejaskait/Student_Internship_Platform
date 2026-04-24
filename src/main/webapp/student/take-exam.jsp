<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>

<html>
<head>
    <title>Take Exam</title>

```
<style>
    body {
        font-family: Arial;
        background: #f4f6fb;
        margin: 0;
    }

    /* HEADER */
    .header {
        background: #1e293b;
        color: white;
        padding: 15px 20px;
        display: flex;
        justify-content: space-between;
    }

    .timer {
        background: #dc2626;
        padding: 5px 12px;
        border-radius: 6px;
    }

    .violations {
        background: #e5e7eb;
        padding: 5px 12px;
        border-radius: 6px;
        color: black;
    }

    /* MAIN */
    .container {
        max-width: 700px;
        margin: 40px auto;
        background: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.1);
    }

    h2 {
        margin-bottom: 20px;
    }

    .option {
        margin: 10px 0;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 6px;
        cursor: pointer;
    }

    .option:hover {
        background: #f1f5f9;
    }

    .buttons {
        margin-top: 20px;
    }

    button {
        padding: 8px 14px;
        margin-right: 10px;
        border: none;
        background: #6366f1;
        color: white;
        border-radius: 6px;
        cursor: pointer;
    }

    button:hover {
        background: #4f46e5;
    }

    .submit-btn {
        background: #16a34a;
    }

    .submit-btn:hover {
        background: #15803d;
    }
    
    /* 🔥 FIX CLICK BLOCK ISSUE */
		.container {
		    position: relative;
		    z-index: 10000 !important;
		}
		
		.option {
		    position: relative;
		    z-index: 10001 !important;
		}
		
		button {
		    position: relative;
		    z-index: 10002 !important;
		}
</style>
```

</head>

<body>

<div class="header">
    <div>⏱ Time Remaining: <span id="time">60:00</span></div>
    <div class="violations">Violations: <span id="vio">0</span> / 5</div>
</div>

<div class="container">
    <h2 id="questionText"></h2>

```
<div id="optionsContainer"></div>

<div class="buttons">
    <button onclick="prev()">Prev</button>
    <button onclick="next()">Next</button>
    <button class="submit-btn" onclick="submitExam()">Submit</button>
</div>
```

</div>

<!-- JS Modules -->
<script src="<%= request.getContextPath() %>/js/exam-security.js"></script>
<script src="<%= request.getContextPath() %>/js/camera-monitoring.js"></script>
<script src="<%= request.getContextPath() %>/js/audio-monitoring.js"></script>
<script src="<%= request.getContextPath() %>/js/screen-security.js"></script>
<script src="<%= request.getContextPath() %>/js/timer-module.js"></script>
<script src="<%= request.getContextPath() %>/js/tab-tracking.js"></script>
<script src="<%= request.getContextPath() %>/js/violation-tracker.js"></script>
<script src="<%= request.getContextPath() %>/js/exam-mode-init.js"></script>

<script>
/* ================= QUESTIONS ================= */
const questions = [
    {
        id: 1,
        q: "What is JVM?",
        o: ["Java Virtual Machine", "Java Variable Method", "Joint VM", "None"],
        a: 0
    },
    {
        id: 2,
        q: "Which is used for frontend?",
        o: ["Java", "HTML", "MySQL", "C"],
        a: 1
    },
    {
        id: 3,
        q: "CSS is used for?",
        o: ["Logic", "Database", "Styling", "Backend"],
        a: 2
    }
];

let current = 0;
let answers = {};

/* ================= START EXAM ================= */
window.onload = async () => {

    const config = {
        examTimeMinutes: 60,
        maxViolations: 5,
        enableCamera: false,
        enableMicrophone: false,
        enableTabTracking: true,
        enableScreenSecurity: true,
        autoSubmitOnViolations: true
    };

    try {
        // 🔥 START EXAM MODE (THIS WAS MISSING)
        await ExamModeInitializer.startExamMode(config);

        console.log("✅ Exam Mode Started");

        // 🔥 FORCE FULLSCREEN
        await document.documentElement.requestFullscreen();

    } catch (e) {
        console.warn("Exam init failed", e);
    }

    render();

    // ✅ live violation tracking
    setInterval(() => {
        const state = ExamModeInitializer.getExamState();

        document.getElementById("vio").innerText =
            state ? state.violationCount : 0;

        if (state && state.violationCount >= config.maxViolations) {
            alert("Too many violations. Auto submitting.");
            submitExam();
        }

    }, 1000);
};
//🔥 REMOVE INVISIBLE BLOCKING OVERLAY
setTimeout(() => {
    const elements = document.querySelectorAll('*');

    elements.forEach(el => {
        const style = window.getComputedStyle(el);

        if (
            style.position === 'fixed' &&
            style.width === '100%' &&
            style.height === '100%' &&
            parseInt(style.zIndex) > 1000
        ) {
            console.log("Blocking overlay found → disabling:", el);
            el.style.pointerEvents = 'none';
        }
    });

}, 2000);
/* ================= RENDER ================= */
function render() {
    const q = questions[current];

    document.getElementById("questionText").innerText =
        "Q" + (current + 1) + ": " + q.q;

    const container = document.getElementById("optionsContainer");
    container.innerHTML = "";

    for (let i = 0; i < q.o.length; i++) {
        const div = document.createElement("div");
        div.className = "option";

        const input = document.createElement("input");
        input.type = "radio";
        input.name = "ans";
        input.value = i;

        if (answers[q.id] === i) input.checked = true;

        input.onchange = () => {
            answers[q.id] = i;
        };

        div.appendChild(input);
        div.appendChild(document.createTextNode(" " + q.o[i]));

        container.appendChild(div);
    }
}

/* ================= NAVIGATION ================= */
function next() {
    if (current < questions.length - 1) {
        current++;
        render();
    }
}

function prev() {
    if (current > 0) {
        current--;
        render();
    }
}

/* ================= SUBMIT ================= */
function submitExam() {
    let score = 0;

    questions.forEach(q => {
        if (answers[q.id] === q.a) score++;
    });

    const violations = ExamModeInitializer.getViolationLog();

    alert(
        "Score: " + score + "/" + questions.length +
        "\nViolations: " + violations.length
    );
}

window.addEventListener('exam-violation', (e) => {
    console.log("🚨 VIOLATION:", e.detail);
});
</script>

</body>
</html>
