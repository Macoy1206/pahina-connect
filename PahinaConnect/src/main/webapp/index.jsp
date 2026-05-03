<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${not empty sessionScope.loggedUser}">
    <c:choose>
      <c:when test="${sessionScope.loggedUser.role eq 'admin'}">
        <c:redirect url="/admin/dashboard"/>
      </c:when>
      <c:otherwise>
        <c:redirect url="/student/dashboard"/>
      </c:otherwise>
    </c:choose>
  </c:when>
  <c:otherwise>
    <c:redirect url="/login"/>
  </c:otherwise>
</c:choose>
