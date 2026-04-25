package com.mitwpu.lca.dao;

import com.mitwpu.lca.model.Internship;
import com.mitwpu.lca.util.DBConnection;
import java.sql.*;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;

/**
 * Data Access Object for Internship entity
 * Handles CRUD operations for internship postings
 */
public class InternshipDAO {
    
    /**
     * Get all internships
     * @return List of all internships
     */
    public List<Internship> getAllInternships() {
        String sql = "SELECT internship_id, company_id, job_title, job_description, job_location, " +
                     "stipend_amount, stipend_type, duration_months, start_date, end_date, application_deadline, " +
                     "minimum_cgpa, required_skills, total_positions, filled_positions, status, created_at, updated_at " +
                     "FROM internships ORDER BY application_deadline DESC";
        
        List<Internship> internships = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Internship internship = mapResultSetToInternship(rs);
                internships.add(internship);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all internships: " + e.getMessage());
            e.printStackTrace();
        }
        return internships;
    }
    
    /**
     * Get all open internships
     * @return List of open internships
     */
    public List<Internship> getOpenInternships() {
        String sql = "SELECT internship_id, company_id, job_title, job_description, job_location, " +
                     "stipend_amount, stipend_type, duration_months, start_date, end_date, application_deadline, " +
                     "minimum_cgpa, required_skills, total_positions, filled_positions, status, created_at, updated_at " +
                     "FROM internships WHERE status = 'OPEN' AND application_deadline >= CURDATE() " +
                     "ORDER BY application_deadline ASC";
        
        List<Internship> internships = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Internship internship = mapResultSetToInternship(rs);
                internships.add(internship);
            }
        } catch (SQLException e) {
            System.err.println("Error getting open internships: " + e.getMessage());
            e.printStackTrace();
        }
        return internships;
    }
    
    /**
     * Get internships by company
     * @param companyId Company ID
     * @return List of internships for the company
     */
    public List<Internship> getInternshipsByCompany(int companyId) {
        String sql = "SELECT internship_id, company_id, job_title, job_description, job_location, " +
                     "stipend_amount, stipend_type, duration_months, start_date, end_date, application_deadline, " +
                     "minimum_cgpa, required_skills, total_positions, filled_positions, status, created_at, updated_at " +
                     "FROM internships WHERE company_id = ? ORDER BY created_at DESC";
        
        List<Internship> internships = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, companyId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Internship internship = mapResultSetToInternship(rs);
                internships.add(internship);
            }
        } catch (SQLException e) {
            System.err.println("Error getting internships by company: " + e.getMessage());
            e.printStackTrace();
        }
        return internships;
    }
    
    /**
     * Get internship by ID
     * @param internshipId Internship ID
     * @return Internship object or null if not found
     */
    public Internship getInternshipById(int internshipId) {
        String sql = "SELECT internship_id, company_id, job_title, job_description, job_location, " +
                     "stipend_amount, stipend_type, duration_months, start_date, end_date, application_deadline, " +
                     "minimum_cgpa, required_skills, total_positions, filled_positions, status, created_at, updated_at " +
                     "FROM internships WHERE internship_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internshipId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToInternship(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getting internship by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Create new internship
     * @param internship Internship object to create
     * @return true if internship created successfully, false otherwise
     */
    public boolean createInternship(Internship internship) {
        String sql = "INSERT INTO internships (company_id, job_title, job_description, job_location, " +
                     "stipend_amount, stipend_type, duration_months, start_date, end_date, application_deadline, " +
                     "minimum_cgpa, required_skills, total_positions, filled_positions, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internship.getCompanyId());
            stmt.setString(2, internship.getJobTitle());
            stmt.setString(3, internship.getJobDescription());
            stmt.setString(4, internship.getJobLocation());
            stmt.setDouble(5, internship.getStipendAmount());
            stmt.setString(6, internship.getStipendType());
            stmt.setInt(7, internship.getDurationMonths());
            stmt.setDate(8, java.sql.Date.valueOf(internship.getStartDate()));
            stmt.setDate(9, java.sql.Date.valueOf(internship.getEndDate()));
            stmt.setDate(10, java.sql.Date.valueOf(internship.getApplicationDeadline()));
            stmt.setDouble(11, internship.getMinimumCgpa());
            stmt.setString(12, internship.getRequiredSkills());
            stmt.setInt(13, internship.getTotalPositions());
            stmt.setInt(14, internship.getFilledPositions());
            stmt.setString(15, internship.getStatus());
            
            int rowsInserted = stmt.executeUpdate();
            return rowsInserted > 0;
        } catch (SQLException e) {
            System.err.println("Error creating internship: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update internship
     * @param internship Internship object with updated values
     * @return true if internship updated successfully, false otherwise
     */
    public boolean updateInternship(Internship internship) {
        String sql = "UPDATE internships SET company_id = ?, job_title = ?, job_description = ?, job_location = ?, " +
                     "stipend_amount = ?, stipend_type = ?, duration_months = ?, start_date = ?, end_date = ?, " +
                     "application_deadline = ?, minimum_cgpa = ?, required_skills = ?, total_positions = ?, " +
                     "filled_positions = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE internship_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internship.getCompanyId());
            stmt.setString(2, internship.getJobTitle());
            stmt.setString(3, internship.getJobDescription());
            stmt.setString(4, internship.getJobLocation());
            stmt.setDouble(5, internship.getStipendAmount());
            stmt.setString(6, internship.getStipendType());
            stmt.setInt(7, internship.getDurationMonths());
            stmt.setDate(8, java.sql.Date.valueOf(internship.getStartDate()));
            stmt.setDate(9, java.sql.Date.valueOf(internship.getEndDate()));
            stmt.setDate(10, java.sql.Date.valueOf(internship.getApplicationDeadline()));
            stmt.setDouble(11, internship.getMinimumCgpa());
            stmt.setString(12, internship.getRequiredSkills());
            stmt.setInt(13, internship.getTotalPositions());
            stmt.setInt(14, internship.getFilledPositions());
            stmt.setString(15, internship.getStatus());
            stmt.setInt(16, internship.getInternshipId());
            
            int rowsUpdated = stmt.executeUpdate();
            return rowsUpdated > 0;
        } catch (SQLException e) {
            System.err.println("Error updating internship: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete internship by ID
     * @param internshipId Internship ID
     * @return true if internship deleted successfully, false otherwise
     */
    public boolean deleteInternship(int internshipId) {
        String sql = "DELETE FROM internships WHERE internship_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, internshipId);
            int rowsDeleted = stmt.executeUpdate();
            return rowsDeleted > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting internship: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Helper method to map ResultSet to Internship object
     */
    private Internship mapResultSetToInternship(ResultSet rs) throws SQLException {
        Internship internship = new Internship();
        internship.setInternshipId(rs.getInt("internship_id"));
        internship.setCompanyId(rs.getInt("company_id"));
        internship.setJobTitle(rs.getString("job_title"));
        internship.setJobDescription(rs.getString("job_description"));
        internship.setJobLocation(rs.getString("job_location"));
        internship.setStipendAmount(rs.getDouble("stipend_amount"));
        internship.setStipendType(rs.getString("stipend_type"));
        internship.setDurationMonths(rs.getInt("duration_months"));
        
        java.sql.Date startDate = rs.getDate("start_date");
        if (startDate != null) internship.setStartDate(startDate.toLocalDate());
        
        java.sql.Date endDate = rs.getDate("end_date");
        if (endDate != null) internship.setEndDate(endDate.toLocalDate());
        
        java.sql.Date deadlineDate = rs.getDate("application_deadline");
        if (deadlineDate != null) internship.setApplicationDeadline(deadlineDate.toLocalDate());
        
        internship.setMinimumCgpa(rs.getDouble("minimum_cgpa"));
        internship.setRequiredSkills(rs.getString("required_skills"));
        internship.setTotalPositions(rs.getInt("total_positions"));
        internship.setFilledPositions(rs.getInt("filled_positions"));
        internship.setStatus(rs.getString("status"));
        java.sql.Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) internship.setCreatedAt(createdTs.toLocalDateTime());
        java.sql.Timestamp updatedTs = rs.getTimestamp("updated_at");
        if (updatedTs != null) internship.setUpdatedAt(updatedTs.toLocalDateTime());
        return internship;
    }
    
    
    /**
     * Check if internship deadline is passed
     */
    public boolean isDeadlinePassed(int internshipId) {
        String sql = "SELECT application_deadline FROM internships WHERE internship_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, internshipId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Date deadline = rs.getDate("application_deadline");
                return deadline.before(new java.util.Date());
            }

        } catch (SQLException e) {
            System.err.println("Error checking deadline: " + e.getMessage());
            e.printStackTrace();
        }

        return true; // safe fallback
    }
}
