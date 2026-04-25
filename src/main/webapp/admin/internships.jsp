<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.mitwpu.lca.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equals("ADMIN")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Map<String, String>> studentList = new ArrayList<>();

    // Attempt Database Fetch
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/Login", "root", "your_password");
        String sql = "SELECT * FROM XXGM_CUSTOMER";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, String> s = new HashMap<>();
            s.put("id", rs.getString("CUST_ID"));
            s.put("name", rs.getString("CUST_FNAME") + " " + rs.getString("CUST_LNAME"));
            s.put("phone", rs.getString("CUST_PHONE"));
            s.put("email", rs.getString("CUST_EMAIL"));
            s.put("points", rs.getString("CUST_POINTS"));
            studentList.add(s);
        }
        conn.close();
    } catch (Exception e) {
        // Fallback to Dummy Data if DB is not connected
        String[][] dummyData = {
            {"1", "Geeta Kumari", "geeta@gmail.com", "9876543210", "4500"},
            {"2", "Sajjad M", "saj@gmail.com", "9877676755", "3200"},
            {"3", "Vedant M", "vedant@gmail.com", "9877676756", "3200"},
            {"4", "Jasleen M", "jasleen@gmail.com", "9877676757", "3200"},
            {"5", "Umar M", "umar@gmail.com", "9877676758", "3200"}
        };
        for (String[] row : dummyData) {
            Map<String, String> s = new HashMap<>();
            s.put("id", row[0]); s.put("name", row[1]); s.put("email", row[2]); s.put("phone", row[3]); s.put("points", row[4]);
            studentList.add(s);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Students - Internship Hub</title>
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
            color: white;
            padding: 2rem;
        }

        .container {
            max-width: 1100px;
            margin: 0 auto;
        }

        .btn-back {
            display: inline-block;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(6px);
            color: white;
            padding: 0.6rem 1.2rem;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 500;
            margin-bottom: 2rem;
            transition: all 0.2s ease;
            border: 1px solid rgba(255,255,255,0.2);
            font-size: 0.9rem;
        }
        .btn-back:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateX(-2px);
        }

        .header-section {
            margin-bottom: 2rem;
        }
        .header-section h1 {
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(135deg, #ffffff 0%, #e0c3ff 100%);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            margin-bottom: 0.5rem;
        }
        .header-section p {
            color: rgba(255, 255, 255, 0.85);
            font-size: 1rem;
        }

        .table-container {
            overflow-x: auto;
            margin-top: 1rem;
        }

        .table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 12px;
        }

        .table th {
            color: rgba(255, 255, 255, 0.75);
            padding: 1rem 1.5rem;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.7rem;
            letter-spacing: 1.5px;
            background: transparent;
        }

        .table tbody tr {
            background-color: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(5px);
            -webkit-backdrop-filter: blur(5px);
            transition: background-color 0.2s ease;
        }

        .table tbody tr:hover {
            background-color: rgba(255, 255, 255, 0.18);
        }

        .table td {
            padding: 1.2rem 1.5rem;
            vertical-align: middle;
            color: white;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            font-weight: 500;
        }

        .table td:first-child {
            border-left: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px 0 0 16px;
        }
        .table td:last-child {
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 0 16px 16px 0;
        }

        .points-badge {
            background: rgba(46, 213, 115, 0.18);
            color: #b9f6ca;
            padding: 0.3rem 0.9rem;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.8rem;
            font-family: monospace;
            letter-spacing: 0.3px;
            backdrop-filter: blur(2px);
            border: 1px solid rgba(46, 213, 115, 0.35);
            display: inline-block;
        }

        .student-name {
            font-weight: 600;
            letter-spacing: 0.2px;
            background: linear-gradient(135deg, #fff, #e2d4ff);
            -webkit-background-clip: text;
            background-clip: text;
            color: white;
        }

        .glass-note {
            margin-top: 2rem;
            font-size: 0.8rem;
            text-align: center;
            color: rgba(255,255,255,0.6);
            background: rgba(0,0,0,0.2);
            padding: 0.8rem;
            border-radius: 60px;
            backdrop-filter: blur(4px);
            display: inline-block;
            width: auto;
        }
        .center-note {
            text-align: center;
        }

        .id-cell {
            color: rgba(255,255,255,0.6);
            font-weight: 500;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="dashboard.jsp" class="btn-back">← Back to Dashboard</a>

        <div class="header-section">
            <h1>Student Management</h1>
            <p>Viewing all registered students from the <strong>XXGM_CUSTOMER</strong> database.</p>
        </div>

        <div class="table-container">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Student Name</th>
                        <th>Email Address</th>
                        <th>Phone</th>
                        <th>Points</th>
                    </tr>
                </thead>
                <tbody>
                    <% for(Map<String, String> s : studentList) { %>
                        <tr>
                            <td class="id-cell">#<%= s.get("id") %></td>
                            <td class="student-name"><%= s.get("name") %></td>
                            <td style="opacity: 0.9;"><%= s.get("email") %></td>
                            <td><%= s.get("phone") %></td>
                            <td><span class="points-badge"><%= s.get("points") %> pts</span></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <div class="center-note">
            <div class="glass-note">Unified dashboard design • Glass-morphism table • Gradient background</div>
        </div>
    </div>
</body>
</html>