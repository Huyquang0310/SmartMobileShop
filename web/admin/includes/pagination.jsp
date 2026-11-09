<c:if test="${totalPages > 1}">
    <div class="admin-pagination">
        <span class="page-info">${totalItems} total &mdash; Page ${currentPage} of ${totalPages}</span>
        <div class="page-btns">
            <c:choose>
                <c:when test="${currentPage <= 1}">
                    <span class="pg disabled">&#8592;</span>
                </c:when>
                <c:otherwise>
                    <a href="${paginationBaseUrl}&page=${currentPage - 1}" class="pg">&#8592;</a>
                </c:otherwise>
            </c:choose>

            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose>
                    <c:when test="${p == 1 or p == totalPages or (p >= currentPage - 2 and p <= currentPage + 2)}">
                        <c:choose>
                            <c:when test="${p == currentPage}">
                                <span class="pg active">${p}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${paginationBaseUrl}&page=${p}" class="pg">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:when test="${(p == 2 and currentPage > 4) or (p == totalPages - 1 and currentPage < totalPages - 3)}">
                        <span class="pg-ellipsis">&#8230;</span>
                    </c:when>
                </c:choose>
            </c:forEach>

            <c:choose>
                <c:when test="${currentPage >= totalPages}">
                    <span class="pg disabled">&#8594;</span>
                </c:when>
                <c:otherwise>
                    <a href="${paginationBaseUrl}&page=${currentPage + 1}" class="pg">&#8594;</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</c:if>
