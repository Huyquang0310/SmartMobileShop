package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import model.Product;
import model.Order;
import model.OrderDetail;
import utils.JPAUtil;

import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public int createOrder(Order order) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                em.persist(order);
                em.flush();
                return order.getOrderId();
            });
        } catch (RuntimeException e) {
            System.err.println("Error creating order: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Adds an order to an existing checkout transaction.
     * The caller owns the transaction and EntityManager.
     */
    public int createOrder(Order order, EntityManager em) {
        em.persist(order);
        em.flush();
        return order.getOrderId();
    }

    public boolean createOrderDetail(OrderDetail orderDetail) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                em.persist(orderDetail);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error creating order detail: " + e.getMessage());
            return false;
        }
    }

    public boolean createOrderDetail(OrderDetail orderDetail, EntityManager em) {
        em.persist(orderDetail);
        return true;
    }

    public List<Order> getOrdersByUserId(int userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(
                    "SELECT o FROM PurchaseOrder o WHERE o.userId = :userId ORDER BY o.orderDate DESC",
                    Order.class)
                    .setParameter("userId", userId).getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting orders by user id: " + e.getMessage());
            return List.of();
        }
    }

    public List<Order> getAllOrders() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT o FROM PurchaseOrder o ORDER BY o.orderDate DESC", Order.class)
                    .getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting all orders: " + e.getMessage());
            return List.of();
        }
    }

    public Order getOrderById(int orderId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.find(Order.class, orderId);
        } catch (RuntimeException e) {
            System.err.println("Error getting order by id: " + e.getMessage());
            return null;
        }
    }

    public List<OrderDetail> getOrderDetailsByOrderId(int orderId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                    "SELECT d, p.productName FROM OrderDetailEntity d, ShopProduct p " +
                    "WHERE d.productId = p.productId AND d.orderId = :orderId ORDER BY d.detailId",
                    Object[].class)
                    .setParameter("orderId", orderId).getResultList();

            List<OrderDetail> details = new ArrayList<>();
            for (Object[] row : rows) {
                OrderDetail detail = (OrderDetail) row[0];
                detail.setProductName((String) row[1]);
                details.add(detail);
            }
            return details;
        } catch (RuntimeException e) {
            System.err.println("Error getting order details: " + e.getMessage());
            return List.of();
        }
    }

    public boolean updateOrderStatus(int orderId, String status) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Order order = em.find(Order.class, orderId, LockModeType.PESSIMISTIC_WRITE);
                if (order == null || !validTransition(order.getStatus(), status)) return false;
                if (!status.equals(order.getStatus())) {
                    if ("Cancelled".equals(status)) restoreStock(em, order.getOrderId());
                    order.setStatus(status);
                }
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating order status: " + e.getMessage());
            return false;
        }
    }

    public boolean cancelOrder(int orderId, int userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Order order = em.find(Order.class, orderId, LockModeType.PESSIMISTIC_WRITE);
                if (order == null || order.getUserId() != userId || !order.canCancel()) return false;
                restoreStock(em, orderId);
                order.setStatus("Cancelled");
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error cancelling order: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteCancelledOrder(int orderId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Order order = em.find(Order.class, orderId, LockModeType.PESSIMISTIC_WRITE);
                if (order == null || !"Cancelled".equals(order.getStatus())) return false;
                em.createQuery("DELETE FROM OrderDetailEntity d WHERE d.orderId = :orderId")
                    .setParameter("orderId", orderId).executeUpdate();
                em.remove(order);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Unable to delete cancelled order: " + e.getMessage());
            return false;
        }
    }

    private boolean validTransition(String current, String next) {
        if (current == null || next == null) return false;
        if (current.equals(next)) return true;
        return switch (current) {
            case "Pending" -> "Confirmed".equals(next) || "Cancelled".equals(next);
            case "Confirmed" -> "Shipping".equals(next) || "Cancelled".equals(next);
            case "Shipping" -> "Completed".equals(next);
            default -> false;
        };
    }

    private void restoreStock(EntityManager em, int orderId) {
        List<OrderDetail> details = em.createQuery(
            "SELECT d FROM OrderDetailEntity d WHERE d.orderId = :id", OrderDetail.class)
            .setParameter("id", orderId).getResultList();
        for (OrderDetail detail : details) {
            Product product = em.find(Product.class, detail.getProductId(), LockModeType.PESSIMISTIC_WRITE);
            if (product != null) product.setQuantity(Math.addExact(product.getQuantity(), detail.getQuantity()));
        }
    }
}
