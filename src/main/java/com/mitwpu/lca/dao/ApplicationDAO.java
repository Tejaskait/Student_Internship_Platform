package com.mitwpu.lca.dao;

import com.mitwpu.lca.model.Application;
import com.mitwpu.lca.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Internship Application operations
 * Handles CRUD operations for student internship applications
 */
public class ApplicationDAO {
    
    /**
     * Get application by ID
     * @param applicationId Application ID
     * @return Application object or null if not found
     */
    public Application getApplicationById(int applicationId) {
        String sql = "SELECT application_id, student_id, internship_id, applied_date, status, " +
                     "cover_letter, rating, feedback, created_at, updated_at " +
                     "FROM student_applications WHERE application_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, applicationId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToApplication(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getting application by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get all applications by student
     * @param studentId Student ID
     * @return List of applications for the student
     */
    public List<Application> getApplicationsByStudent(int studentId) {
        String sql = "SELECT application_id, student_id, internship_id, applied_date, status, " +
                     "cover_letter, rating, feedback, created_at, updated_at " +
                     "FROM student_applications WHERE student_id = ? ORDER BY applied_date DESC";
        
        List<Application> applications = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, studentId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                applications.add(mapResultSetToApplication(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting applications by student: " + e.getMessage());
            e.printStackTrace();
        }
        return applications;
    }
    
    /**
     * Get all applications for an internship
     * @param internshipId Internship ID
     * @return List of applications for the internship
     */
    public List<Application> getApplicationsByInternship(int internshipId) {
        String sql = "SELECT application_id, student_id, internship_id, applied_date, status, " +
                     "cover_letter, rating, feedback, created_at, updated_at " +
                     "FROM student_applications WHERE internship_id = ? ORDER BY applied_date DESC";
        
        List<Application> applications = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internshipId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                applications.add(mapResultSetToApplication(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting applications by internship: " + e.getMessage());
            e.printStackTrace();
        }
        return applications;
    }
    
    /**
     * Get all applications by status
     * @param status Application status (PENDING, SHORTLISTED, REJECTED, ACCEPTED)
     * @return List of applications with specified status
     */
    public List<Application> getApplicationsByStatus(String status) {
        String sql = "SELECT application_id, student_id, internship_id, applied_date, status, " +
                     "cover_letter, rating, feedback, created_at, updated_at " +
                     "FROM student_applications WHERE status = ? ORDER BY applied_date DESC";
        
        List<Application> applications = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                applications.add(mapResultSetToApplication(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting applications by status: " + e.getMessage());
            e.printStackTrace();
        }
        return applications;
    }
    
    /**
     * Check if student has already applied for internship
     * @param studentId Student ID
     * @param internshipId Internship ID
     * @return true if already applied, false otherwise
     */
    public boolean hasStudentApplied(int studentId, int internshipId) {
    	String sql = "SELECT COUNT(*) as count FROM applications "
    			+ "WHERE student_id = ? AND internship_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, studentId);
            stmt.setInt(2, internshipId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error checking if student applied: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Create new application
     * @param application Application object to create
     * @return true if application created successfully, false otherwise
     */
    public boolean createApplication(Application application) {
        String sql = "INSERT INTO student_applications (student_id, internship_id, applied_date, " +
                     "status, cover_letter) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, application.getStudentId());
            stmt.setInt(2, application.getInternshipId());
            stmt.setDate(3, java.sql.Date.valueOf(application.getAppliedDate()));
            stmt.setString(4, application.getStatus());
            stmt.setString(5, application.getCoverLetter());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error creating application: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update application status
     * @param applicationId Application ID
     * @param status New status
     * @return true if updated successfully, false otherwise
     */
    public boolean updateApplicationStatus(int applicationId, String status) {
        String sql = "UPDATE student_applications SET status = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE application_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, applicationId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating application status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update application with rating and feedback
     * @param application Application object with updates
     * @return true if updated successfully, false otherwise
     */
    public boolean updateApplication(Application application) {
        String sql = "UPDATE student_applications SET status = ?, rating = ?, feedback = ?, " +
                     "updated_at = CURRENT_TIMESTAMP WHERE application_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, application.getStatus());
            stmt.setObject(2, application.getRating() != null ? application.getRating() : null);
            stmt.setString(3, application.getFeedback());
            stmt.setInt(4, application.getApplicationId());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating application: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get shortlisted applications for internship
     * @param internshipId Internship ID
     * @return List of shortlisted applications
     */
    public List<Application> getShortlistedApplications(int internshipId) {
        String sql = "SELECT application_id, student_id, internship_id, applied_date, status, " +
                     "cover_letter, rating, feedback, created_at, updated_at " +
                     "FROM student_applications WHERE internship_id = ? AND status = 'SHORTLISTED' " +
                     "ORDER BY applied_date DESC";
        
        List<Application> applications = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internshipId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                applications.add(mapResultSetToApplication(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting shortlisted applications: " + e.getMessage());
            e.printStackTrace();
        }
        return applications;
    }
    
    /**
     * Get accepted applications
     * @param studentId Student ID
     * @return List of accepted applications for the student
     */
    public List<Application> getAcceptedApplications(int studentId) {
        String sql = "SELECT application_id, student_id, internship_id, applied_date, status, " +
                     "cover_letter, rating, feedback, created_at, updated_at " +
                     "FROM student_applications WHERE student_id = ? AND status = 'ACCEPTED' " +
                     "ORDER BY applied_date DESC";
        
        List<Application> applications = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, studentId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                applications.add(mapResultSetToApplication(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getting accepted applications: " + e.getMessage());
            e.printStackTrace();
        }
        return applications;
    }
    
    /**
     * Delete application
     * @param applicationId Application ID
     * @return true if deleted successfully, false otherwise
     */
    public boolean deleteApplication(int applicationId) {
        String sql = "DELETE FROM student_applications WHERE application_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, applicationId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting application: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get application count for internship by status
     * @param internshipId Internship ID
     * @param status Application status
     * @return Count of applications with specified status
     */
    public int getApplicationCountByStatus(int internshipId, String status) {
        String sql = "SELECT COUNT(*) as count FROM applications " +
                     "WHERE internship_id = ? AND status = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internshipId);
            stmt.setString(2, status);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.err.println("Error getting application count: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Helper method to map ResultSet to Application object
     */
    private Application mapResultSetToApplication(ResultSet rs) throws SQLException {
        Application application = new Application();
        application.setApplicationId(rs.getInt("application_id"));
        application.setStudentId(rs.getInt("student_id"));
        application.setInternshipId(rs.getInt("internship_id"));
        application.setAppliedDate(rs.getDate("applied_date").toLocalDate());
        application.setStatus(rs.getString("status"));
        application.setCoverLetter(rs.getString("cover_letter"));
        
        Object rating = rs.getObject("rating");
        if (rating != null) {
            application.setRating(((Number) rating).doubleValue());
        }
        
        application.setFeedback(rs.getString("feedback"));
        
        java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) application.setCreatedAt(createdTs.toLocalDateTime());
        java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
        if (updatedTs != null) application.setUpdatedAt(updatedTs.toLocalDateTime());
        
        return application;
    }
    public boolean applyForInternship(int studentId, int internshipId, int companyId) {
        try (Connection conn = DBConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO applications (student_id, internship_id, company_id, status) VALUES (?, ?, ?, 'PENDING')"
            );

            ps.setInt(1, studentId);
            ps.setInt(2, internshipId);
            ps.setInt(3, companyId);

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLIntegrityConstraintViolationException e) {
            return false; // already applied
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getCompanyIdByInternship(int internshipId) {
        try (Connection conn = DBConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "SELECT company_id FROM internships WHERE internship_id=?"
            );

            ps.setInt(1, internshipId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("company_id");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public ResultSet getApplicationsForStudent(int studentId) {
        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT a.*, i.job_title, c.company_name " +
                         "FROM applications a " +
                         "JOIN internships i ON a.internship_id = i.internship_id " +
                         "JOIN companies c ON a.company_id = c.company_id " +
                         "WHERE a.student_id = ?";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);

            return ps.executeQuery();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public List<Application> getApplicationsFromMainTable(int studentId) {
        List<Application> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT * FROM applications WHERE student_id = ?";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Application app = new Application();
                app.setApplicationId(rs.getInt("application_id"));
                app.setStudentId(rs.getInt("student_id"));
                app.setInternshipId(rs.getInt("internship_id"));
                app.setStatus(rs.getString("status"));

                // optional (if column exists)
                try {
                    app.setAppliedDate(rs.getDate("created_at").toLocalDate());
                } catch (Exception ignored) {}

                list.add(app);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
