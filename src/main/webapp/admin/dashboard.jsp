<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mitwpu.lca.model.User" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !user.getRole().equals("ADMIN")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Internship & Examination System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .navbar {
            background: linear-gradient(90deg, #1f3a93 0%, #2d5a96 100%);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .navbar .logo {
            font-size: 1.5rem;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .navbar .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .navbar .logout-btn {
            background: #ff6b6b;
            color: white;
            border: none;
            padding: 0.5rem 1.5rem;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background 0.3s ease;
        }

        .navbar .logout-btn:hover {
            background: #ee5a52;
        }

        .sidebar {
            position: fixed;
            left: 0;
            top: 60px;
            width: 250px;
            height: calc(100vh - 60px);
            background: #2c3e50;
            color: white;
            padding: 2rem 0;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
        }

        .sidebar .menu-item {
            padding: 1.2rem 1.5rem;
            cursor: pointer;
            transition: background 0.3s ease;
            display: flex;
            align-items: center;
            gap: 1rem;
            text-decoration: none;
            color: #ecf0f1;
        }

        .sidebar .menu-item:hover {
            background: #34495e;
            padding-left: 2rem;
        }

        .sidebar .menu-item.active {
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border-left: 4px solid #f39c12;
        }

        .main-content {
            margin-left: 0;
            margin-top: 0;
            padding: 2rem;
            min-height: auto;
        }

        .header {
            margin-bottom: 2rem;
        }

        .header h1 {
            color: white;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .header p {
            color: rgba(255, 255, 255, 0.8);
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .card {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }

        .card-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .card-title {
            color: #2c3e50;
            font-size: 1.2rem;
            margin-bottom: 0.5rem;
            font-weight: bold;
        }

        .card-value {
            color: #667eea;
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 1rem;
        }

        .card-description {
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }

        .card-action {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.7rem 1.5rem;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9rem;
            transition: opacity 0.3s ease;
        }

        .card-action:hover {
            opacity: 0.9;
        }

        .section {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .section-title {
            color: #2c3e50;
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #667eea;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table thead {
            background: #f8f9fa;
        }

        .table th {
            color: #2c3e50;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #e9ecef;
        }

        .table td {
            padding: 1rem;
            border-bottom: 1px solid #e9ecef;
        }

        .table tr:hover {
            background: #f8f9fa;
        }

        .badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }

        .badge-success {
            background: #d4edda;
            color: #155724;
        }

        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }

        .badge-danger {
            background: #f8d7da;
            color: #721c24;
        }

        .action-btn {
            padding: 0.4rem 0.8rem;
            margin: 0 0.2rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.3s ease;
        }

        .action-btn-view {
            background: #667eea;
            color: white;
        }

        .action-btn-view:hover {
            background: #5568d3;
        }

        .action-btn-edit {
            background: #f39c12;
            color: white;
        }

        .action-btn-edit:hover {
            background: #e67e22;
        }

        .action-btn-delete {
            background: #ff6b6b;
            color: white;
        }

        .action-btn-delete:hover {
            background: #ee5a52;
        }

        .welcome-msg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }

        .welcome-msg h2 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }

        .welcome-msg p {
            font-size: 1rem;
            opacity: 0.9;
        }

        @media (max-width: 768px) {
            .sidebar {
                display: none;
            }

            .main-content {
                margin-left: 0;
            }

            .dashboard-grid {
                grid-template-columns: 1fr;
            }

            .navbar {
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body class="app-layout" data-page="dashboard">
    <%@ include file="../components/navbar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Welcome Section -->
        <div class="welcome-msg">
            <h2>Welcome back, <%= user.getFullName() %>! 👋</h2>
            <p>Here's your dashboard overview. Manage companies, internships, applications, and more.</p>
        </div>

        <!-- Dashboard Header -->
        <div class="header">
            <h1>Dashboard</h1>
            <p>Overview of your system</p>
        </div>

        <!-- Dashboard Cards -->
        <div class="dashboard-grid">
            <!-- Total Companies -->
            <div class="card">
                <div class="card-icon">🏢</div>
                <div class="card-title">Total Companies</div>
                <div class="card-value">12</div>
                <div class="card-description">Registered companies on the platform</div>
                <a href="#companies" class="card-action">Manage Companies →</a>
            </div>

            <!-- Active Internships -->
            <div class="card">
                <div class="card-icon">💼</div>
                <div class="card-title">Active Internship</div>
                <div class="card-value">28</div>
                <div class="card-description">Internship positions currently open</div>
                <a href="#internships" class="card-action">View Internships →</a>
            </div>

            <!-- Total Students -->
            <div class="card">
                <div class="card-icon">👨‍🎓</div>
                <div class="card-title">Total Students</div>
                <div class="card-value">245</div>
                <div class="card-description">Active students in the system</div>
                <a href="#users" class="card-action">Manage Students →</a>
            </div>

            <!-- Pending Applications -->
            <div class="card">
                <div class="card-icon">📋</div>
                <div class="card-title">Pending Applications</div>
                <div class="card-value">18</div>
                <div class="card-description">Applications awaiting review</div>
                <a href="#applications" class="card-action">Review Applications →</a>
            </div>
        </div>

        <!-- Recent Activities Section -->
        <div class="section">
            <h2 class="section-title">📊 Recent Activities</h2>
            <table class="table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Activity</th>
                        <th>User</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>2026-04-20</td>
                        <td>New company registered</td>
                        <td>Google Inc.</td>
                        <td><span class="badge badge-success">Completed</span></td>
                    </tr>
                    <tr>
                        <td>2026-04-19</td>
                        <td>Internship application submitted</td>
                        <td>John Doe</td>
                        <td><span class="badge badge-warning">Pending</span></td>
                    </tr>
                    <tr>
                        <td>2026-04-18</td>
                        <td>Student registered</td>
                        <td>Jane Smith</td>
                        <td><span class="badge badge-success">Completed</span></td>
                    </tr>
                    <tr>
                        <td>2026-04-17</td>
                        <td>Exam created</td>
                        <td>Data Structures</td>
                        <td><span class="badge badge-success">Completed</span></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Quick Actions -->
        <div class="section">
            <h2 class="section-title">⚡ Quick Actions</h2>
            <div class="dashboard-grid">
                <button class="card-action" style="padding: 1rem; display: block; width: 100%; text-align: center; border: none; cursor: pointer;">
                    ➕ Add New Company
                </button>
                <button class="card-action" style="padding: 1rem; display: block; width: 100%; text-align: center; border: none; cursor: pointer;">
                    ➕ Post New Internship
                </button>
                <button class="card-action" style="padding: 1rem; display: block; width: 100%; text-align: center; border: none; cursor: pointer;">
                    ➕ Create New Exam
                </button>
                <button class="card-action" style="padding: 1rem; display: block; width: 100%; text-align: center; border: none; cursor: pointer;">
                    📊 Generate Report
                </button>
            </div>
        </div>
    </div>

    <script src="<%= request.getContextPath() %>/js/navbar.js"></script>
</body>
</html>
