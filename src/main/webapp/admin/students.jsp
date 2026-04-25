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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1c2c 0%, #4a1942 100%); /* Matching your dashboard dark-purple theme */
            min-height: 100vh;
            color: white;
            padding: 2rem;
        }

        .container { max-width: 1100px; margin: 0 auto; }

        /* Dashboard-style Header */
        .header-section { margin-bottom: 2rem; }
        .header-section h1 { font-size: 2rem; margin-bottom: 0.5rem; }
        .header-section p { opacity: 0.7; }

        .btn-back {
            display: inline-block;
            padding: 0.6rem 1.2rem;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            transition: 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .btn-back:hover { background: rgba(255, 255, 255, 0.2); }

        /* Glass-morphism Table Styles */
        .table-container { overflow-x: auto; margin-top: 1rem; }
        .table { width: 100%; border-collapse: separate; border-spacing: 0 10px; }
        .table th {
            color: rgba(255, 255, 255, 0.6);
            padding: 1rem 1.5rem;
            text-align: left;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 1.5px;
        }
        .table tbody tr {
            background-color: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            transition: background-color 0.3s ease;
        }
        .table tbody tr:hover { background-color: rgba(255, 255, 255, 0.15); }
        .table td {
            padding: 1.2rem 1.5rem;
            vertical-align: middle;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }
        .table td:first-child { border-left: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px 0 0 12px; }
        .table td:last-child { border-right: 1px solid rgba(255, 255, 255, 0.05); border-radius: 0 12px 12px 0; }

        .points-badge {
            background: rgba(102, 126, 234, 0.2);
            color: #a3b8ff;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.85rem;
            border: 1px solid rgba(102, 126, 234, 0.3);
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
                        <td style="color: rgba(255,255,255,0.5);">#<%= s.get("id") %></td>
                        <td style="font-weight: 600;"><%= s.get("name") %></td>
                        <td><%= s.get("email") %></td>
                        <td><%= s.get("phone") %></td>
                        <td><span class="points-badge"><%= s.get("points") %> pts</span></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>