<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Q&amp;A Conversations" scope="request"/>
<c:set var="activePage" value="qa" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>
<style>
    .conversation-card { scroll-margin-top: 90px; }
    .conversation-body { overflow-wrap: anywhere; white-space: pre-wrap; }
    .qa-message { border-left: 3px solid #3b82f6; background: #f8fafc; }
    .qa-status { font-size: .75rem; }
</style>
<c:if test="${not empty param.message}"><div class="alert alert-success"><c:out value="${param.message}"/></div></c:if>
<c:if test="${not empty param.error}"><div class="alert alert-danger"><c:out value="${param.error}"/></div></c:if>
<div class="content-card">
    <div class="d-flex flex-wrap align-items-center justify-content-between gap-3">
        <div><h3 class="h5 mb-1">Customer Conversations</h3><p class="text-muted mb-0 small">Review questions and responses in their original discussion threads.</p></div>
        <div class="d-flex flex-wrap gap-2">
            <span class="badge text-bg-light border text-dark p-2">${totalConversations} conversations</span>
            <span class="badge text-bg-warning p-2">${pendingQuestions} questions pending</span>
            <span class="badge text-bg-warning p-2">${pendingAnswers} replies pending</span>
        </div>
    </div>
    <form method="get" action="${pageContext.request.contextPath}/admin/qa" class="d-flex flex-wrap align-items-end gap-2 mt-3">
        <div>
            <label for="admin-qa-status" class="form-label small mb-1">Status</label>
            <select class="form-select form-select-sm" name="status" id="admin-qa-status" style="min-width:185px">
                <option value="all" ${selectedStatus == 'all' ? 'selected' : ''}>All conversations</option>
                <option value="pending" ${selectedStatus == 'pending' ? 'selected' : ''}>Needs review</option>
                <option value="approved" ${selectedStatus == 'approved' ? 'selected' : ''}>Approved</option>
                <option value="rejected" ${selectedStatus == 'rejected' ? 'selected' : ''}>Rejected</option>
            </select>
        </div>
        <button class="btn btn-primary btn-sm" type="submit">Filter</button>
        <c:if test="${selectedStatus != 'all'}"><a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/admin/qa">Clear</a></c:if>
    </form>
</div>
<c:choose>
    <c:when test="${empty conversations}">
        <div class="content-card text-center py-5 text-muted">No conversations match this filter.</div>
    </c:when>
    <c:otherwise>
        <c:forEach var="q" items="${conversations}">
            <section class="content-card conversation-card" id="thread-${q.questionId}">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                    <div>
                        <div class="small text-muted mb-1">Conversation #${q.questionId}</div>
                        <a class="fw-semibold text-decoration-none" href="${pageContext.request.contextPath}/product-details?id=${q.productId}#questions"><c:out value="${q.productName}"/></a>
                    </div>
                    <span class="badge qa-status ${q.status == 'Approved' ? 'text-bg-success' : q.status == 'Pending' ? 'text-bg-warning' : 'text-bg-secondary'}"><c:out value="${q.status}"/> question</span>
                </div>
                <div class="bg-light border rounded p-3 mb-3">
                    <div class="d-flex flex-wrap align-items-center gap-2 mb-2 small">
                        <strong><c:out value="${q.authorName}"/></strong>
                        <span class="text-muted">asked</span>
                        <c:if test="${not empty q.createdAt}"><span class="text-muted"><fmt:formatDate value="${q.createdAt}" pattern="dd MMM yyyy, HH:mm"/></span></c:if>
                    </div>
                    <div class="conversation-body"><c:out value="${q.content}"/></div>
                </div>
                <div class="d-flex flex-wrap gap-2 mb-4">
                    <c:if test="${q.status != 'Approved'}">
                        <form method="post" action="${pageContext.request.contextPath}/admin/qa"><input type="hidden" name="type" value="question"><input type="hidden" name="id" value="${q.questionId}"><input type="hidden" name="status" value="${selectedStatus}"><button name="action" value="approve" class="btn btn-sm btn-success">Approve question</button></form>
                    </c:if>
                    <c:if test="${q.status != 'Rejected'}">
                        <form method="post" action="${pageContext.request.contextPath}/admin/qa"><input type="hidden" name="type" value="question"><input type="hidden" name="id" value="${q.questionId}"><input type="hidden" name="status" value="${selectedStatus}"><button name="action" value="reject" class="btn btn-sm btn-outline-warning">Reject question</button></form>
                    </c:if>
                    <form method="post" action="${pageContext.request.contextPath}/admin/qa" onsubmit="return confirm('Delete this question and all replies?')"><input type="hidden" name="type" value="question"><input type="hidden" name="id" value="${q.questionId}"><input type="hidden" name="status" value="${selectedStatus}"><button name="action" value="delete" class="btn btn-sm btn-outline-danger">Delete thread</button></form>
                </div>
                <h4 class="h6 mb-3">Replies (${fn:length(q.answers)})</h4>
                <c:if test="${empty q.answers}"><p class="small text-muted">No replies yet.</p></c:if>
                <c:forEach var="a" items="${q.answers}">
                    <div class="qa-message rounded p-3 mb-3 ms-md-4">
                        <div class="d-flex flex-wrap align-items-center gap-2 mb-2 small">
                            <strong><c:out value="${a.authorName}"/></strong>
                            <c:if test="${not empty a.createdAt}"><span class="text-muted"><fmt:formatDate value="${a.createdAt}" pattern="dd MMM yyyy, HH:mm"/></span></c:if>
                            <span class="badge qa-status ${a.status == 'Approved' ? 'text-bg-success' : a.status == 'Pending' ? 'text-bg-warning' : 'text-bg-secondary'}"><c:out value="${a.status}"/></span>
                        </div>
                        <div class="conversation-body mb-3"><c:out value="${a.content}"/></div>
                        <div class="d-flex flex-wrap gap-2">
                            <c:if test="${a.status != 'Approved'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/qa"><input type="hidden" name="type" value="answer"><input type="hidden" name="id" value="${a.answerId}"><input type="hidden" name="status" value="${selectedStatus}"><button name="action" value="approve" class="btn btn-sm btn-success">Approve</button></form>
                            </c:if>
                            <c:if test="${a.status != 'Rejected'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/qa"><input type="hidden" name="type" value="answer"><input type="hidden" name="id" value="${a.answerId}"><input type="hidden" name="status" value="${selectedStatus}"><button name="action" value="reject" class="btn btn-sm btn-outline-warning">Reject</button></form>
                            </c:if>
                            <form method="post" action="${pageContext.request.contextPath}/admin/qa" onsubmit="return confirm('Delete this reply?')"><input type="hidden" name="type" value="answer"><input type="hidden" name="id" value="${a.answerId}"><input type="hidden" name="status" value="${selectedStatus}"><button name="action" value="delete" class="btn btn-sm btn-outline-danger">Delete</button></form>
                        </div>
                    </div>
                </c:forEach>
                <form method="post" action="${pageContext.request.contextPath}/admin/qa" class="mt-4 ms-md-4">
                    <input type="hidden" name="action" value="reply">
                    <input type="hidden" name="questionId" value="${q.questionId}">
                    <input type="hidden" name="status" value="${selectedStatus}">
                    <label class="form-label fw-semibold" for="admin-reply-${q.questionId}">Reply to this conversation</label>
                    <textarea id="admin-reply-${q.questionId}" name="content" rows="2" minlength="5" maxlength="2000" class="form-control mb-2" required placeholder="Write your response..."></textarea>
                    <div class="d-flex justify-content-between flex-wrap align-items-center gap-2">
                        <small class="text-muted">Admin replies are published immediately. Questions still require approval to appear publicly.</small>
                        <button class="btn btn-primary btn-sm" type="submit">Post Reply</button>
                    </div>
                </form>
            </section>
        </c:forEach>
    </c:otherwise>
</c:choose>
<%@ include file="includes/admin-footer.jsp" %>
