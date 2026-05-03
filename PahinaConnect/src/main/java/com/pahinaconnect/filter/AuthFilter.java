package com.pahinaconnect.filter;

import java.io.IOException;

import com.pahinaconnect.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login?redirect=" + uri);
            return;
        }

        // Prevent browser from caching protected pages
        // This stops the back button from showing cached pages after logout
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Expires", "0");

        // Admin-only paths
        if (uri.contains("/admin/") && !"admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        // Student-only paths
        if (uri.contains("/student/") && !"student".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
