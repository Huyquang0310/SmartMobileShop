<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>
<style>
    .qa-thread { scroll-margin-top: 95px; }
    .qa-text { white-space: pre-wrap; overflow-wrap: anywhere; }
</style>
<div class="container" style="max-width:970px">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div><h2 class="mb-1">My Q&amp;A</h2><p class="text-muted mb-0">Your product questions, replies and moderation status.</p></div>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary">Browse Products</a>
    </div>
    <form method="get" action="${pageContext.request.contextPath}/my-qa" class="d-flex flex-wrap align-items-end gap-2 mb-4">
        <div>
            <label for="my-qa-status" class="form-label small mb-1">Status</label>
            <select class="form-select form-select-sm" id="my-qa-status" name="status" style="min-width:185px">
                <option value="all" ${selectedStatus == 'all' ? 'selected' : ''}>All conversations</option>
                <option value="pending" ${selectedStatus == 'pending' ? 'selected' : ''}>Pending</option>
                <option value="approved" ${selectedStatus == 'approved' ? 'selected' : ''}>Approved</option>
                <option value="rejected" ${selectedStatus == 'rejected' ? 'selected' : ''}>Rejected</option>
            </select>
        </div>
        <button class="btn btn-primary btn-sm" type="submit">Filter</button>
        <c:if test="${selectedStatus != 'all'}"><a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/my-qa">Clear</a></c:if>
    </form>
    <c:if test="${not empty param.message}"><div class="alert alert-success"><c:out value="${param.message}"/></div></c:if>
    <c:if test="${not empty param.error}"><div class="alert alert-danger"><c:out value="${param.error}"/></div></c:if>
    <c:choose>
        <c:when test="${empty conversations}">
            <div class="card shadow-sm p-5 text-center"><h4>No matching conversations</h4><p class="text-muted">Choose a different status or browse products to ask a question.</p><a class="btn btn-primary mx-auto" href="${pageContext.request.contextPath}/home">Explore Products</a></div>
        </c:when>
        <c:otherwise>
            <c:forEach var="q" items="${conversations}">
                <section class="card shadow-sm p-4 mb-4 qa-thread" id="thread-${q.questionId}">
                    <div class="d-flex justify-content-between flex-wrap align-items-center gap-2 mb-3">
                        <div><small class="d-block text-muted">Conversation #${q.questionId}</small><a class="fw-semibold text-decoration-none" href="${pageContext.request.contextPath}/product-details?id=${q.productId}#questions"><c:out value="${q.productName}"/></a></div>
                        <span class="badge ${q.status == 'Approved' ? 'text-bg-success' : q.status == 'Pending' ? 'text-bg-warning' : 'text-bg-secondary'}"><c:out value="${q.status}"/> question</span>
                    </div>
                    <div class="border rounded bg-light p-3 mb-3">
                        <div class="small text-muted mb-2"><strong><c:out value="${q.authorName}"/></strong><c:if test="${not empty q.createdAt}"> &middot; <fmt:formatDate value="${q.createdAt}" pattern="dd MMM yyyy, HH:mm"/></c:if></div>
                        <div class="qa-text"><c:out value="${q.content}"/></div>
                    </div>
                    <c:forEach var="a" items="${q.answers}">
                        <div class="border-start border-primary border-3 bg-light rounded p-3 mb-2 ms-md-4">
                            <div class="d-flex flex-wrap align-items-center gap-2 mb-2 small"><strong><c:out value="${a.authorName}"/></strong><c:if test="${not empty a.createdAt}"><span class="text-muted"><fmt:formatDate value="${a.createdAt}" pattern="dd MMM yyyy, HH:mm"/></span></c:if><span class="badge ${a.status == 'Approved' ? 'text-bg-success' : a.status == 'Pending' ? 'text-bg-warning' : 'text-bg-secondary'}"><c:out value="${a.status}"/></span></div>
                            <div class="qa-text"><c:out value="${a.content}"/></div>
                        </div>
                    </c:forEach>
                    <c:if test="${q.status != 'Approved'}"><div class="small text-muted mt-2">This question is not publicly visible while its status is <c:out value="${q.status}"/>.</div></c:if>
                    <c:if test="${q.status == 'Approved'}">
                        <form method="post" action="${pageContext.request.contextPath}/qa" class="mt-3 ms-md-4">
                            <input type="hidden" name="action" value="reply"><input type="hidden" name="productId" value="${q.productId}"><input type="hidden" name="questionId" value="${q.questionId}"><input type="hidden" name="returnTo" value="history">
                            <label class="form-label" for="my-reply-${q.questionId}">Add a reply</label>
                            <textarea id="my-reply-${q.questionId}" name="content" class="form-control mb-2" rows="2" minlength="5" maxlength="2000" required></textarea>
                            <button type="submit" class="btn btn-outline-primary btn-sm">Submit Reply</button>
                        </form>
                    </c:if>
                </section>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>
<%@ include file="includes/footer.jsp" %>
