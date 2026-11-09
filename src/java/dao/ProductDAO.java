package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import model.Brand;
import model.Category;
import model.Product;
import utils.JPAUtil;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<Product> getAllProducts() {
        return findProducts(null, null, null, null, null, null, false, 0, Integer.MAX_VALUE);
    }

    public List<Product> getActiveProducts() {
        return findProducts(null, null, null, null, null, null, true, 0, Integer.MAX_VALUE);
    }

    public Product getVisibleProductById(int productId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                "SELECT p, b.brandName, c.categoryName, b.status, c.status " +
                "FROM ShopProduct p, BrandEntity b, CategoryEntity c " +
                "WHERE p.brandId = b.brandId AND p.categoryId = c.categoryId " +
                "AND p.productId = :id AND p.status = true AND b.status = true AND c.status = true",
                Object[].class).setParameter("id", productId).getResultList();
            return rows.isEmpty() ? null : mapProductRows(rows).get(0);
        } catch (RuntimeException e) {
            System.err.println("Unable to get visible product: " + e.getMessage());
            return null;
        }
    }

    public boolean isAvailableForSale(EntityManager em, Product product) {
        if (product == null || !product.isStatus()) return false;
        Brand brand = em.find(Brand.class, product.getBrandId());
        Category category = em.find(Category.class, product.getCategoryId());
        return brand != null && brand.isStatus() && category != null && category.isStatus();
    }

    public List<Product> searchProducts(String keyword, Integer brandId,
                                        BigDecimal minPrice, BigDecimal maxPrice, String sortBy) {
        return findProducts(keyword, brandId, null, minPrice, maxPrice, sortBy, false, 0, Integer.MAX_VALUE);
    }

    public Product getProductById(int productId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Product product = em.find(Product.class, productId);
            if (product != null) {
                populateProductNames(em, List.of(product));
            }
            return product;
        } catch (RuntimeException e) {
            System.err.println("Error getting product: " + e.getMessage());
            return null;
        }
    }

    public boolean addProduct(Product product) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                em.persist(product);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error adding product: " + e.getMessage());
            return false;
        }
    }

    public boolean updateProduct(Product product) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Product current = em.find(Product.class, product.getProductId());
                if (current == null) return false;
                current.setProductName(product.getProductName());
                current.setBrandId(product.getBrandId());
                current.setCategoryId(product.getCategoryId());
                current.setPrice(product.getPrice());
                current.setDescription(product.getDescription());
                current.setImageUrl(product.getImageUrl());
                current.setRam(product.getRam());
                current.setRom(product.getRom());
                current.setScreen(product.getScreen());
                current.setBattery(product.getBattery());
                current.setStatus(product.isStatus());
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating product: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteProduct(int productId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Product product = em.find(Product.class, productId);
                if (product == null) return false;
                Long detailCount = em.createQuery(
                        "SELECT COUNT(d) FROM OrderDetailEntity d WHERE d.productId = :productId", Long.class)
                        .setParameter("productId", productId).getSingleResult();
                if (detailCount > 0) return false;
                List<Integer> questions = em.createQuery(
                        "SELECT q.questionId FROM ShopQuestion q WHERE q.productId = :productId", Integer.class)
                        .setParameter("productId", productId).getResultList();
                for (Integer questionId : questions) {
                    em.createQuery("DELETE FROM ShopAnswer a WHERE a.questionId = :questionId")
                            .setParameter("questionId", questionId).executeUpdate();
                }
                em.createQuery("DELETE FROM ShopQuestion q WHERE q.productId = :productId")
                        .setParameter("productId", productId).executeUpdate();
                em.remove(product);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error deleting product: " + e.getMessage());
            return false;
        }
    }

    public boolean adjustStock(int productId, int adjustment) {
        if (adjustment == 0) return false;
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                int lowerBound = adjustment < 0 ? -adjustment : 0;
                int upperBound = adjustment > 0 ? Integer.MAX_VALUE - adjustment : Integer.MAX_VALUE;
                int updated = em.createQuery(
                    "UPDATE ShopProduct p SET p.quantity = p.quantity + :delta " +
                    "WHERE p.productId = :id AND p.quantity >= :min AND p.quantity <= :max")
                    .setParameter("delta", adjustment)
                    .setParameter("id", productId)
                    .setParameter("min", lowerBound)
                    .setParameter("max", upperBound)
                    .executeUpdate();
                return updated == 1;
            });
        } catch (RuntimeException e) {
            System.err.println("Error adjusting stock: " + e.getMessage());
            return false;
        }
    }

    public int countProducts(String keyword, Integer brandId,
                             BigDecimal minPrice, BigDecimal maxPrice) {
        return countProducts(keyword, brandId, null, minPrice, maxPrice);
    }

    public int countProducts(String keyword, Integer brandId, Integer categoryId,
                             BigDecimal minPrice, BigDecimal maxPrice) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            StringBuilder jpql = new StringBuilder("SELECT COUNT(p) FROM ShopProduct p, BrandEntity b, CategoryEntity c " +
                    "WHERE p.brandId = b.brandId AND p.categoryId = c.categoryId AND p.status = true AND b.status = true AND c.status = true");
            appendFilters(jpql, keyword, brandId, categoryId, minPrice, maxPrice, null);
            TypedQuery<Long> query = em.createQuery(jpql.toString(), Long.class);
            bindFilters(query, keyword, brandId, categoryId, minPrice, maxPrice);
            return query.getSingleResult().intValue();
        } catch (RuntimeException e) {
            System.err.println("Error counting products: " + e.getMessage());
            return 0;
        }
    }

    public List<Product> searchProductsWithPaging(String keyword, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, String sortBy, int offset, int pageSize) {
        return searchProductsWithPaging(keyword, brandId, null, minPrice, maxPrice, sortBy, offset, pageSize);
    }

    public List<Product> searchProductsWithPaging(String keyword, Integer brandId, Integer categoryId,
            BigDecimal minPrice, BigDecimal maxPrice, String sortBy, int offset, int pageSize) {
        return findProducts(keyword, brandId, categoryId, minPrice, maxPrice, sortBy, true,
                Math.max(0, offset), Math.max(1, pageSize));
    }

    public List<Product> getNewArrivals(int limit) {
        return findProducts(null, null, null, null, null, null, true, 0, limit);
    }

    public List<Product> getFeaturedProducts(int limit) {
        return findProducts(null, null, null, null, null, "price_desc", true, 0, limit);
    }

    public List<Product> getBestSellers(int limit) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                "SELECT d.productId, SUM(d.quantity) FROM OrderDetailEntity d, PurchaseOrder o " +
                "WHERE d.orderId = o.orderId AND o.status = 'Completed' " +
                "GROUP BY d.productId ORDER BY SUM(d.quantity) DESC", Object[].class)
                .setMaxResults(Math.max(1, limit * 3)).getResultList();
            List<Product> result = new ArrayList<>();
            for (Object[] row : rows) {
                Product product = em.find(Product.class, ((Number) row[0]).intValue());
                if (isAvailableForSale(em, product)) {
                    populateProductNames(em, List.of(product));
                    result.add(product);
                    if (result.size() >= limit) break;
                }
            }
            return result;
        } catch (RuntimeException e) {
            System.err.println("Error getting best sellers: " + e.getMessage());
            return List.of();
        }
    }

    public List<Product> getRelatedProducts(int productId, int brandId, int categoryId, int limit) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                    "SELECT p, b.brandName, c.categoryName, b.status, c.status " +
                    "FROM ShopProduct p, BrandEntity b, CategoryEntity c " +
                    "WHERE p.brandId = b.brandId AND p.categoryId = c.categoryId " +
                    "AND p.productId <> :productId AND p.status = true AND b.status = true AND c.status = true " +
                    "AND (p.categoryId = :categoryId OR p.brandId = :brandId) " +
                    "ORDER BY CASE WHEN p.categoryId = :categoryId THEN 0 ELSE 1 END, p.productId DESC",
                    Object[].class)
                    .setParameter("productId", productId)
                    .setParameter("categoryId", categoryId)
                    .setParameter("brandId", brandId)
                    .setMaxResults(Math.max(1, limit))
                    .getResultList();
            return mapProductRows(rows);
        } catch (RuntimeException e) {
            System.err.println("Error getting related products: " + e.getMessage());
            return List.of();
        }
    }

    public List<Product> searchAdminProducts(String keyword, Integer brandId, Integer categoryId,
            String visibility, String stockFilter, String sortBy) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            StringBuilder jpql = new StringBuilder(
                "SELECT p, b.brandName, c.categoryName, b.status, c.status " +
                "FROM ShopProduct p, BrandEntity b, CategoryEntity c " +
                "WHERE p.brandId = b.brandId AND p.categoryId = c.categoryId");
            appendFilters(jpql, keyword, brandId, categoryId, null, null, null);
            if ("visible".equals(visibility)) {
                jpql.append(" AND p.status = true AND b.status = true AND c.status = true");
            } else if ("hidden".equals(visibility)) {
                jpql.append(" AND (p.status = false OR b.status = false OR c.status = false)");
            } else if ("inactive".equals(visibility)) {
                jpql.append(" AND p.status = false");
            } else if ("brand_hidden".equals(visibility)) {
                jpql.append(" AND b.status = false");
            } else if ("category_hidden".equals(visibility)) {
                jpql.append(" AND c.status = false");
            }
            if ("out".equals(stockFilter)) jpql.append(" AND p.quantity = 0");
            if ("low".equals(stockFilter)) jpql.append(" AND p.quantity BETWEEN 1 AND 5");
            if ("available".equals(stockFilter)) jpql.append(" AND p.quantity > 5");
            if ("stock_asc".equals(sortBy)) jpql.append(" ORDER BY p.quantity ASC, p.productId DESC");
            else if ("stock_desc".equals(sortBy)) jpql.append(" ORDER BY p.quantity DESC, p.productId DESC");
            else jpql.append(sortClause(sortBy));
            TypedQuery<Object[]> query = em.createQuery(jpql.toString(), Object[].class);
            bindFilters(query, keyword, brandId, categoryId, null, null);
            return mapProductRows(query.getResultList());
        } catch (RuntimeException e) {
            System.err.println("Error filtering admin products: " + e.getMessage());
            return List.of();
        }
    }

    private List<Product> findProducts(String keyword, Integer brandId, Integer categoryId,
            BigDecimal minPrice, BigDecimal maxPrice, String sortBy,
            boolean activeOnly, int offset, int pageSize) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            StringBuilder jpql = new StringBuilder(
                    "SELECT p, b.brandName, c.categoryName, b.status, c.status " +
                    "FROM ShopProduct p, BrandEntity b, CategoryEntity c " +
                    "WHERE p.brandId = b.brandId AND p.categoryId = c.categoryId");
            if (activeOnly) jpql.append(" AND p.status = true AND b.status = true AND c.status = true");
            appendFilters(jpql, keyword, brandId, categoryId, minPrice, maxPrice, null);
            jpql.append(sortClause(sortBy));

            TypedQuery<Object[]> query = em.createQuery(jpql.toString(), Object[].class);
            bindFilters(query, keyword, brandId, categoryId, minPrice, maxPrice);
            if (offset > 0) query.setFirstResult(offset);
            if (pageSize != Integer.MAX_VALUE) query.setMaxResults(pageSize);
            return mapProductRows(query.getResultList());
        } catch (RuntimeException e) {
            System.err.println("Error searching products: " + e.getMessage());
            return List.of();
        }
    }

    private void appendFilters(StringBuilder jpql, String keyword, Integer brandId, Integer categoryId,
            BigDecimal minPrice, BigDecimal maxPrice, String alias) {
        String prefix = alias == null ? "p." : alias + ".";
        if (keyword != null && !keyword.trim().isEmpty()) {
            jpql.append(" AND (LOWER(").append(prefix).append("productName) LIKE :keyword " +
                "OR LOWER(b.brandName) LIKE :keyword OR LOWER(c.categoryName) LIKE :keyword)");
        }
        if (brandId != null) jpql.append(" AND ").append(prefix).append("brandId = :brandId");
        if (categoryId != null) jpql.append(" AND ").append(prefix).append("categoryId = :categoryId");
        if (minPrice != null) jpql.append(" AND ").append(prefix).append("price >= :minPrice");
        if (maxPrice != null) jpql.append(" AND ").append(prefix).append("price <= :maxPrice");
    }

    private void bindFilters(TypedQuery<?> query, String keyword, Integer brandId, Integer categoryId,
            BigDecimal minPrice, BigDecimal maxPrice) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            query.setParameter("keyword", "%" + keyword.trim().toLowerCase() + "%");
        }
        if (brandId != null) query.setParameter("brandId", brandId);
        if (categoryId != null) query.setParameter("categoryId", categoryId);
        if (minPrice != null) query.setParameter("minPrice", minPrice);
        if (maxPrice != null) query.setParameter("maxPrice", maxPrice);
    }

    private String sortClause(String sortBy) {
        if ("price_asc".equalsIgnoreCase(sortBy)) return " ORDER BY p.price ASC";
        if ("price_desc".equalsIgnoreCase(sortBy)) return " ORDER BY p.price DESC";
        if ("name_asc".equalsIgnoreCase(sortBy)) return " ORDER BY p.productName ASC";
        if ("name_desc".equalsIgnoreCase(sortBy)) return " ORDER BY p.productName DESC";
        return " ORDER BY p.productId DESC";
    }

    private List<Product> mapProductRows(List<Object[]> rows) {
        List<Product> products = new ArrayList<>();
        for (Object[] row : rows) {
            Product product = (Product) row[0];
            product.setBrandName((String) row[1]);
            product.setCategoryName((String) row[2]);
            if (row.length > 4) {
                product.setBrandActive(Boolean.TRUE.equals(row[3]));
                product.setCategoryActive(Boolean.TRUE.equals(row[4]));
            }
            products.add(product);
        }
        return products;
    }

    private void populateProductNames(EntityManager em, List<Product> products) {
        for (Product product : products) {
            Brand brand = em.find(Brand.class, product.getBrandId());
            Category category = em.find(Category.class, product.getCategoryId());
            product.setBrandName(brand == null ? null : brand.getBrandName());
            product.setCategoryName(category == null ? null : category.getCategoryName());
            product.setBrandActive(brand != null && brand.isStatus());
            product.setCategoryActive(category != null && category.isStatus());
        }
    }
}
