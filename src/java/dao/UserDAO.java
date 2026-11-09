package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import model.User;
import utils.JPAUtil;
import utils.PasswordUtil;

import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User login(String usernameOrEmail, String password) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                    "SELECT u, r.roleName FROM UserEntity u, RoleEntity r " +
                    "WHERE u.roleId = r.roleId AND (u.username = :identity OR u.email = :identity) " +
                    "AND u.status = true", Object[].class)
                    .setParameter("identity", usernameOrEmail)
                    .setMaxResults(1)
                    .getResultList();

            if (rows.isEmpty()) return null;
            User user = (User) rows.get(0)[0];
            user.setRoleName((String) rows.get(0)[1]);

            if (!PasswordUtil.matches(password, user.getPassword())) return null;
            if (user.getPassword() != null && !user.getPassword().startsWith("pbkdf2:")) {
                JPAUtil.inTransaction(em, () -> {
                    user.setPassword(PasswordUtil.hash(password));
                    return true;
                });
            }
            user.setPassword(null);
            return user;
        } catch (RuntimeException e) {
            System.err.println("Error in login: " + e.getMessage());
            return null;
        }
    }

    public boolean register(User user) {
        user.setRoleId(2); // Customer role in the existing database seed data.
        user.setStatus(true);
        return persistUser(user, "register");
    }

    public boolean isUsernameExists(String username) {
        return exists("SELECT COUNT(u) FROM UserEntity u WHERE u.username = :value", "value", username);
    }

    public boolean isEmailExists(String email) {
        return exists("SELECT COUNT(u) FROM UserEntity u WHERE u.email = :value", "value", email);
    }

    public List<User> getAllUsers() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                    "SELECT u, r.roleName FROM UserEntity u, RoleEntity r " +
                    "WHERE u.roleId = r.roleId ORDER BY u.userId", Object[].class).getResultList();
            return mapUserRows(rows);
        } catch (RuntimeException e) {
            System.err.println("Error getting all users: " + e.getMessage());
            return List.of();
        }
    }

    public List<User> searchUsers(String keyword) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            String value = keyword == null ? "" : keyword.trim().toLowerCase();
            List<Object[]> rows = em.createQuery(
                    "SELECT u, r.roleName FROM UserEntity u, RoleEntity r " +
                    "WHERE u.roleId = r.roleId AND " +
                    "(LOWER(u.fullName) LIKE :keyword OR LOWER(u.username) LIKE :keyword " +
                    "OR LOWER(u.email) LIKE :keyword) ORDER BY u.userId", Object[].class)
                    .setParameter("keyword", "%" + value + "%")
                    .getResultList();
            return mapUserRows(rows);
        } catch (RuntimeException e) {
            System.err.println("Error searching users: " + e.getMessage());
            return List.of();
        }
    }

    public boolean updateUserStatus(int userId, boolean status) {
        return updateUserField(userId, user -> user.setStatus(status));
    }

    public boolean updateUserRole(int userId, int roleId) {
        return updateUserField(userId, user -> user.setRoleId(roleId));
    }

    public User getUserById(int userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            User user = em.find(User.class, userId);
            if (user != null) {
                List<String> roleNames = em.createQuery(
                        "SELECT r.roleName FROM RoleEntity r WHERE r.roleId = :roleId", String.class)
                        .setParameter("roleId", user.getRoleId())
                        .getResultList();
                user.setRoleName(roleNames.isEmpty() ? null : roleNames.get(0));
            }
            return user;
        } catch (RuntimeException e) {
            System.err.println("Error getting user by id: " + e.getMessage());
            return null;
        }
    }

    public boolean addUser(User user) {
        return persistUser(user, "add user");
    }

    public boolean updateUser(User user) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                User current = em.find(User.class, user.getUserId());
                if (current == null) return false;
                current.setFullName(user.getFullName());
                current.setUsername(user.getUsername());
                current.setEmail(user.getEmail());
                current.setPhone(user.getPhone());
                current.setAddress(user.getAddress());
                current.setRoleId(user.getRoleId());
                current.setStatus(user.isStatus());
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating user: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteUser(int userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                User user = em.find(User.class, userId);
                if (user == null) return false;
                Long orderCount = em.createQuery(
                        "SELECT COUNT(o) FROM PurchaseOrder o WHERE o.userId = :userId", Long.class)
                        .setParameter("userId", userId).getSingleResult();
                if (orderCount > 0) return false;
                List<Integer> questions = em.createQuery(
                        "SELECT q.questionId FROM ShopQuestion q WHERE q.userId = :userId", Integer.class)
                        .setParameter("userId", userId).getResultList();
                em.createQuery("DELETE FROM ShopAnswer a WHERE a.userId = :userId")
                        .setParameter("userId", userId).executeUpdate();
                for (Integer questionId : questions) {
                    em.createQuery("DELETE FROM ShopAnswer a WHERE a.questionId = :questionId")
                            .setParameter("questionId", questionId).executeUpdate();
                }
                em.createQuery("DELETE FROM ShopQuestion q WHERE q.userId = :userId")
                        .setParameter("userId", userId).executeUpdate();
                em.remove(user);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error deleting user: " + e.getMessage());
            return false;
        }
    }

    public boolean hasOrders(int userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Long count = em.createQuery(
                    "SELECT COUNT(o) FROM PurchaseOrder o WHERE o.userId = :userId", Long.class)
                    .setParameter("userId", userId).getSingleResult();
            return count > 0;
        } catch (RuntimeException e) {
            System.err.println("Error checking user orders: " + e.getMessage());
            return false;
        }
    }

    public boolean isUsernameExists(String username, int excludeUserId) {
        return exists("SELECT COUNT(u) FROM UserEntity u WHERE u.username = :value AND u.userId <> :excludeId",
                "value", username, excludeUserId);
    }

    public boolean isEmailExists(String email, int excludeUserId) {
        return exists("SELECT COUNT(u) FROM UserEntity u WHERE u.email = :value AND u.userId <> :excludeId",
                "value", email, excludeUserId);
    }

    public boolean updateProfile(int userId, String fullName, String email, String phone, String address) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                User user = em.find(User.class, userId);
                if (user == null) return false;
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setAddress(address);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating profile: " + e.getMessage());
            return false;
        }
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                User user = em.find(User.class, userId);
                if (user == null || !PasswordUtil.matches(oldPassword, user.getPassword())) return false;
                user.setPassword(PasswordUtil.hash(newPassword));
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error changing password: " + e.getMessage());
            return false;
        }
    }


    public Integer findActiveAccountForLocalReset(String username, String email) {
        if (username == null || email == null || username.isBlank() || email.isBlank()) return null;
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Integer> ids = em.createQuery(
                    "SELECT u.userId FROM UserEntity u WHERE LOWER(u.username) = :username " +
                    "AND LOWER(u.email) = :email AND u.status = true", Integer.class)
                    .setParameter("username", username.trim().toLowerCase(java.util.Locale.ROOT))
                    .setParameter("email", email.trim().toLowerCase(java.util.Locale.ROOT))
                    .setMaxResults(1).getResultList();
            return ids.isEmpty() ? null : ids.get(0);
        } catch (RuntimeException exception) {
            System.err.println("Error verifying account: " + exception.getMessage());
            return null;
        }
    }

    public boolean resetPasswordForLocalDemo(int userId, String newPassword) {
        if (userId <= 0 || newPassword == null || newPassword.length() < 8 || newPassword.length() > 100)
            return false;
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                User account = em.find(User.class, userId);
                if (account == null || !account.isStatus()) return false;
                account.setPassword(PasswordUtil.hash(newPassword));
                return true;
            });
        } catch (RuntimeException exception) {
            System.err.println("Error resetting password: " + exception.getMessage());
            return false;
        }
    }

    private boolean persistUser(User user, String operation) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                user.setPassword(PasswordUtil.hash(user.getPassword()));
                em.persist(user);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error trying to " + operation + ": " + e.getMessage());
            return false;
        }
    }

    private boolean updateUserField(int userId, java.util.function.Consumer<User> updater) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                User user = em.find(User.class, userId);
                if (user == null) return false;
                updater.accept(user);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Error updating user field: " + e.getMessage());
            return false;
        }
    }

    private boolean exists(String jpql, String parameter, Object value) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(jpql, Long.class).setParameter(parameter, value).getSingleResult() > 0;
        } catch (RuntimeException e) {
            System.err.println("Error checking user data: " + e.getMessage());
            return false;
        }
    }

    private boolean exists(String jpql, String parameter, Object value, int excludeUserId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(jpql, Long.class).setParameter(parameter, value)
                    .setParameter("excludeId", excludeUserId).getSingleResult() > 0;
        } catch (RuntimeException e) {
            System.err.println("Error checking user data: " + e.getMessage());
            return false;
        }
    }

    private List<User> mapUserRows(List<Object[]> rows) {
        List<User> users = new ArrayList<>();
        for (Object[] row : rows) {
            User user = (User) row[0];
            user.setRoleName((String) row[1]);
            users.add(user);
        }
        return users;
    }
}
