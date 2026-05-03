package com.pahinaconnect.servlet.admin;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

import com.pahinaconnect.dao.BookIssueDAO;
import com.pahinaconnect.model.BookIssue;
import com.pahinaconnect.util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ReminderServlet extends HttpServlet {

    private final BookIssueDAO issueDAO = new BookIssueDAO();
    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("MMMM dd, yyyy");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            issueDAO.updateOverdueStatuses();
            req.setAttribute("dueSoon",   issueDAO.getIssuesDueSoon(3));
            req.setAttribute("overdue",   issueDAO.getOverdueIssuesWithEmail());
            req.setAttribute("allActive", issueDAO.getAllActiveIssuesWithEmail());
            req.getRequestDispatcher("/WEB-INF/views/admin/reminders.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error loading reminders: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/reminders.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        int sent = 0, failed = 0;

        try {
            issueDAO.updateOverdueStatuses();

            if ("sendOverdue".equals(action)) {
                // Send overdue notices to all overdue borrowers
                List<BookIssue> overdueList = issueDAO.getOverdueIssuesWithEmail();
                for (BookIssue issue : overdueList) {
                    if (issue.getStudentEmail() == null) continue;
                    String firstName = issue.getStudentName().split(" ")[0];
                    long days = issue.getDaysOverdue();
                    double fine = Math.min(days * 5.0, 500.0);
                    boolean ok = EmailUtil.sendOverdueNotice(
                        issue.getStudentEmail(), firstName,
                        issue.getBookTitle(), days, fine
                    );
                    if (ok) sent++; else failed++;
                }
                req.setAttribute("success", "Overdue notices sent: " + sent + " succeeded, " + failed + " failed.");

            } else if ("sendDueSoon".equals(action)) {
                // Send due-soon reminders (books due in next 3 days)
                List<BookIssue> dueSoonList = issueDAO.getIssuesDueSoon(3);
                for (BookIssue issue : dueSoonList) {
                    if (issue.getStudentEmail() == null) continue;
                    String firstName = issue.getStudentName().split(" ")[0];
                    String dueDateStr = DATE_FMT.format(issue.getDueDate());
                    boolean ok = EmailUtil.sendDueDateReminder(
                        issue.getStudentEmail(), firstName,
                        issue.getBookTitle(), dueDateStr
                    );
                    if (ok) sent++; else failed++;
                }
                req.setAttribute("success", "Due-soon reminders sent: " + sent + " succeeded, " + failed + " failed.");

            } else if ("sendForceAll".equals(action)) {
                // FORCE SEND to ALL active borrowers regardless of due date — for testing
                List<BookIssue> allList = issueDAO.getAllActiveIssuesWithEmail();
                for (BookIssue issue : allList) {
                    if (issue.getStudentEmail() == null) continue;
                    String firstName = issue.getStudentName().split(" ")[0];
                    String dueDateStr = DATE_FMT.format(issue.getDueDate());
                    boolean ok = EmailUtil.sendDueDateReminder(
                        issue.getStudentEmail(), firstName,
                        issue.getBookTitle(), dueDateStr
                    );
                    if (ok) sent++; else failed++;
                }
                req.setAttribute("success", "⚡ Force reminder sent to ALL " + allList.size() + " active borrowers: "
                    + sent + " succeeded, " + failed + " failed.");

            } else if ("sendSingle".equals(action)) {
                // Send reminder to a single issue
                int issueId = Integer.parseInt(req.getParameter("issueId"));
                String type  = req.getParameter("type"); // "overdue" or "reminder"
                BookIssue issue = issueDAO.findById(issueId);
                if (issue != null && issue.getStudentEmail() != null) {
                    String firstName = issue.getStudentName().split(" ")[0];
                    boolean ok;
                    if ("overdue".equals(type)) {
                        long days = issue.getDaysOverdue();
                        double fine = Math.min(days * 5.0, 500.0);
                        ok = EmailUtil.sendOverdueNotice(issue.getStudentEmail(), firstName, issue.getBookTitle(), days, fine);
                    } else {
                        String dueDateStr = DATE_FMT.format(issue.getDueDate());
                        ok = EmailUtil.sendDueDateReminder(issue.getStudentEmail(), firstName, issue.getBookTitle(), dueDateStr);
                    }
                    req.setAttribute("success", ok
                        ? "✅ Email sent to " + issue.getStudentEmail()
                        : "❌ Failed to send email to " + issue.getStudentEmail() + ". Check server logs.");
                } else {
                    req.setAttribute("error", "Issue not found or student has no email.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error sending reminders: " + e.getMessage());
        }

        // Reload page data
        try {
            req.setAttribute("dueSoon",   issueDAO.getIssuesDueSoon(3));
            req.setAttribute("overdue",   issueDAO.getOverdueIssuesWithEmail());
            req.setAttribute("allActive", issueDAO.getAllActiveIssuesWithEmail());
        } catch (Exception e) { /* ignore */ }

        req.getRequestDispatcher("/WEB-INF/views/admin/reminders.jsp").forward(req, res);
    }
}
