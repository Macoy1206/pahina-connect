package com.pahinaconnect.servlet.student;

import com.pahinaconnect.dao.*;
import com.pahinaconnect.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class StudentBooksServlet extends HttpServlet {

    private final BookIssueDAO issueDAO = new BookIssueDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final BorrowRequestDAO borrowRequestDAO = new BorrowRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("loggedUser");
        try {
            issueDAO.updateOverdueStatuses();
            req.setAttribute("activeIssues",   issueDAO.getActiveIssuesByStudent(user.getId()));
            req.setAttribute("allIssues",      issueDAO.getAllIssuesByStudent(user.getId()));
            req.setAttribute("reservations",   reservationDAO.getReservationsByStudent(user.getId()));
            req.setAttribute("borrowRequests", borrowRequestDAO.getByStudent(user.getId()));

            // Flash messages
            HttpSession session = req.getSession();
            if (session.getAttribute("successMsg") != null) {
                req.setAttribute("success", session.getAttribute("successMsg"));
                session.removeAttribute("successMsg");
            }
            if (session.getAttribute("errorMsg") != null) {
                req.setAttribute("error", session.getAttribute("errorMsg"));
                session.removeAttribute("errorMsg");
            }
            req.getRequestDispatcher("/WEB-INF/views/student/my-books.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/student/my-books.jsp").forward(req, res);
        }
    }
}
