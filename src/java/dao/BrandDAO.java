package dao;

import jakarta.persistence.EntityManager;
import model.Brand;
import utils.JPAUtil;
import java.util.List;

public class BrandDAO {

    public List<Brand> getAllBrands() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT b FROM BrandEntity b ORDER BY b.brandName", Brand.class)
                    .getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting brands: " + e.getMessage());
            return List.of();
        }
    }

    public List<Brand> getActiveBrands() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(
                    "SELECT b FROM BrandEntity b WHERE b.status = true ORDER BY b.brandName", Brand.class)
                    .getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting active brands: " + e.getMessage());
            return List.of();
        }
    }

    public Brand getBrandById(int brandId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.find(Brand.class, brandId);
        } catch (RuntimeException e) {
            System.err.println("Error getting brand: " + e.getMessage());
            return null;
        }
    }

    public boolean addBrand(Brand brand) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                em.persist(brand);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error adding brand: " + e.getMessage());
            return false;
        }
    }

    public boolean updateBrand(Brand brand) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Brand current = em.find(Brand.class, brand.getBrandId());
                if (current == null) return false;
                current.setBrandName(brand.getBrandName());
                current.setStatus(brand.isStatus());
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating brand: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteBrand(int brandId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Brand brand = em.find(Brand.class, brandId);
                if (brand == null) return false;
                em.remove(brand);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error deleting brand: " + e.getMessage());
            return false;
        }
    }

    public boolean isBrandNameExists(String brandName) {
        return countByName(brandName, null) > 0;
    }

    public boolean isBrandNameExists(String brandName, int excludeBrandId) {
        return countByName(brandName, excludeBrandId) > 0;
    }

    private long countByName(String brandName, Integer excludeBrandId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            String jpql = "SELECT COUNT(b) FROM BrandEntity b WHERE LOWER(b.brandName) = LOWER(:name)";
            if (excludeBrandId != null) jpql += " AND b.brandId <> :excludeId";
            var query = em.createQuery(jpql, Long.class).setParameter("name", brandName);
            if (excludeBrandId != null) query.setParameter("excludeId", excludeBrandId);
            return query.getSingleResult();
        } catch (RuntimeException e) {
            System.err.println("Error checking brand name: " + e.getMessage());
            return 0;
        }
    }
}
