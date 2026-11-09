package dao;

import jakarta.persistence.EntityManager;
import model.Category;
import utils.JPAUtil;
import java.util.List;

public class CategoryDAO {

    public List<Category> getAllCategories() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT c FROM CategoryEntity c ORDER BY c.categoryName", Category.class)
                    .getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting categories: " + e.getMessage());
            return List.of();
        }
    }

    public List<Category> getActiveCategories() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(
                    "SELECT c FROM CategoryEntity c WHERE c.status = true ORDER BY c.categoryName", Category.class)
                    .getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting active categories: " + e.getMessage());
            return List.of();
        }
    }

    public Category getCategoryById(int categoryId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.find(Category.class, categoryId);
        } catch (RuntimeException e) {
            System.err.println("Error getting category: " + e.getMessage());
            return null;
        }
    }

    public boolean addCategory(Category category) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                em.persist(category);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error adding category: " + e.getMessage());
            return false;
        }
    }

    public boolean updateCategory(Category category) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Category current = em.find(Category.class, category.getCategoryId());
                if (current == null) return false;
                current.setCategoryName(category.getCategoryName());
                current.setStatus(category.isStatus());
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating category: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteCategory(int categoryId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Category category = em.find(Category.class, categoryId);
                if (category == null) return false;
                em.remove(category);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error deleting category: " + e.getMessage());
            return false;
        }
    }

    public boolean isCategoryNameExists(String categoryName) {
        return countByName(categoryName, null) > 0;
    }

    public boolean isCategoryNameExists(String categoryName, int excludeCategoryId) {
        return countByName(categoryName, excludeCategoryId) > 0;
    }

    private long countByName(String categoryName, Integer excludeCategoryId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            String jpql = "SELECT COUNT(c) FROM CategoryEntity c WHERE LOWER(c.categoryName) = LOWER(:name)";
            if (excludeCategoryId != null) jpql += " AND c.categoryId <> :excludeId";
            var query = em.createQuery(jpql, Long.class).setParameter("name", categoryName);
            if (excludeCategoryId != null) query.setParameter("excludeId", excludeCategoryId);
            return query.getSingleResult();
        } catch (RuntimeException e) {
            System.err.println("Error checking category name: " + e.getMessage());
            return 0;
        }
    }
}
