package com.mitwpu.lca.servlet;

import com.mitwpu.lca.dao.ApplicationDAO;
import com.mitwpu.lca.dao.InternshipDAO;
import com.mitwpu.lca.dao.StudentDAO;
import com.mitwpu.lca.model.Student;
import com.mitwpu.lca.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/student/apply")
public class ApplyInternshipServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            // 🔹 1. Session check
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Session expired\"}");
                return;
            }

            User user = (User) session.getAttribute("user");

            if (user == null || !"STUDENT".equals(user.getRole())) {
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized access\"}");
                return;
            }

            // 🔹 2. Get internshipId
            String internshipParam = request.getParameter("internshipId");

            if (internshipParam == null || internshipParam.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid internship\"}");
                return;
            }

            int internshipId = Integer.parseInt(internshipParam);

            // 🔹 3. Get student
            StudentDAO studentDAO = new StudentDAO();
            Student student = studentDAO.getStudentByUserId(user.getUserId());

            if (student == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Complete profile first\"}");
                return;
            }

            int studentId = student.getStudentId();

            // 🔹 4. Application DAO
            ApplicationDAO dao = new ApplicationDAO();

            // 🔥 Prevent duplicate application
            if (dao.hasStudentApplied(studentId, internshipId)) {
                response.getWriter().write("{\"success\":false,\"message\":\"You already applied for this internship\"}");
                return;
            }

            // 🔹 5. Get company ID
            int companyId = dao.getCompanyIdByInternship(internshipId);

            if (companyId == 0) {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid internship data\"}");
                return;
            }

            // 🔹 6. Apply
            boolean success = dao.applyForInternship(studentId, internshipId, companyId);

            if (success) {
                response.getWriter().write("{\"success\":true,\"message\":\"Application submitted successfully!\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Already applied or failed\"}");
            }
            
         // DAO objects
            ApplicationDAO appDao = new ApplicationDAO();
            InternshipDAO internshipDAO = new InternshipDAO();

            // ❌ 1. Cannot apply twice
            if (appDao.hasStudentApplied(studentId, internshipId)) {
                response.getWriter().write("{\"success\":false,\"message\":\"Already applied\"}");
                return;
            }

            // ❌ 2. Cannot apply after deadline
            if (internshipDAO.isDeadlinePassed(internshipId)) {
                response.getWriter().write("{\"success\":false,\"message\":\"Deadline passed\"}");
                return;
            }
            

        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid input\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Server error occurred\"}");
        }
    }
    
    
}