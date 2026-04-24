package com.mitwpu.lca.servlet;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import com.mitwpu.lca.dao.UserDAO;
import com.mitwpu.lca.model.User;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 Basic user fields
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone"); // optional

        // 🔹 Student fields
        String roll = request.getParameter("roll");
        String deptCode = request.getParameter("deptCode");
        String deptName = request.getParameter("deptName");
        String cgpaStr = request.getParameter("cgpa");
        String semStr = request.getParameter("semester");

        // 🔹 Basic validation
        if (name == null || email == null || password == null || confirmPassword == null ||
            roll == null || deptCode == null || deptName == null ||
            cgpaStr == null || semStr == null ||
            name.isEmpty() || email.isEmpty() || password.isEmpty()) {

            response.sendRedirect("register.jsp?error=All fields are required");
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=Passwords do not match");
            return;
        }

        double cgpa = 0;
        int semester = 0;

        try {
            cgpa = Double.parseDouble(cgpaStr);
            semester = Integer.parseInt(semStr);
        } catch (Exception e) {
            response.sendRedirect("register.jsp?error=Invalid CGPA or Semester");
            return;
        }

        UserDAO dao = new UserDAO();

        // 🔴 Check duplicate email
        if (dao.getUserByEmail(email) != null) {
            response.sendRedirect("register.jsp?error=Email already exists");
            return;
        }

        // 🔹 Create User object
        User user = new User();
        user.setFullName(name);
        user.setEmail(email);
        user.setPassword(password); // later hash this
        user.setPhoneNumber(phone);
        user.setRole("STUDENT");
        user.setStatus("ACTIVE");

        // 🔹 Call DAO
        boolean success = dao.registerStudent(
                user,
                roll,
                deptCode,
                deptName,
                cgpa,
                semester
        );

        // 🔹 Response handling
        if (success) {
            response.sendRedirect("login.jsp?success=Registered successfully");
        } else {
            response.sendRedirect("register.jsp?error=Registration failed");
        }
    }
}