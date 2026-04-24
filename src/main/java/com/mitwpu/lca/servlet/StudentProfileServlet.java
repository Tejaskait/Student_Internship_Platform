<%@ page import="com.mitwpu.lca.model.User" %>
<%@ page import="com.mitwpu.lca.dao.StudentDAO" %>
<%@ page import="com.mitwpu.lca.model.Student" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"STUDENT".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    StudentDAO dao = new StudentDAO();
    Student student = dao.getStudentByUserId(user.getUserId());
%>

<!DOCTYPE html>
<html>
<head>
    <title>Profile</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/student/dashboard.css">

    <style>
        .profile-box {
            background: white;
            padding: 25px;
            border-radius: 10px;
            max-width: 650px;
            margin: 30px auto;
        }

        .section {
            margin-bottom: 20px;
        }

        .section h3 {
            margin-bottom: 10px;
            color: #333;
        }

        label {
            font-size: 14px;
            font-weight: 500;
        }

        input {
            width: 100%;
            padding: 10px;
            margin: 6px 0 12px 0;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        button {
            width: 100%;
            padding: 12px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
        }

        .msg {
            color: green;
            margin-bottom: 10px;
        }
    </style>
</head>

<body class="app-layout">

<%@ include file="../components/navbar.jsp" %>

<div class="profile-box">

    <h2>Student Profile</h2>

    <%
        String msg = request.getParameter("msg");
        if (msg != null) {
    %>
        <p class="msg"><%= msg %></p>
    <%
        }
    %>

    <form method="post" action="<%= request.getContextPath() %>/student/save-profile">

        <!-- BASIC INFO -->
        <div class="section">
            <h3>Basic Information</h3>

            <label>Full Name</label>
            <input type="text" value="<%= user.getFullName() %>" disabled>

            <label>Email</label>
            <input type="email" value="<%= user.getEmail() %>" disabled>
        </div>

        <!-- ACADEMIC DETAILS -->
        <div class="section">
            <h3>Academic Details</h3>

            <label>Roll Number *</label>
            <input type="text" name="roll" required
                value="<%= student != null ? student.getRollNumber() : "" %>"
                <%= student != null ? "readonly" : "" %>>

            <label>Department Code *</label>
            <input type="text" name="deptCode" required
                value="<%= student != null ? student.getDepartmentCode() : "" %>">

            <label>Department Name *</label>
            <input type="text" name="deptName" required
                value="<%= student != null ? student.getDepartmentName() : "" %>">

            <label>CGPA *</label>
            <input type="number" step="0.01" min="0" max="10" name="cgpa" required
                value="<%= student != null ? student.getCgpa() : "" %>">

            <label>Semester *</label>
            <input type="number" min="1" max="8" name="semester" required
                value="<%= student != null ? student.getSemester() : "" %>">
        </div>

        <!-- PERSONAL DETAILS -->
        <div class="section">
            <h3>Personal Details</h3>

            <label>Date of Birth</label>
            <input type="date" name="dob"
                value="<%= (student != null && student.getDateOfBirth()!=null) ? student.getDateOfBirth() : "" %>">

            <label>Address</label>
            <input type="text" name="address"
                value="<%= student != null ? student.getAddress() : "" %>">

            <label>City</label>
            <input type="text" name="city"
                value="<%= student != null ? student.getCity() : "" %>">

            <label>State</label>
            <input type="text" name="state"
                value="<%= student != null ? student.getState() : "" %>">

            <label>Pincode</label>
            <input type="text" name="pincode"
                value="<%= student != null ? student.getPincode() : "" %>">
        </div>

        <button type="submit">
            <%= (student == null) ? "Save Profile" : "Update Profile" %>
        </button>

    </form>
</div>

</body>
</html>