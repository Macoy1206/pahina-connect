package com.pahinaconnect.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.pahinaconnect.dao.ReservationDAO;
import com.pahinaconnect.model.User;

public class ReservationServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        try {
            if ("reserve".equals(action)) {
                int bookId = Integer.parseInt(req.getParameter("bookId"));
                boolean ok = reservationDAO.reserve(bookId, user.getId());
                if (ok) {
                    session.setAttribute("successMsg", "Book reserved successfully! You will be notified when it's available.");
                } else {
                    session.setAttribute("errorMsg", "You have already reserved this book.");
                }
            } else if ("cancel".equals(action)) {
                int reservationId = Integer.parseInt(req.getParameter("reservationId"));
                reservationDAO.cancelReservation(reservationId, user.getId());
                session.setAttribute("successMsg", "Reservation cancelled.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Operation failed: " + e.getMessage());
        }
        res.sendRedirect(req.getContextPath() + "/student/my-books");
    }
}
