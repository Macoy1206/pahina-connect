package com.pahinaconnect.servlet.admin;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Timestamp;
import java.util.Calendar;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.dao.BookIssueDAO;
import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.Book;
import com.pahinaconnect.model.BookIssue;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.DBConnection;
import com.pahinaconnect.util.EmailUtil;

public class IssueBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final UserDAO userDAO = new UserDAO();
    private final BookIssueDAO issueDAO = new BookIssueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String studentIdParam = req.getParameter("studentId");
        try {
            req.setAttribute("books", bookDAO.getAllBooks());
            if (studentIdParam != null && !studentIdParam.trim().isEmpty()) {
                User student = userDAO.findByStudentId(studentIdParam.trim());
                if (student != null) {
                    req.setAttribute("student", student);
                    req.setAttribute("activeIssues", issueDAO.getActiveIssuesByStudent(student.getId()));
                } else {
                    req.setAttribute("searchError", "No student found with ID: " + studentIdParam);
                }
            }
            req.getRequestDispatcher("/WEB-INF/views/admin/issue-book.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/issue-book.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String studentIdCode = req.getParameter("studentIdCode");
        String bookIdParam   = req.getParameter("bookId");
        String dueDaysParam  = req.getParameter("dueDays");
        String notes         = req.getParameter("notes");

        try {
            User student = userDAO.findByStudentId(studentIdCode.trim());
            if (student == null) {
                req.setAttribute("error", "Student not found.");
                req.setAttribute("books", bookDAO.getAllBooks());
                req.getRequestDispatcher("/WEB-INF/views/admin/issue-book.jsp").forward(req, res);
                return;
            }

            int bookId = Integer.parseInt(bookIdParam);
            Book book = bookDAO.findById(bookId);
            if (book == null || !book.isAvailable()) {
                req.setAttribute("error", "Book is not available for issue.");
                req.setAttribute("books", bookDAO.getAllBooks());
                req.setAttribute("student", student);
                req.getRequestDispatcher("/WEB-INF/views/admin/issue-book.jsp").forward(req, res);
                return;
            }

            int dueDays = (dueDaysParam != null && !dueDaysParam.isEmpty()) ? Integer.parseInt(dueDaysParam) : 14;
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_MONTH, dueDays);
            Timestamp dueDate = new Timestamp(cal.getTimeInMillis());

            User admin = (User) req.getSession().getAttribute("loggedUser");

            BookIssue issue = new BookIssue();
            issue.setBookId(bookId);
            issue.setStudentId(student.getId());
            issue.setDueDate(dueDate);
            issue.setIssuedBy(admin.getId());
            issue.setNotes(notes);

            // Transactional issue
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    boolean decremented = bookDAO.decrementAvailable(bookId, conn);
                    if (!decremented) {
                        conn.rollback();
                        req.setAttribute("error", "Book is no longer available.");
                        req.setAttribute("books", bookDAO.getAllBooks());
                        req.setAttribute("student", student);
                        req.getRequestDispatcher("/WEB-INF/views/admin/issue-book.jsp").forward(req, res);
                        return;
                    }
                    int issueId = issueDAO.issueBook(issue, conn);
                    conn.commit();

                    // Send email reminder
                    EmailUtil.sendDueDateReminder(student.getEmail(), student.getFirstName(),
                            book.getTitle(), dueDate.toString().substring(0, 10));

                    res.sendRedirect(req.getContextPath() + "/admin/issue-book?success=issued&studentId=" + studentIdCode);
                } catch (Exception ex) {
                    conn.rollback();
                    throw ex;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to issue book: " + e.getMessage());
            try {
                req.setAttribute("books", bookDAO.getAllBooks());
            } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/issue-book.jsp").forward(req, res);
        }
    }
}
