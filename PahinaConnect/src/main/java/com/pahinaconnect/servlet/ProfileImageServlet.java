package com.pahinaconnect.servlet;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Serves profile images from the persistent upload folder outside the webapp.
 * URL: /uploads/profiles/{filename}
 */
public class ProfileImageServlet extends HttpServlet {

    private static final String UPLOAD_DIR;

    static {
        // Use env var on Railway, fallback to local Tomcat path
        String envDir = System.getenv("UPLOAD_DIR");
        UPLOAD_DIR = (envDir != null && !envDir.isEmpty())
            ? envDir + "/profiles/"
            : "C:\\tomcat10\\apache-tomcat-10.1.28\\pahina_uploads\\profiles\\";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo(); // e.g. /profile_1.jpg
        if (pathInfo == null || pathInfo.equals("/")) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Security: prevent path traversal
        String filename = new File(pathInfo).getName();
        File file = new File(UPLOAD_DIR + filename);

        if (!file.exists() || !file.isFile()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Set content type based on extension
        String ext = filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
        switch (ext) {
            case "jpg": case "jpeg": res.setContentType("image/jpeg"); break;
            case "png":  res.setContentType("image/png");  break;
            case "gif":  res.setContentType("image/gif");  break;
            case "webp": res.setContentType("image/webp"); break;
            default:     res.setContentType("image/jpeg");
        }

        // Cache for 1 hour
        res.setHeader("Cache-Control", "max-age=3600");
        res.setContentLengthLong(file.length());

        Files.copy(file.toPath(), res.getOutputStream());
    }
}
