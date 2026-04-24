package com.mitwpu.lca.dao;

import com.mitwpu.lca.model.User;
import com.mitwpu.lca.util.DBConnection;
import java.sql.*;
import java.util.*;

/**
 * Data Access Object for User entity
 * Handles CRUD operations and authentication for users
 */
public class UserDAO {
    
    /**
     * Authenticate user by email and password
     * @param email User email
     * @param password User password
     * @return User object if authentication successful, null otherwise
     */
    public User authenticate(String email, String password) {
        String sql = "SELECT user_id, email, password, full_name, role, phone_number, status, created_at, updated_at " +
                     "FROM users WHERE email = ? AND status = 'ACTIVE'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                // Verify password (in production, use hashing like BCrypt)
                String storedPassword = rs.getString("password");
                if (password.equals(storedPassword)) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setFullName(rs.getString("full_name"));
                    user.setRole(rs.getString("role"));
                    user.setPhoneNumber(rs.getString("phone_number"));
                    user.setStatus(rs.getString("status"));
                    java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
                    if (createdTs != null) user.setCreatedAt(createdTs.toLocalDateTime());
                    java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
                    if (updatedTs != null) user.setUpdatedAt(updatedTs.toLocalDateTime());
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error during user authentication: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
 // REGISTER STUDENT (users + students table)
    public boolean registerStudent(User user,
                                   String rollNumber,
                                   String deptCode,
                                   String deptName,
                                   double cgpa,
                                   int semester) {

        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psStudent = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // transaction start

            // 1️⃣ Insert into users table
            String userSql = "INSERT INTO users (email, password, full_name, role, phone_number, status) " +
                             "VALUES (?, ?, ?, 'STUDENT', ?, 'ACTIVE')";

            psUser = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS);

            psUser.setString(1, user.getEmail());
            psUser.setString(2, user.getPassword());
            psUser.setString(3, user.getFullName());
            psUser.setString(4, user.getPhoneNumber());

            int rows = psUser.executeUpdate();

            if (rows == 0) {
                conn.rollback();
                return false;
            }

            // 2️⃣ Get user_id
            rs = psUser.getGeneratedKeys();
            int userId = 0;

            if (rs.next()) {
                userId = rs.getInt(1);
            } else {
                conn.rollback();
                return false;
            }

            // 3️⃣ Insert into students table
            String studentSql = "INSERT INTO students (user_id, roll_number, department_code, department_name, cgpa, semester) " +
                                "VALUES (?, ?, ?, ?, ?, ?)";

            psStudent = conn.prepareStatement(studentSql);

            psStudent.setInt(1, userId);
            psStudent.setString(2, rollNumber);
            psStudent.setString(3, deptCode);
            psStudent.setString(4, deptName);
            psStudent.setDouble(5, cgpa);
            psStudent.setInt(6, semester);

            psStudent.executeUpdate();

            conn.commit(); // ✅ success
            return true;

        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;

        } finally {
            try {
                if (rs != null) rs.close();
                if (psUser != null) psUser.close();
                if (psStudent != null) psStudent.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    /**
     * Get user by ID
     * @param userId User ID
     * @return User object or null if not found
     */
    public User getUserById(int userId) {
        String sql = "SELECT user_id, email, password, full_name, role, phone_number, status, created_at, updated_at " +
                     "FROM users WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setStatus(rs.getString("status"));
                java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
                if (createdTs != null) user.setCreatedAt(createdTs.toLocalDateTime());
                java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) user.setUpdatedAt(updatedTs.toLocalDateTime());
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get user by email
     * @param email User email
     * @return User object or null if not found
     */
    public User getUserByEmail(String email) {
        String sql = "SELECT user_id, email, password, full_name, role, phone_number, status, created_at, updated_at " +
                     "FROM users WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setStatus(rs.getString("status"));
                java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
                if (createdTs != null) user.setCreatedAt(createdTs.toLocalDateTime());
                java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) user.setUpdatedAt(updatedTs.toLocalDateTime());
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by email: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Create new user
     * @param user User object to create
     * @return true if user created successfully, false otherwise
     */
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (email, password, full_name, role, phone_number, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getEmail());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getFullName());
            stmt.setString(4, user.getRole());
            stmt.setString(5, user.getPhoneNumber());
            stmt.setString(6, user.getStatus());
            
            int rowsInserted = stmt.executeUpdate();
            return rowsInserted > 0;
        } catch (SQLException e) {
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update user
     * @param user User object with updated values
     * @return true if user updated successfully, false otherwise
     */
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET email = ?, password = ?, full_name = ?, role = ?, " +
                     "phone_number = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getEmail());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getFullName());
            stmt.setString(4, user.getRole());
            stmt.setString(5, user.getPhoneNumber());
            stmt.setString(6, user.getStatus());
            stmt.setInt(7, user.getUserId());
            
            int rowsUpdated = stmt.executeUpdate();
            return rowsUpdated > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get all users with specified role
     * @param role User role (ADMIN or STUDENT)
     * @return List of users with specified role
     */
    public List<User> getUsersByRole(String role) {
        String sql = "SELECT user_id, email, password, full_name, role, phone_number, status, created_at, updated_at " +
                     "FROM users WHERE role = ? ORDER BY created_at DESC";
        
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, role);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setStatus(rs.getString("status"));
                java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
                if (createdTs != null) user.setCreatedAt(createdTs.toLocalDateTime());
                java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) user.setUpdatedAt(updatedTs.toLocalDateTime());
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error getting users by role: " + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }
    
    /**
     * Get all active users
     * @return List of all active users
     */
    public List<User> getAllActiveUsers() {
        String sql = "SELECT user_id, email, password, full_name, role, phone_number, status, created_at, updated_at " +
                     "FROM users WHERE status = 'ACTIVE' ORDER BY created_at DESC";
        
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setStatus(rs.getString("status"));
                java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
                if (createdTs != null) user.setCreatedAt(createdTs.toLocalDateTime());
                java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) user.setUpdatedAt(updatedTs.toLocalDateTime());
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all active users: " + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }
    
    /**
     * Change user status (ACTIVE, INACTIVE, BLOCKED)
     * @param userId User ID
     * @param status New status
     * @return true if status changed successfully, false otherwise
     */
    public boolean changeUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, userId);
            
            int rowsUpdated = stmt.executeUpdate();
            return rowsUpdated > 0;
        } catch (SQLException e) {
            System.err.println("Error changing user status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete user by ID
     * @param userId User ID
     * @return true if user deleted successfully, false otherwise
     */
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            int rowsDeleted = stmt.executeUpdate();
            return rowsDeleted > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting user: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
