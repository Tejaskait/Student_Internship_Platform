<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea, #764ba2);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            background: #fff;
            padding: 35px;
            border-radius: 12px;
            width: 380px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            animation: fadeIn 0.5s ease-in-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .header {
            text-align: center;
            margin-bottom: 25px;
        }

        .header h2 {
            color: #333;
            margin-bottom: 5px;
        }

        .header p {
            font-size: 14px;
            color: #777;
        }

        .form-group {
            margin-bottom: 15px;
            position: relative;
        }

        label {
            font-size: 13px;
            color: #555;
            display: block;
            margin-bottom: 5px;
        }

        input {
            width: 100%;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #ddd;
            transition: 0.3s;
            font-size: 14px;
        }

        input:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 5px rgba(102,126,234,0.3);
        }

        .toggle {
            position: absolute;
            right: 10px;
            top: 38px;
            font-size: 12px;
            cursor: pointer;
            color: #667eea;
        }

        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 5px 15px rgba(102,126,234,0.4);
        }

        .footer {
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
        }

        .footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }

        .error {
            background: #ffe5e5;
            color: #c33;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 13px;
        }
    </style>

    <script>
        function togglePassword(id) {
            var input = document.getElementById(id);
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
</head>

<body>

<div class="container">

    <div class="header">
        <h2>Create Account</h2>
        <p>Join Internship Hub</p>
    </div>

    <%
        String error = request.getParameter("error");
        if (error != null) {
    %>
        <div class="error"><%= error %></div>
    <%
        }
    %>

    <form method="post" action="<%= request.getContextPath() %>/register">

        <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="name" placeholder="Enter your name" required>
        </div>

        <div class="form-group">
            <label>Phone Number</label>
            <input type="text" name="phone" placeholder="Enter phone number">
        </div>

        <div class="form-group">
            <label>Email Address</label>
            <input type="email" name="email" placeholder="Enter email" required>
        </div>

        <div class="form-group">
            <label>Password</label>
            <input type="password" id="password" name="password" required>
            <span class="toggle" onclick="togglePassword('password')">Show</span>
        </div>

        <div class="form-group">
            <label>Confirm Password</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required>
            <span class="toggle" onclick="togglePassword('confirmPassword')">Show</span>
        </div>

        <button type="submit" class="btn">Register</button>
    </form>

    <div class="footer">
        Already have an account? 
        <a href="<%= request.getContextPath() %>/login.jsp">Login</a>
    </div>

</div>

</body>
</html>