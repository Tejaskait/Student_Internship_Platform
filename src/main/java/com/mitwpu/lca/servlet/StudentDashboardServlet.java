package com.mitwpu.lca.servlet;

import java.io.PrintWriter;
import java.util.List;

import com.mitwpu.lca.dao.ApplicationDAO;
import com.mitwpu.lca.dao.InternshipDAO;
import com.mitwpu.lca.dao.StudentDAO;
import com.mitwpu.lca.model.Application;
import com.mitwpu.lca.model.Internship;
import com.mitwpu.lca.model.Student;
import com.mitwpu.lca.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/student/dashboard-stats")
public class StudentDashboardServlet extends HttpServlet {
    private final StudentDAO studentDAO = new StudentDAO();
    private final ApplicationDAO applicationDAO = new ApplicationDAO();
    private final InternshipDAO internshipDAO = new InternshipDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null || user.getRole() == null || !"STUDENT".equals(user.getRole())) {
            sendJsonResponse(response, false, "Unauthorized", 403);
            return;
        }

        try {
            System.out.println("DEBUG: Getting student for user ID: " + user.getUserId());
            Student student = studentDAO.getStudentByUserId(user.getUserId());
            if (student == null) {
                System.out.println("DEBUG: Student profile not found for user ID: " + user.getUserId());
                sendJsonResponse(response, false, "Student profile not found", 404);
                return;
            }

            System.out.println("DEBUG: Student found: " + student.getStudentId());

            // Get applications
            List<Application> applications = applicationDAO.getApplicationsByStudent(student.getStudentId());
            System.out.println("DEBUG: Found " + applications.size() + " applications");

            // Count by status
            int pending = 0, shortlisted = 0, accepted = 0, rejected = 0;
            for (Application app : applications) {
                switch (app.getStatus()) {
                    case "PENDING":
                        pending++;
                        break;
                    case "SHORTLISTED":
                        shortlisted++;
                        break;
                    case "ACCEPTED":
                        accepted++;
                        break;
                    case "REJECTED":
                        rejected++;
                        break;
                }
            }

            // Get recommended internships (first 3 open internships)
            List<Internship> internships = internshipDAO.getOpenInternships();
            System.out.println("DEBUG: Found " + internships.size() + " open internships");
            
            // Build response JSON
            StringBuilder json = new StringBuilder("{");
            json.append("\"success\":true,");
            json.append("\"student\":{")
                .append("\"name\":\"").append(escapeJson(user.getFullName())).append("\",")
                .append("\"cgpa\":").append(student.getCgpa()).append(",")
                .append("\"semester\":").append(student.getSemester()).append(",")
                .append("\"department\":\"").append(escapeJson(student.getDepartmentName() != null ? student.getDepartmentName() : "N/A")).append("\"")
                .append("},");

            json.append("\"statistics\":{")
                .append("\"totalApplications\":").append(applications.size()).append(",")
                .append("\"pending\":").append(pending).append(",")
                .append("\"shortlisted\":").append(shortlisted).append(",")
                .append("\"accepted\":").append(accepted).append(",")
                .append("\"rejected\":").append(rejected).append(",")
                .append("\"openInternships\":").append(internships.size())
                .append("},");

            // Add recommended internships
            json.append("\"recommendedInternships\":[");
            int count = 0;
            for (int i = 0; i < Math.min(3, internships.size()); i++) {
                Internship internship = internships.get(i);
                if (count > 0) json.append(",");
                json.append("{")
                    .append("\"internshipId\":").append(internship.getInternshipId()).append(",")
                    .append("\"jobTitle\":\"").append(escapeJson(internship.getJobTitle())).append("\",")
                    .append("\"jobLocation\":\"").append(escapeJson(internship.getJobLocation())).append("\",")
                    .append("\"stipendAmount\":").append(internship.getStipendAmount()).append(",")
                    .append("\"durationMonths\":").append(internship.getDurationMonths()).append(",")
                    .append("\"minimumCgpa\":").append(internship.getMinimumCgpa()).append(",")
                    .append("\"applicationDeadline\":\"").append(internship.getApplicationDeadline()).append("\"")
                    .append("}");
                count++;
            }
            json.append("]");

            json.append("}");

            try (PrintWriter out = response.getWriter()) {
                out.write(json.toString());
                out.flush();
            }
            System.out.println("DEBUG: Response sent successfully");
        } catch (java.io.IOException e) {
            System.out.println("DEBUG: Exception occurred: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            sendJsonResponse(response, false, "Error: " + e.getMessage(), 500);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, int status) {
        response.setStatus(status);
        response.setContentType("application/json");
        try (PrintWriter out = response.getWriter()) {
            out.write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
            out.flush();
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
