<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mitwpu.lca.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !user.getRole().equals("STUDENT")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/student/dashboard.css">
</head>
<body>
    <nav class="navbar">
        <div class="logo">🎓 InternshipHub</div>
        <div class="user-info">
            <span>Welcome, <%= user.getFullName() %></span>
            <form action="<%= request.getContextPath() %>/logout" method="POST" style="display:inline;">
                <button type="submit">Logout</button>
            </form>
        </div>
    </nav>

    <div class="welcome-banner">
        <h2>Welcome back, <%= user.getFullName() %>! 👋</h2>
        <p>Explore exciting internship opportunities, track your applications, and ace your exams all in one place.</p>
    </div>

    <div class="container">
        <h1 class="section-title">Your Dashboard</h1>
        <p class="section-subtitle">Your internship journey at a glance</p>
        
        <div class="dashboard-grid" id="dashboardCards">
            <p>Loading statistics...</p>
        </div>

        <h2 class="section-title" style="margin-top: 3rem;">💼 Recommended Internships for You</h2>
        <div id="recommendedInternships">
            <p>Loading internships...</p>
        </div>

        <h2 class="section-title" style="margin-top: 3rem;">📋 Recent Applications</h2>
        <div id="recentApplications">
            <p>Loading applications...</p>
        </div>
    </div>

    <script>
        const contextPath = '<%= request.getContextPath() %>';
        
        function loadDashboardStats() {
            console.log('Loading from: ' + contextPath + '/student/dashboard-stats');
            fetch(contextPath + '/student/dashboard-stats')
                .then(r => {
                    console.log('Response status:', r.status);
                    if (!r.ok) throw new Error('HTTP ' + r.status);
                    return r.json();
                })
                .then(data => {
                    console.log('Data:', data);
                    if (data.success) {
                        const s = data.statistics;
                        document.getElementById('dashboardCards').innerHTML = `
                            <div class="card">
                                <div class="card-icon">📋</div>
                                <div class="card-title">My Applications</div>
                                <div class="card-value">${s.totalApplications}</div>
                            </div>
                            <div class="card">
                                <div class="card-icon">⭐</div>
                                <div class="card-title">Shortlisted</div>
                                <div class="card-value">${s.shortlisted}</div>
                            </div>
                            <div class="card">
                                <div class="card-icon">✅</div>
                                <div class="card-title">Accepted</div>
                                <div class="card-value">${s.accepted}</div>
                            </div>
                            <div class="card">
                                <div class="card-icon">🔍</div>
                                <div class="card-title">Open Positions</div>
                                <div class="card-value">${s.openInternships}</div>
                            </div>
                        `;
                        
                        if (data.recommendedInternships && data.recommendedInternships.length > 0) {
                            let html = '';
                            data.recommendedInternships.forEach(i => {
                                html += `<div class="internship-card">
                                    <div class="internship-header">
                                        <div>
                                            <div class="internship-title">${i.jobTitle}</div>
                                            <div class="internship-company">ID: ${i.internshipId}</div>
                                        </div>
                                        <span class="badge badge-active">Active</span>
                                    </div>
                                    <div class="internship-details">
                                        <div class="detail-item">📍 ${i.jobLocation}</div>
                                        <div class="detail-item">💰 ₹${i.stipendAmount}/month</div>
                                        <div class="detail-item">⏱️ ${i.durationMonths} months</div>
                                        <div class="detail-item">📅 Deadline: ${i.applicationDeadline}</div>
                                    </div>
                                    <button class="apply-btn" onclick="alert('Apply to: ' + '${i.jobTitle}')">View & Apply →</button>
                                </div>`;
                            });
                            document.getElementById('recommendedInternships').innerHTML = html;
                        }
                    }
                })
                .catch(e => {
                    console.error('Error:', e);
                    document.getElementById('dashboardCards').innerHTML = '<p>Error loading data</p>';
                });
        }
        
        document.addEventListener('DOMContentLoaded', loadDashboardStats);
    </script>
</body>
</html>
