<%@page import="org.cysecurity.cspf.jvl.model.DBConnect"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@ include file="header.jsp" %>

<script type="text/javascript">
    $(document).ready(function(){
        $("#username").change(function(){
            var username = $(this).val();
            
            // Prevent unnecessary queries if username is empty
            if (username.trim() === "") {
                $("#status").text(""); // Clear the status if username is empty
                return;
            }

            $.getJSON("UsernameCheck.do", {username: username}, function(result) {
                // Avoid HTML injection by using .text() instead of .html()
                if (result.available == 1) {
                    $("#status").text("Username is available").css('color', 'green');
                } else {
                    $("#status").text("Username doesn't exist").css('color', 'red');
                }
            });
        });
    });
</script>

<h2>Password Recovery:</h2>
<form action="ForgotPassword.jsp" method="post">
    <table>
        <tr>
            <td>Username: </td>
            <td><input type="text" name="username" id="username" required/></td>
            <td><span id="status"></span></td>
        </tr>
        <tr>
            <td>What's Your Pet's name?: </td>
            <td><input type="text" name="secret" required/></td>
        </tr>
        <tr>
            <td><input type="submit" name="GetPassword" value="Get Password" /></td>
        </tr>
    </table>
</form><br/>

<%
    // Server-side processing for password recovery
    if (request.getParameter("secret") != null && request.getParameter("username") != null) {
        // Sanitize inputs and ensure they are valid
        String username = request.getParameter("username").trim();
        String secret = request.getParameter("secret").trim();

        // Validate inputs
        if (username.isEmpty() || secret.isEmpty()) {
            out.print("<b class='fail'> Please provide both username and secret.</b>");
            return;
        }

        // Use PreparedStatement to prevent SQL injection
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = new DBConnect().connect(getServletContext().getRealPath("/WEB-INF/config.properties"));
            
            // Query to retrieve user data based on username and secret
            String query = "SELECT * FROM users WHERE username = ? AND secret = ?";
            pstmt = con.prepareStatement(query);
            pstmt.setString(1, username);  // Set username safely
            pstmt.setString(2, secret);    // Set secret safely

            rs = pstmt.executeQuery();

            if (rs != null && rs.next()) {
                // Never display passwords in plain text!
                // Ideally, you would send a reset link to the user's email or provide another secure method
                out.print("<b class='success'>A password reset link has been sent to your email.</b>");
            } else {
                out.print("<b class='fail'> Username or secret is incorrect.</b>");
            }
        } catch (Exception e) {
            out.print("<b class='fail'> Error: " + e.getMessage() + "</b>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>

<%@ include file="footer.jsp" %>
