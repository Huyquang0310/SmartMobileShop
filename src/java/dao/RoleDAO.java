package dao;

import jakarta.persistence.EntityManager;
import model.Role;
import utils.JPAUtil;
import java.util.List;

public class RoleDAO {

    public List<Role> getAllRoles() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT r FROM RoleEntity r ORDER BY r.roleId", Role.class)
                    .getResultList();
        } catch (RuntimeException e) {
            System.err.println("Error getting roles: " + e.getMessage());
            return List.of();
        }
    }

    public Role getRoleById(int roleId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.find(Role.class, roleId);
        } catch (RuntimeException e) {
            System.err.println("Error getting role: " + e.getMessage());
            return null;
        }
    }
}
