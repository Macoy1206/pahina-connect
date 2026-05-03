' ============================================================
' Pahina Connect - One-Click Launcher
' Double-click = website opens automatically
' ============================================================
Set objShell = CreateObject("WScript.Shell")
Set objFSO   = CreateObject("Scripting.FileSystemObject")

MYSQLD     = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe"
MYSQL      = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
DATADIR    = "C:\MySQL8Data"
TOMCAT10   = "C:\tomcat10\apache-tomcat-10.1.28"
JAVA_HOME  = "C:\Program Files\Java\jdk-25"
JAVA_EXE   = "C:\Program Files\Java\jdk-25\bin\java.exe"
SQL_FILE   = "C:\Users\Admin\OneDrive\Documents\Pahina_connect\PahinaConnect\database\pahina_connect.sql"
JAR1       = "C:\Users\Admin\OneDrive\Documents\Pahina_connect\PahinaConnect\target\PahinaConnect-1.0.0\WEB-INF\lib\jbcrypt-0.4.jar"
JAR2       = "C:\Users\Admin\OneDrive\Documents\Pahina_connect\PahinaConnect\target\PahinaConnect-1.0.0\WEB-INF\lib\mysql-connector-j-8.0.33.jar"
TMPDIR     = "C:\Users\Admin\AppData\Local\Temp"
APP_URL    = "http://localhost:8080/PahinaConnect/"

' ── Step 1: Kill ALL java and mysqld (XAMPP or otherwise) ───
objShell.Run "taskkill /F /IM java.exe",    0, True
objShell.Run "taskkill /F /IM mysqld.exe",  0, True
objShell.Run "taskkill /F /IM mysqld_DISABLED.exe", 0, True
WScript.Sleep 4000

' ── Step 2: Start MySQL 8.0 ─────────────────────────────────
objShell.Environment("Process")("JAVA_HOME") = JAVA_HOME
objShell.Run """" & MYSQLD & """ --datadir=""" & DATADIR & """ --port=3306 --standalone", 0, False
WScript.Sleep 14000

' ── Step 3: Setup database if first time ────────────────────
Dim dbCheck
dbCheck = objShell.Run("cmd /c """ & MYSQL & """ -u root -proot -h 127.0.0.1 -e ""SELECT 1 FROM pahina_connect.users LIMIT 1;"" >nul 2>&1", 0, True)
If dbCheck <> 0 Then
    objShell.Run "cmd /c """ & MYSQL & """ -u root -proot -h 127.0.0.1 < """ & SQL_FILE & """ >nul 2>&1", 0, True
    WScript.Sleep 3000
End If

' ── Step 4: Fix admin password every time (Java avoids $ escaping) ──
Dim fixClass
fixClass = TMPDIR & "\FixAdmin.class"
If Not objFSO.FileExists(fixClass) Then
    Dim f, fso2
    Set fso2 = CreateObject("Scripting.FileSystemObject")
    Set f = fso2.CreateTextFile(TMPDIR & "\FixAdmin.java", True)
    f.WriteLine "import org.mindrot.jbcrypt.BCrypt;"
    f.WriteLine "import java.sql.*;"
    f.WriteLine "public class FixAdmin {"
    f.WriteLine "  public static void main(String[] a) throws Exception {"
    f.WriteLine "    Class.forName(""com.mysql.cj.jdbc.Driver"");"
    f.WriteLine "    String url=""jdbc:mysql://127.0.0.1:3306/pahina_connect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Manila"";"
    f.WriteLine "    Connection c=DriverManager.getConnection(url,""root"",""root"");"
    f.WriteLine "    String h=BCrypt.hashpw(""Admin@123"",BCrypt.gensalt(10));"
    f.WriteLine "    PreparedStatement p=c.prepareStatement(""UPDATE users SET password=? WHERE email='admin@pahinaconnect.com'"");"
    f.WriteLine "    p.setString(1,h); p.executeUpdate(); c.close();"
    f.WriteLine "  }"
    f.WriteLine "}"
    f.Close
    objShell.Run """C:\Program Files\Java\jdk-25\bin\javac.exe"" -cp """ & JAR1 & ";" & JAR2 & """ -d """ & TMPDIR & """ """ & TMPDIR & "\FixAdmin.java""", 0, True
End If
objShell.Run """" & JAVA_EXE & """ -cp """ & TMPDIR & ";" & JAR1 & ";" & JAR2 & """ FixAdmin", 0, True

' ── Step 5: Start Tomcat 10 (NOT XAMPP Tomcat) ──────────────
objShell.Environment("Process")("JAVA_HOME")     = JAVA_HOME
objShell.Environment("Process")("CATALINA_HOME") = TOMCAT10
objShell.Run """" & TOMCAT10 & "\bin\startup.bat""", 0, False
WScript.Sleep 15000

' ── Step 6: Open browser ────────────────────────────────────
objShell.Run APP_URL

Set objShell = Nothing
Set objFSO   = Nothing
