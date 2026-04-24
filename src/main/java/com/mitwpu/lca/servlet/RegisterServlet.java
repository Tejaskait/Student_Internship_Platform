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

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=Passwords do not match");
            return;
        }

        UserDAO dao = new UserDAO();

        // Check if email exists
        if (dao.getUserByEmail(email) != null) {
            response.sendRedirect("register.jsp?error=Email already exists");
            return;
        }

        // Create user object
        User user = new User();
        user.setFullName(name);
        user.setEmail(email);
        user.setPassword(password);
        user.setPhoneNumber(phone);
        user.setRole("STUDENT");
        user.setStatus("ACTIVE");

        // Insert into USERS table only
        boolean success = dao.createUser(user);

        if (success) {
            response.sendRedirect("login.jsp?success=Registered successfully");
        } else {
            response.sendRedirect("register.jsp?error=Registration failed");
        }
    }
}