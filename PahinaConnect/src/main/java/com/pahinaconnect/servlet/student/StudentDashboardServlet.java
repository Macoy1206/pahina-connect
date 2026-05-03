package com.pahinaconnect.servlet.student;

import com.pahinaconnect.dao.*;
import com.pahinaconnect.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class StudentDashboardServlet extends HttpServlet {

    private final BookIssueDAO issueDAO = new BookIssueDAO();
    private final BookDAO bookDAO = new BookDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("loggedUser");
        try {
            issueDAO.updateOverdueStatuses();
            req.setAttribute("activeIssues",  issueDAO.getActiveIssuesByStudent(user.getId()));
            req.setAttribute("allIssues",     issueDAO.getAllIssuesByStudent(user.getId()));
            req.setAttribute("reservations",  reservationDAO.getReservationsByStudent(user.getId()));
            req.setAttribute("recentBooks",   bookDAO.getMostBorrowed(6));
            req.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp").forward(req, res);
        }
    }
}
