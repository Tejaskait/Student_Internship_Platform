<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>

    <style>
        body {
            font-family: Arial;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .box {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 380px;
        }

        h2 {
            text-align: center;
            margin-bottom: 10px;
        }

        h4 {
            margin-top: 15px;
            color: #444;
        }

        input {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
        }

        button {
            width: 100%;
            padding: 10px;
            background: #667eea;
            color: white;
            border: none;
            cursor: pointer;
            margin-top: 10px;
        }

        button:hover {
            opacity: 0.9;
        }

        .error {
            color: red;
            margin-bottom: 10px;
        }

        .success {
            color: green;
            margin-bottom: 10px;
        }

        p {
            text-align: center;
            margin-top: 10px;
        }

        a {
            color: #667eea;
            text-decoration: none;
        }
    </style>
</head>

<body>

<div class="box">
    <h2>Register as Student</h2>

    <%
        String error = request.getParameter("error");
        String success = request.getParameter("success");

        if (error != null) {
    %>
        <p class="error"><%= error %></p>
    <%
        }

        if (success != null) {
    %>
        <p class="success"><%= success %></p>
    <%
        }
    %>

    <form method="post" action="<%= request.getContextPath() %>/register">

        <!-- USER DETAILS -->
        <h4>User Details</h4>

        <input type="text" name="name" placeholder="Full Name" required>
        <input type="email" name="email" placeholder="Email" required>
        <input type="text" name="phone" placeholder="Phone Number">

        <input type="password" name="password" placeholder="Password" required>
        <input type="password" name="confirmPassword" placeholder="Confirm Password" required>

        <!-- STUDENT DETAILS -->
        <h4>Student Details</h4>

        <input type="text" name="roll" placeholder="Roll Number" required>
        <input type="text" name="deptCode" placeholder="Department Code (CSE)" required>
        <input type="text" name="deptName" placeholder="Department Name" required>

        <input type="number" step="0.01" name="cgpa" placeholder="CGPA (e.g. 8.5)" required>
        <input type="number" name="semester" placeholder="Semester (e.g. 6)" required>

        <button type="submit">Register</button>
    </form>

    <p>
        Already have an account? 
        <a href="<%= request.getContextPath() %>/login.jsp">Login</a>
    </p>
</div>

</body>
</html>