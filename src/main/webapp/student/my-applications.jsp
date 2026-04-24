<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mitwpu.lca.model.User" %>
<%@ page import="com.mitwpu.lca.dao.ApplicationDAO, com.mitwpu.lca.dao.InternshipDAO, com.mitwpu.lca.dao.CompanyDAO, com.mitwpu.lca.dao.StudentDAO" %>
<%@ page import="com.mitwpu.lca.model.Application, com.mitwpu.lca.model.Internship, com.mitwpu.lca.model.Company, com.mitwpu.lca.model.Student" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // Check authentication
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equals("STUDENT")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Unauthorized");
        return;
    }

    // Get student profile
    StudentDAO studentDAO = new StudentDAO();
    Student student = studentDAO.getStudentByUserId(user.getUserId());
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/student/profile.jsp");
        return;
    }

    // Get student's applications
    ApplicationDAO applicationDAO = new ApplicationDAO();
    List<Application> applications = applicationDAO.getApplicationsFromMainTable(student.getStudentId());    
    InternshipDAO internshipDAO = new InternshipDAO();
    CompanyDAO companyDAO = new CompanyDAO();
    
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");
    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Applications - InternshipHub</title>
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
            padding: 20px 0;
        }

        .navbar {
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .navbar-brand {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }

        .navbar-menu {
            display: flex;
            gap: 25px;
            list-style: none;
        }

        .navbar-menu a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
            transition: color 0.3s;
        }

        .navbar-menu a:hover {
            color: #667eea;
        }

        .navbar-right {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .page-header {
            background: white;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .page-header h1 {
            color: #333;
            margin-bottom: 5px;
        }

        .page-header p {
            color: #666;
            font-size: 1em;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .stat-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #666;
            font-weight: 500;
        }

        .applications-container {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .applications-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            font-size: 1.2em;
            font-weight: 600;
        }

        .application-item {
            padding: 20px;
            border-bottom: 1px solid #eee;
            transition: background 0.3s;
        }

        .application-item:last-child {
            border-bottom: none;
        }

        .application-item:hover {
            background: #f9f9f9;
        }

        .application-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
        }

        .application-title {
            font-size: 1.2em;
            font-weight: 600;
            color: #333;
        }

        .application-company {
            color: #667eea;
            font-size: 0.95em;
            margin-top: 3px;
        }

        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9em;
            text-transform: uppercase;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-shortlisted {
            background: #d1ecf1;
            color: #0c5460;
        }

        .status-rejected {
            background: #f8d7da;
            color: #721c24;
        }

        .status-accepted {
            background: #d4edda;
            color: #155724;
        }

        .application-details {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 15px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
        }

        .detail-label {
            color: #666;
            font-size: 0.9em;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .detail-value {
            color: #333;
            font-size: 1em;
        }

        .cover-letter-section {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 6px;
            margin: 15px 0;
        }

        .cover-letter-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            display: block;
        }

        .cover-letter-text {
            color: #666;
            line-height: 1.6;
            font-size: 0.95em;
        }

        .feedback-section {
            background: #e8f5e9;
            padding: 15px;
            border-left: 4px solid #4caf50;
            border-radius: 4px;
            margin: 15px 0;
            display: none;
        }

        .feedback-section.show {
            display: block;
        }

        .feedback-label {
            font-weight: 600;
            color: #2e7d32;
            margin-bottom: 8px;
            display: block;
        }

        .feedback-text {
            color: #555;
            line-height: 1.6;
        }

        .application-actions {
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 10px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 0.9em;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .btn-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .btn-danger:hover {
            background: #f5c6cb;
        }

        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }

        .btn-secondary:hover {
            background: #e0e0e0;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-state h2 {
            color: #999;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #bbb;
            font-size: 1.1em;
            margin-bottom: 20px;
        }

        .alert {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 6px;
            border-left: 4px solid;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border-color: #28a745;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }

        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .application-details {
                grid-template-columns: repeat(2, 1fr);
            }

            .application-header {
                flex-direction: column;
            }

            .status-badge {
                align-self: flex-start;
                margin-top: 10px;
            }
        }
    </style>
</head>
<body class="app-layout" data-page="applications">
    <%@ include file="../components/navbar.jsp" %>

    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1>📋 My Applications</h1>
            <p>Track and manage your internship applications</p>
        </div>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value"><%= applications.size() %></div>
                <div class="stat-label">Total Applications</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= applicationDAO.getApplicationCountByStatus(student.getStudentId(), "PENDING") %></div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= applicationDAO.getApplicationCountByStatus(student.getStudentId(), "SHORTLISTED") %></div>
                <div class="stat-label">Shortlisted</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= applicationDAO.getApplicationCountByStatus(student.getStudentId(), "ACCEPTED") %></div>
                <div class="stat-label">Accepted</div>
            </div>
        </div>

        <!-- Applications List -->
        <div class="applications-container">
            <div class="applications-header">
                💼 Your Applications
            </div>

            <% if (applications.isEmpty()) { %>
                <div class="empty-state">
                    <h2>No applications yet</h2>
                    <p>Start by browsing available internship opportunities</p>
                    <a href="<%= request.getContextPath() %>/student/browse-internships.jsp" class="btn btn-primary">Browse Internships</a>
                </div>
            <% } else { %>
                <% for (Application app : applications) {
                    Internship internship = internshipDAO.getInternshipById(app.getInternshipId());
                    Company company = internship != null ? companyDAO.getCompanyById(internship.getCompanyId()) : null;
                    
                    if (internship == null) continue;
                    String companyName = company != null ? company.getCompanyName() : "Unknown Company";
                %>
                    <div class="application-item">
                        <div class="application-header">
                            <div>
                                <div class="application-title"><%= internship.getJobTitle() %></div>
                                <div class="application-company">@ <%= companyName %></div>
                            </div>
                            <span class="status-badge status-<%= app.getStatus().toLowerCase() %>">
                                <%= app.getStatus() %>
                            </span>
                        </div>

                        <div class="application-details">
                            <div class="detail-item">
                                <span class="detail-label">Applied On</span>
                                <span class="detail-value"><%= app.getAppliedDate() != null ? app.getAppliedDate().format(dateFormatter) : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Location</span>
                                <span class="detail-value"><%= internship.getJobLocation() %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Duration</span>
                                <span class="detail-value"><%= internship.getDurationMonths() %> months</span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Stipend</span>
                                <span class="detail-value">₹<%= String.format("%.0f", internship.getStipendAmount()) %>/month</span>
                            </div>
                        </div>

                        <!-- Cover Letter -->
                        <div class="cover-letter-section">
                            <label class="cover-letter-label">Your Cover Letter</label>
						<p class="cover-letter-text">
						    <%= app.getCoverLetter() != null ? app.getCoverLetter() : "Not provided" %>
						</p>    
						 </div>

                        <!-- Feedback (if available) -->
						<% if (app.getFeedback() != null && !app.getFeedback().isEmpty()) { %>                            <div class="feedback-section show">
                                <label class="feedback-label">📝 Feedback from <%= companyName %></label>
                                <p class="feedback-text"><%= app.getFeedback() %></p>
                                <% if (app.getRating() != null) { %>
                                    <div style="margin-top: 10px; font-weight: 600;">
                                        Rating: <span style="color: #ffc107;">★</span> <%= String.format("%.1f", app.getRating()) %>/5.0
                                    </div>
                                <% } %>
                            </div>
                        <% } %>

                        <!-- Actions -->
                        <div class="application-actions" style="margin-top: 15px;">
                            <% if (app.getStatus().equals("PENDING")) { %>
                                <button class="btn btn-danger" onclick="cancelApplication(<%= app.getApplicationId() %>)">Cancel Application</button>
                            <% } else if (app.getStatus().equals("ACCEPTED")) { %>
                                <a href="#" class="btn btn-primary">View Details</a>
                            <% } else if (app.getStatus().equals("SHORTLISTED")) { %>
                                <a href="#" class="btn btn-primary">View Interview Details</a>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <script>
        function cancelApplication(applicationId) {
            if (confirm('Are you sure you want to cancel this application? This action cannot be undone.')) {
                const formData = new FormData();
                formData.append('action', 'cancel');
                formData.append('applicationId', applicationId);

                fetch('<%= request.getContextPath() %>/student/apply', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showAlert('success', data.message);
                        setTimeout(() => {
                            location.reload();
                        }, 2000);
                    } else {
                        showAlert('error', data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showAlert('error', 'An error occurred. Please try again.');
                });
            }
        }

        function showAlert(type, message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-${type}`;
            alertDiv.textContent = message;
            document.querySelector('.container').insertBefore(alertDiv, document.querySelector('.page-header'));
            
            setTimeout(() => {
                alertDiv.remove();
            }, 5000);
        }
    </script>
    <script src="<%= request.getContextPath() %>/js/navbar.js"></script>
</body>
</html>
