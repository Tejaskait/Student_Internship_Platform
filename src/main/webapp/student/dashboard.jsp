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
    <title>Student Portal - InternshipHub</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/student/dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <i class="fas fa-graduation-cap"></i>
                <span class="brand-text">InternshipHub</span>
            </div>
            <ul class="nav-menu">
                <li><a href="<%= request.getContextPath() %>/student/dashboard.jsp" class="nav-link active">
                    <i class="fas fa-home"></i> Dashboard
                </a></li>
                <li><a href="<%= request.getContextPath() %>/student/browse-internships.jsp" class="nav-link">
                    <i class="fas fa-briefcase"></i> Browse Internships
                </a></li>
                <li><a href="<%= request.getContextPath() %>/student/my-applications.jsp" class="nav-link">
                    <i class="fas fa-file-alt"></i> My Applications
                </a></li>
                <li><a href="<%= request.getContextPath() %>/student/profile.jsp" class="nav-link">
                    <i class="fas fa-user-circle"></i> Profile
                </a></li>
            </ul>
            <div class="nav-user">
                <div class="user-menu">
                    <span class="user-name"><%= user.getFullName() %></span>
                    <form action="<%= request.getContextPath() %>/logout" method="POST" style="display:inline;">
                        <button type="submit" class="logout-btn">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </nav>

    <div class="hero-section">
        <div class="hero-content">
            <h1>Welcome back, <%= user.getFullName() %>! 👋</h1>
            <p>Track your internship journey, explore opportunities, and manage your applications all in one place.</p>
        </div>
        <div class="hero-bg-pattern"></div>
    </div>

    <main class="main-content">
        <!-- Stats Section -->
        <section class="stats-section">
            <h2 class="section-title">Your Progress</h2>
            <div class="stats-grid" id="dashboardCards">
                <div class="stat-card loading">
                    <div class="skeleton"></div>
                </div>
                <div class="stat-card loading">
                    <div class="skeleton"></div>
                </div>
                <div class="stat-card loading">
                    <div class="skeleton"></div>
                </div>
                <div class="stat-card loading">
                    <div class="skeleton"></div>
                </div>
            </div>
        </section>

        <!-- Recommended Internships Section -->
        <section class="internships-section">
            <div class="section-header">
                <h2 class="section-title">💼 Recommended For You</h2>
                <a href="<%= request.getContextPath() %>/student/browse-internships.jsp" class="view-all-btn">View All →</a>
            </div>
            <div class="internships-container" id="recommendedInternships">
                <p class="loading-text">Loading opportunities...</p>
            </div>
        </section>

        <!-- Recent Applications Section -->
        <section class="applications-section">
            <div class="section-header">
                <h2 class="section-title">📋 Your Applications</h2>
                <a href="<%= request.getContextPath() %>/student/my-applications.jsp" class="view-all-btn">View All →</a>
            </div>
            <div class="applications-container" id="recentApplications">
                <p class="loading-text">Loading applications...</p>
            </div>
        </section>
    </main>

    <script>
        const contextPath = '<%= request.getContextPath() %>';
        
        function loadDashboardStats() {
            fetch(contextPath + '/student/dashboard-stats')
                .then(r => {
                    if (!r.ok) throw new Error('HTTP ' + r.status);
                    return r.json();
                })
                .then(data => {
                    if (data.success) {
                        const s = data.statistics;
                        document.getElementById('dashboardCards').innerHTML = `
                            <div class="stat-card">
                                <div class="stat-icon applications">
                                    <i class="fas fa-file-alt"></i>
                                </div>
                                <div class="stat-content">
                                    <div class="stat-label">Total Applications</div>
                                    <div class="stat-value">${s.totalApplications}</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon shortlisted">
                                    <i class="fas fa-star"></i>
                                </div>
                                <div class="stat-content">
                                    <div class="stat-label">Shortlisted</div>
                                    <div class="stat-value">${s.shortlisted}</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon accepted">
                                    <i class="fas fa-check-circle"></i>
                                </div>
                                <div class="stat-content">
                                    <div class="stat-label">Accepted</div>
                                    <div class="stat-value">${s.accepted}</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon open">
                                    <i class="fas fa-briefcase"></i>
                                </div>
                                <div class="stat-content">
                                    <div class="stat-label">Open Positions</div>
                                    <div class="stat-value">${s.openInternships}</div>
                                </div>
                            </div>
                        `;
                        
                        if (data.recommendedInternships && data.recommendedInternships.length > 0) {
                            let html = '';
                            data.recommendedInternships.slice(0, 3).forEach(i => {
                                html += `
                                    <div class="internship-card">
                                        <div class="internship-badge">RECOMMENDED</div>
                                        <div class="internship-header">
                                            <h3>${i.jobTitle}</h3>
                                            <p class="company-name">ID: ${i.internshipId}</p>
                                        </div>
                                        <div class="internship-details">
                                            <span class="detail"><i class="fas fa-map-marker-alt"></i> ${i.jobLocation}</span>
                                            <span class="detail"><i class="fas fa-rupee-sign"></i> ₹${i.stipendAmount}/month</span>
                                            <span class="detail"><i class="fas fa-calendar"></i> ${i.durationMonths} months</span>
                                        </div>
                                        <button class="apply-btn" onclick="window.location.href='${contextPath}/student/browse-internships.jsp?id=${i.internshipId}'">
                                            View & Apply <i class="fas fa-arrow-right"></i>
                                        </button>
                                    </div>`;
                            });
                            document.getElementById('recommendedInternships').innerHTML = html || '<p class="empty-msg">No recommendations yet</p>';
                        }
                    }
                })
                .catch(e => {
                    console.error('Error:', e);
                    document.getElementById('dashboardCards').innerHTML = '<p class="error-msg">Error loading statistics</p>';
                });
        }
        
        document.addEventListener('DOMContentLoaded', loadDashboardStats);
    </script>
</body>
</html>
