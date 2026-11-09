package model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

import java.math.BigDecimal;

@Entity(name = "ShopProduct")
@Table(name = "Products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private int productId;
    @Column(name = "product_name")
    private String productName;
    @Column(name = "brand_id")
    private int brandId;
    @Transient
    private String brandName;
    @Column(name = "category_id")
    private int categoryId;
    @Transient
    private String categoryName;
    @Column(name = "price")
    private BigDecimal price;
    @Column(name = "quantity")
    private int quantity;
    @Column(name = "description", columnDefinition = "NTEXT")
    private String description;
    @Column(name = "image_url")
    private String imageUrl;
    @Column(name = "ram")
    private String ram;
    @Column(name = "rom")
    private String rom;
    @Column(name = "screen")
    private String screen;
    @Column(name = "battery")
    private String battery;
    @Column(name = "status")
    private boolean status;
    @Transient
    private boolean brandActive = true;
    @Transient
    private boolean categoryActive = true;
    
    public Product() {}
    
    public Product(int productId, String productName, int brandId, int categoryId, 
                   BigDecimal price, int quantity, String description, String imageUrl,
                   String ram, String rom, String screen, String battery, boolean status) {
        this.productId = productId;
        this.productName = productName;
        this.brandId = brandId;
        this.categoryId = categoryId;
        this.price = price;
        this.quantity = quantity;
        this.description = description;
        this.imageUrl = imageUrl;
        this.ram = ram;
        this.rom = rom;
        this.screen = screen;
        this.battery = battery;
        this.status = status;
    }
    
    public int getProductId() {
        return productId;
    }
    
    public void setProductId(int productId) {
        this.productId = productId;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public int getBrandId() {
        return brandId;
    }
    
    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }
    
    public String getBrandName() {
        return brandName;
    }
    
    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }
    
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public String getRam() {
        return ram;
    }
    
    public void setRam(String ram) {
        this.ram = ram;
    }
    
    public String getRom() {
        return rom;
    }
    
    public void setRom(String rom) {
        this.rom = rom;
    }
    
    public String getScreen() {
        return screen;
    }
    
    public void setScreen(String screen) {
        this.screen = screen;
    }
    
    public String getBattery() {
        return battery;
    }
    
    public void setBattery(String battery) {
        this.battery = battery;
    }
    
    public boolean isBrandActive() { return brandActive; }
    public void setBrandActive(boolean brandActive) { this.brandActive = brandActive; }
    public boolean isCategoryActive() { return categoryActive; }
    public void setCategoryActive(boolean categoryActive) { this.categoryActive = categoryActive; }
    public boolean isVisible() { return status && brandActive && categoryActive; }

    public boolean isStatus() {
        return status;
    }
    
    public void setStatus(boolean status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return "Product{" +
                "productId=" + productId +
                ", productName='" + productName + '\'' +
                ", brandId=" + brandId +
                ", brandName='" + brandName + '\'' +
                ", categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", price=" + price +
                ", quantity=" + quantity +
                ", description='" + description + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                ", ram='" + ram + '\'' +
                ", rom='" + rom + '\'' +
                ", screen='" + screen + '\'' +
                ", battery='" + battery + '\'' +
                ", status=" + status +
                '}';
    }
}