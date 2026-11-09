package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Cart {
    private List<CartItem> items;
    
    public Cart() {
        this.items = new ArrayList<>();
    }
    
    public List<CartItem> getItems() {
        return items;
    }
    
    public void setItems(List<CartItem> items) {
        this.items = items;
    }
    
    public boolean addItem(Product product, int quantity) {
        if (product == null || !product.isStatus() || quantity <= 0) return false;
        // Check if product already exists in cart
        for (CartItem item : items) {
            if (item.getProduct().getProductId() == product.getProductId()) {
                long newQuantity = (long) item.getQuantity() + quantity;
                // Validate against available stock
                if (newQuantity > product.getQuantity()) {
                    return false; // Exceeds available stock
                }
                item.setQuantity((int) newQuantity);
                item.setProduct(product);
                return true;
            }
        }
        // Add new item if not exists
        if (quantity > product.getQuantity()) {
            return false; // Exceeds available stock
        }
        items.add(new CartItem(product, quantity));
        return true;
    }
    
    public void updateItem(int productId, int quantity) {
        if (quantity <= 0) {
            removeItem(productId);
            return;
        }
        
        for (CartItem item : items) {
            if (item.getProduct().getProductId() == productId) {
                if (quantity <= item.getProduct().getQuantity()) item.setQuantity(quantity);
                return;
            }
        }
    }
    
    public void removeItem(int productId) {
        items.removeIf(item -> item.getProduct().getProductId() == productId);
    }
    
    public BigDecimal getTotalAmount() {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items) {
            total = total.add(item.getLineTotal());
        }
        return total;
    }
    
    public int getTotalItems() {
        int total = 0;
        for (CartItem item : items) {
            total += item.getQuantity();
        }
        return total;
    }
    
    public void clear() {
        items.clear();
    }
    
    public boolean isEmpty() {
        return items.isEmpty();
    }
    
    @Override
    public String toString() {
        return "Cart{" +
                "items=" + items +
                ", totalAmount=" + getTotalAmount() +
                ", totalItems=" + getTotalItems() +
                '}';
    }
}