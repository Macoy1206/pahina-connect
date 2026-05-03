package com.pahinaconnect.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Properties;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtil {

    // ── UPDATE THESE IF EMAIL STOPS WORKING ──────────────────
    // Go to: myaccount.google.com → Security → 2-Step Verification → App passwords
    // Generate a new app password for "Mail" and paste it here (16 chars, no spaces)
    private static final String FROM_EMAIL    = "chrstndzdlcrz@gmail.com";
    private static final String FROM_PASSWORD = "ksnelyabjavreehv"; // Gmail App Password
    private static final String FROM_NAME     = "Pahina Connect Library";

    private static Session getSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth",                "true");
        props.put("mail.smtp.starttls.enable",     "true");
        props.put("mail.smtp.starttls.required",   "true");
        props.put("mail.smtp.host",                "smtp.gmail.com");
        props.put("mail.smtp.port",                "587");
        props.put("mail.smtp.ssl.trust",           "smtp.gmail.com");
        props.put("mail.smtp.ssl.protocols",       "TLSv1.2");
        props.put("mail.smtp.connectiontimeout",   "15000");
        props.put("mail.smtp.timeout",             "15000");
        props.put("mail.smtp.writetimeout",        "15000");
        props.put("mail.debug",                    "true");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
            }
        });
    }

    public static boolean sendEmail(String toEmail, String subject, String htmlBody) {
        try {
            Session session = getSession();
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");
            Transport.send(message);
            logEmail(toEmail, subject, htmlBody, "sent");
            System.out.println("[EMAIL] ✅ Sent to: " + toEmail + " | Subject: " + subject);
            return true;
        } catch (Exception e) {
            System.err.println("[EMAIL ERROR] ❌ Failed to send to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            logEmail(toEmail, subject, htmlBody, "failed: " + e.getMessage());
            return false;
        }
    }

    public static boolean sendOTP(String toEmail, String name, String otp) {
        String subject = "🔐 Pahina Connect - Your Password Reset OTP";
        String body = buildOTPEmail(name, otp);
        return sendEmail(toEmail, subject, body);
    }

    public static boolean sendWelcomeEmail(String toEmail, String name, String studentId) {
        String subject = "🎉 Welcome to Pahina Connect Library!";
        String body = buildWelcomeEmail(name, studentId);
        return sendEmail(toEmail, subject, body);
    }

    public static boolean sendDueDateReminder(String toEmail, String name, String bookTitle, String dueDate) {
        String subject = "⏰ Pahina Connect - Book Due Date Reminder";
        String body = buildReminderEmail(name, bookTitle, dueDate);
        return sendEmail(toEmail, subject, body);
    }

    public static boolean sendOverdueNotice(String toEmail, String name, String bookTitle, long daysOverdue, double fine) {
        String subject = "🚨 Pahina Connect - Overdue Book Notice";
        String body = buildOverdueEmail(name, bookTitle, daysOverdue, fine);
        return sendEmail(toEmail, subject, body);
    }

    // ============================================================
    // EMAIL TEMPLATES — Pahina Connect Navy/Gold Branding
    // ============================================================

    private static String header(String iconEmoji, String title, String subtitle, String gradientFrom, String gradientTo) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1'></head>"
            + "<body style='margin:0;padding:0;background:#EDE5D8;font-family:\"Segoe UI\",Arial,sans-serif'>"
            + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#EDE5D8'><tr><td align='center' style='padding:40px 20px'>"
            + "<table width='600' cellpadding='0' cellspacing='0' style='background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 8px 40px rgba(27,58,107,0.18)'>"
            // Header band
            + "<tr><td style='background:linear-gradient(135deg," + gradientFrom + "," + gradientTo + ");padding:36px 40px;text-align:center'>"
            + "<div style='font-size:52px;margin-bottom:10px'>" + iconEmoji + "</div>"
            + "<h1 style='color:#F8F4EE;margin:0;font-size:26px;font-weight:800;letter-spacing:1px'>Pahina Connect</h1>"
            + "<p style='color:rgba(248,244,238,0.75);margin:5px 0 0;font-size:13px;letter-spacing:0.5px'>Library Management System</p>"
            + "<div style='margin-top:16px;background:rgba(255,255,255,0.15);border-radius:8px;padding:10px 20px;display:inline-block'>"
            + "<span style='color:#F8F4EE;font-size:15px;font-weight:700'>" + title + "</span>"
            + "</div>"
            + "</td></tr>"
            // Subtitle bar
            + "<tr><td style='background:#1B3A6B;padding:10px 40px;text-align:center'>"
            + "<p style='margin:0;color:#C8A96E;font-size:12px;letter-spacing:1.5px;text-transform:uppercase;font-weight:600'>" + subtitle + "</p>"
            + "</td></tr>";
    }

    private static String footer() {
        return "<tr><td style='background:#0F2347;padding:24px 40px;text-align:center'>"
            + "<p style='color:#C8A96E;margin:0 0 6px;font-size:13px;font-weight:600'>📚 Pahina Connect Library</p>"
            + "<p style='color:rgba(248,244,238,0.45);margin:0;font-size:11px'>This is an automated message — please do not reply directly to this email.</p>"
            + "<p style='color:rgba(248,244,238,0.3);margin:6px 0 0;font-size:10px'>© 2025 Pahina Connect Library Management System. All rights reserved.</p>"
            + "</td></tr>"
            + "</table></td></tr></table></body></html>";
    }

    private static String buildOTPEmail(String name, String otp) {
        return header("🔐", "Password Reset Request", "One-Time Password", "#0F2347", "#1B3A6B")
            + "<tr><td style='padding:36px 40px'>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 12px'>Hello <strong style='color:#0F2347'>" + name + "</strong>,</p>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 24px'>We received a request to reset your Pahina Connect password. Use the OTP below to continue. This code is valid for <strong>10 minutes only</strong>.</p>"
            // OTP box
            + "<div style='background:linear-gradient(135deg,#F8F4EE,#EDE5D8);border:2px solid #C8A96E;border-radius:14px;padding:32px;text-align:center;margin:0 0 28px'>"
            + "<p style='margin:0 0 10px;color:#7A8FA8;font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Your One-Time Password</p>"
            + "<div style='font-size:48px;font-weight:900;color:#1B3A6B;letter-spacing:14px;font-family:\"Courier New\",monospace;line-height:1'>" + otp + "</div>"
            + "<div style='margin-top:14px;background:#1B3A6B;border-radius:6px;padding:8px 16px;display:inline-block'>"
            + "<span style='color:#C8A96E;font-size:12px;font-weight:700'>⏰ Expires in 10 minutes</span>"
            + "</div>"
            + "</div>"
            // Warning
            + "<div style='background:#FBF5E8;border-left:4px solid #C8A96E;border-radius:0 8px 8px 0;padding:14px 18px;margin:0 0 20px'>"
            + "<p style='margin:0;color:#A8893E;font-size:13px;font-weight:600'>⚠️ Security Notice</p>"
            + "<p style='margin:6px 0 0;color:#7A8FA8;font-size:13px;line-height:1.6'>If you did not request a password reset, please ignore this email. Your account remains secure and no changes have been made.</p>"
            + "</div>"
            + "<p style='color:#7A8FA8;font-size:13px;margin:0'>Need help? Contact your library administrator.</p>"
            + "</td></tr>"
            + footer();
    }

    private static String buildWelcomeEmail(String name, String studentId) {
        return header("📚", "Welcome to Pahina Connect!", "Your Library Account is Ready", "#0F2347", "#2A5298")
            + "<tr><td style='padding:36px 40px'>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 12px'>Hello <strong style='color:#0F2347'>" + name + "</strong>,</p>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 24px'>Your Pahina Connect library account has been successfully created! You can now borrow books, make reservations, and access e-books.</p>"
            // Student ID box
            + "<div style='background:linear-gradient(135deg,#0F2347,#1B3A6B);border-radius:14px;padding:28px;text-align:center;margin:0 0 28px'>"
            + "<p style='margin:0 0 8px;color:rgba(248,244,238,0.6);font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Your Student Library ID</p>"
            + "<div style='font-size:36px;font-weight:900;color:#C8A96E;letter-spacing:6px;font-family:\"Courier New\",monospace'>" + studentId + "</div>"
            + "<p style='margin:10px 0 0;color:rgba(248,244,238,0.55);font-size:12px'>Keep this ID safe — you will need it to borrow books.</p>"
            + "</div>"
            // Features
            + "<div style='background:#F8F4EE;border-radius:10px;padding:20px;margin:0 0 20px'>"
            + "<p style='margin:0 0 12px;color:#1B3A6B;font-size:14px;font-weight:700'>What you can do:</p>"
            + "<table width='100%' cellpadding='0' cellspacing='0'>"
            + "<tr><td style='padding:5px 0;color:#3D5070;font-size:13px'>📖 &nbsp;Browse and borrow books from the library</td></tr>"
            + "<tr><td style='padding:5px 0;color:#3D5070;font-size:13px'>🔖 &nbsp;Reserve books that are currently unavailable</td></tr>"
            + "<tr><td style='padding:5px 0;color:#3D5070;font-size:13px'>📱 &nbsp;Access e-books and scan QR codes</td></tr>"
            + "<tr><td style='padding:5px 0;color:#3D5070;font-size:13px'>📊 &nbsp;Track your borrowing history and fines</td></tr>"
            + "</table>"
            + "</div>"
            + "<p style='color:#3D5070;font-size:14px;margin:0'>Happy reading! 📖</p>"
            + "</td></tr>"
            + footer();
    }

    private static String buildReminderEmail(String name, String bookTitle, String dueDate) {
        return header("⏰", "Book Due Date Reminder", "Please Return Your Book Soon", "#0F2347", "#1B3A6B")
            + "<tr><td style='padding:36px 40px'>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 12px'>Hello <strong style='color:#0F2347'>" + name + "</strong>,</p>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 24px'>This is a friendly reminder from <strong>Pahina Connect Library</strong>. The book you borrowed is due soon — please return it on time to avoid late fines.</p>"
            // Due date highlight box — same style as OTP box
            + "<div style='background:linear-gradient(135deg,#F8F4EE,#EDE5D8);border:2px solid #C8A96E;border-radius:14px;padding:28px;text-align:center;margin:0 0 24px'>"
            + "<p style='margin:0 0 6px;color:#7A8FA8;font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Book to Return</p>"
            + "<p style='margin:0 0 16px;font-size:18px;font-weight:800;color:#0F2347;line-height:1.3'>" + bookTitle + "</p>"
            + "<div style='width:60px;height:2px;background:#C8A96E;margin:0 auto 16px'></div>"
            + "<p style='margin:0 0 6px;color:#7A8FA8;font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Return By</p>"
            + "<div style='font-size:28px;font-weight:900;color:#C0392B;letter-spacing:2px;line-height:1.2'>" + dueDate + "</div>"
            + "<div style='margin-top:14px;background:#1B3A6B;border-radius:6px;padding:8px 16px;display:inline-block'>"
            + "<span style='color:#C8A96E;font-size:12px;font-weight:700'>📍 Return to the library on or before this date</span>"
            + "</div>"
            + "</div>"
            // Fine warning
            + "<div style='background:#FBF5E8;border-left:4px solid #C8A96E;border-radius:0 8px 8px 0;padding:14px 18px;margin:0 0 20px'>"
            + "<p style='margin:0 0 4px;color:#A8893E;font-size:13px;font-weight:700'>💰 Late Return Fine Policy</p>"
            + "<p style='margin:0;color:#7A8FA8;font-size:13px;line-height:1.6'>A fine of <strong style='color:#C0392B'>₱5.00 per day</strong> will be charged for late returns, up to a maximum of <strong style='color:#C0392B'>₱500.00</strong>.</p>"
            + "</div>"
            + "<p style='color:#7A8FA8;font-size:13px;margin:0'>Thank you for using Pahina Connect Library! 📚</p>"
            + "</td></tr>"
            + footer();
    }

    private static String buildOverdueEmail(String name, String bookTitle, long daysOverdue, double fine) {
        return header("🚨", "Overdue Book Notice", "Immediate Action Required", "#7f0000", "#C0392B")
            + "<tr><td style='padding:36px 40px'>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 12px'>Hello <strong style='color:#0F2347'>" + name + "</strong>,</p>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 24px'>Your borrowed book is <strong style='color:#C0392B'>" + daysOverdue + " day(s) overdue</strong>. Please return it to the library immediately to stop further fines from accumulating.</p>"
            // Overdue highlight box — same style as OTP box
            + "<div style='background:linear-gradient(135deg,#FFF0F0,#FDECEA);border:2px solid #C0392B;border-radius:14px;padding:28px;text-align:center;margin:0 0 24px'>"
            + "<p style='margin:0 0 6px;color:#7A8FA8;font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Overdue Book</p>"
            + "<p style='margin:0 0 16px;font-size:18px;font-weight:800;color:#0F2347;line-height:1.3'>" + bookTitle + "</p>"
            + "<div style='width:60px;height:2px;background:#C0392B;margin:0 auto 16px'></div>"
            + "<p style='margin:0 0 4px;color:#7A8FA8;font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Days Overdue</p>"
            + "<div style='font-size:48px;font-weight:900;color:#C0392B;line-height:1;margin-bottom:4px'>" + daysOverdue + "</div>"
            + "<p style='margin:0 0 16px;color:#7A8FA8;font-size:12px'>days</p>"
            + "<div style='width:60px;height:2px;background:#C0392B;margin:0 auto 16px'></div>"
            + "<p style='margin:0 0 4px;color:#7A8FA8;font-size:11px;text-transform:uppercase;letter-spacing:3px;font-weight:600'>Current Fine</p>"
            + "<div style='font-size:36px;font-weight:900;color:#C0392B;line-height:1'>&#8369;" + String.format("%.2f", fine) + "</div>"
            + "<div style='margin-top:16px;background:#C0392B;border-radius:6px;padding:8px 16px;display:inline-block'>"
            + "<span style='color:#fff;font-size:12px;font-weight:700'>⚠️ Return immediately to stop fine accumulation</span>"
            + "</div>"
            + "</div>"
            // Action box
            + "<div style='background:#1B3A6B;border-radius:10px;padding:16px 20px;margin:0 0 20px;text-align:center'>"
            + "<p style='margin:0 0 4px;color:#C8A96E;font-size:14px;font-weight:700'>📍 Return the book to your library immediately</p>"
            + "<p style='margin:0;color:rgba(248,244,238,0.65);font-size:12px'>Fine accumulates at ₱5.00 per day (maximum ₱500.00)</p>"
            + "</div>"
            + "<p style='color:#7A8FA8;font-size:13px;margin:0'>If you have already returned this book, please contact your library administrator to update your records.</p>"
            + "</td></tr>"
            + footer();
    }

    private static void logEmail(String to, String subject, String body, String status) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO email_logs (recipient_email, subject, body, status) VALUES (?,?,?,?)")) {
            ps.setString(1, to);
            ps.setString(2, subject);
            ps.setString(3, body);
            ps.setString(4, status);
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("[EMAIL LOG ERROR] " + e.getMessage());
        }
    }
}
