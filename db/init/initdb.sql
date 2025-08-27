IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'MyDatabase')
BEGIN
  CREATE DATABASE ecss;
END
GO

use ecss
go

CREATE TABLE dbo.users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    role NVARCHAR(50) NOT NULL, 
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    last_login DATETIME2 NULL,
    status NVARCHAR(20) NULL 
);
GO


CREATE TABLE dbo.companies (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255),
    tax_code NVARCHAR(100),
    address NVARCHAR(MAX),
    phone NVARCHAR(50),
    email NVARCHAR(255),
    website NVARCHAR(255),
    logo_url NVARCHAR(500),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL
);
GO


CREATE TABLE dbo.categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    parent_id INT NULL,
    name NVARCHAR(200) NOT NULL,
    slug NVARCHAR(200) NULL UNIQUE,
    description NVARCHAR(MAX),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_id) REFERENCES dbo.categories(id)
);
GO


CREATE TABLE dbo.components (
    id INT IDENTITY(1,1) PRIMARY KEY,
    type NVARCHAR(100),          
    sku NVARCHAR(100) UNIQUE,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    unit_price DECIMAL(18,2) NULL,
    stock INT NOT NULL DEFAULT(0),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL
);
GO


CREATE TABLE dbo.products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sku NVARCHAR(100) UNIQUE,
    name NVARCHAR(255) NOT NULL,
    category_id INT NULL,
    short_description NVARCHAR(500),
    description NVARCHAR(MAX),
    base_price DECIMAL(18,2) NOT NULL DEFAULT(0),
    stock INT NOT NULL DEFAULT(0),
    status NVARCHAR(50) NOT NULL DEFAULT('active'),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_products_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id)
);
GO


CREATE TABLE dbo.product_designs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    name NVARCHAR(255) NOT NULL,  
    option_type NVARCHAR(50) NULL,    
    required BIT NOT NULL DEFAULT(0),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_product_designs_product FOREIGN KEY (product_id) REFERENCES dbo.products(id)
);
GO


CREATE TABLE dbo.product_design_options (
    id INT IDENTITY(1,1) PRIMARY KEY,
    design_id INT NOT NULL,
    label NVARCHAR(255),
    sku NVARCHAR(100),
    additional_price DECIMAL(18,2) NOT NULL DEFAULT(0),
    linked_component_id INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_pdo_design FOREIGN KEY (design_id) REFERENCES dbo.product_designs(id),
    CONSTRAINT FK_pdo_component FOREIGN KEY (linked_component_id) REFERENCES dbo.components(id)
);
GO


CREATE TABLE dbo.product_components (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    component_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT(1),
    note NVARCHAR(500) NULL,
    CONSTRAINT FK_pc_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
    CONSTRAINT FK_pc_component FOREIGN KEY (component_id) REFERENCES dbo.components(id)
);
GO


CREATE TABLE dbo.user_profiles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    full_name NVARCHAR(255) NULL,
    phone NVARCHAR(50) NULL,
    address NVARCHAR(MAX) NULL,
    city NVARCHAR(100) NULL,
    country NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_user_profiles_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.credit_cards (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    card_holder NVARCHAR(255),
    card_type NVARCHAR(50),
    last4 NVARCHAR(4),
    expiry_month TINYINT,
    expiry_year SMALLINT,
    token NVARCHAR(500),  
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_credit_cards_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO


CREATE TABLE dbo.adverts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    company_id INT NULL,
    title NVARCHAR(255),
    image_url NVARCHAR(500),
    link NVARCHAR(500),
    position NVARCHAR(100), 
    active BIT NOT NULL DEFAULT(1),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_adverts_company FOREIGN KEY (company_id) REFERENCES dbo.companies(id)
);
GO


CREATE TABLE dbo.carts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL,             
    session_id NVARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    status NVARCHAR(50) NOT NULL DEFAULT('active'),
    CONSTRAINT FK_carts_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO


CREATE TABLE dbo.cart_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT(1),
    unit_price DECIMAL(18,2) NULL,
    customized BIT NOT NULL DEFAULT(0),
    customization NVARCHAR(MAX) NULL,  
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_cart_items_cart FOREIGN KEY (cart_id) REFERENCES dbo.carts(id),
    CONSTRAINT FK_cart_items_product FOREIGN KEY (product_id) REFERENCES dbo.products(id)
);

GO


CREATE TABLE dbo.orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_no NVARCHAR(100) NOT NULL UNIQUE,
    user_id INT NULL,
    status NVARCHAR(50) NOT NULL DEFAULT('draft'),  
    total_amount DECIMAL(18,2) NULL,
    shipping_address NVARCHAR(MAX) NULL,
    billing_address NVARCHAR(MAX) NULL,
    payment_method NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NULL,
    placed_at DATETIME2 NULL,
    cancelled_at DATETIME2 NULL,
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO


CREATE TABLE dbo.order_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT(1),
    unit_price DECIMAL(18,2) NULL,
    customization NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id) REFERENCES dbo.products(id)
);

GO

CREATE TABLE dbo.payments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NULL,
    amount DECIMAL(18,2) NOT NULL,
    method NVARCHAR(100) NULL,    
    status NVARCHAR(50) NOT NULL DEFAULT('pending'),
    transaction_id NVARCHAR(255) NULL,
    paid_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_payments_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_payments_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO


CREATE TABLE dbo.transactions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL,
    order_id INT NULL,
    type NVARCHAR(100) NULL, 
    amount DECIMAL(18,2) NULL,
    note NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_transactions_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_transactions_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id)
);
GO


CREATE TABLE dbo.admin_actions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    admin_id INT NULL,             
    action NVARCHAR(255) NULL,
    target_table NVARCHAR(255) NULL,
    target_id INT NULL,
    detail NVARCHAR(MAX) NULL,  
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_admin_actions_admin FOREIGN KEY (admin_id) REFERENCES dbo.users(id)
);
GO


CREATE TABLE dbo.product_views (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NULL,
    session_id NVARCHAR(255) NULL,
    viewed_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_product_views_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
    CONSTRAINT FK_product_views_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO


CREATE TABLE dbo.search_logs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL,
    session_id NVARCHAR(255) NULL,
    query_text NVARCHAR(1000) NULL,
    filters NVARCHAR(MAX) NULL, 
    result_count INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_search_logs_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);