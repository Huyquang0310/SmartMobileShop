package dao;

import jakarta.persistence.EntityManager;
import utils.JPAUtil;
import java.math.BigDecimal;

public class ReportDAO {
    public static final class Summary {
        private final long productCount;
        private final long orderCount;
        private final long completedOrderCount;
        private final BigDecimal minPrice;
        private final BigDecimal maxPrice;
        private final double averagePrice;
        private final BigDecimal totalRevenue;
        private final long soldUnits;

        public Summary(long productCount, long orderCount, long completedOrderCount,
                       BigDecimal minPrice, BigDecimal maxPrice, double averagePrice,
                       BigDecimal totalRevenue, long soldUnits) {
            this.productCount = productCount;
            this.orderCount = orderCount;
            this.completedOrderCount = completedOrderCount;
            this.minPrice = minPrice;
            this.maxPrice = maxPrice;
            this.averagePrice = averagePrice;
            this.totalRevenue = totalRevenue;
            this.soldUnits = soldUnits;
        }
        public long getProductCount() { return productCount; }
        public long getOrderCount() { return orderCount; }
        public long getCompletedOrderCount() { return completedOrderCount; }
        public BigDecimal getMinPrice() { return minPrice; }
        public BigDecimal getMaxPrice() { return maxPrice; }
        public double getAveragePrice() { return averagePrice; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public long getSoldUnits() { return soldUnits; }
    }

    public Summary calculate() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Object[] products = (Object[]) em.createQuery(
                "SELECT COUNT(p), MIN(p.price), MAX(p.price), AVG(p.price) " +
                "FROM ShopProduct p, BrandEntity b, CategoryEntity c " +
                "WHERE p.brandId = b.brandId AND p.categoryId = c.categoryId " +
                "AND p.status = true AND b.status = true AND c.status = true").getSingleResult();
            Long orderCount = em.createQuery("SELECT COUNT(o) FROM PurchaseOrder o", Long.class).getSingleResult();
            BigDecimal revenue = em.createQuery(
                "SELECT SUM(o.totalAmount) FROM PurchaseOrder o WHERE o.status = 'Completed'",
                BigDecimal.class).getSingleResult();
            Long completed = em.createQuery("SELECT COUNT(o) FROM PurchaseOrder o WHERE o.status = 'Completed'", Long.class)
                    .getSingleResult();
            Long sold = em.createQuery(
                "SELECT SUM(d.quantity) FROM OrderDetailEntity d, PurchaseOrder o " +
                "WHERE d.orderId = o.orderId AND o.status = 'Completed'", Long.class).getSingleResult();
            return new Summary(((Number) products[0]).longValue(), orderCount,
                completed == null ? 0 : completed, products[1] == null ? BigDecimal.ZERO : (BigDecimal) products[1],
                products[2] == null ? BigDecimal.ZERO : (BigDecimal) products[2],
                products[3] == null ? 0 : ((Number) products[3]).doubleValue(),
                revenue == null ? BigDecimal.ZERO : revenue,
                sold == null ? 0 : sold);
        }
    }
}
