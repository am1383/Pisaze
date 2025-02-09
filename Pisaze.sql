--Pisaze Database Final Project--

--Create Database & Connect To Database--

CREATE DATABASE pisaze;

\c pisaze

--Extension for job scheduled

CREATE EXTENSION IF NOT EXISTS pg_cron;

--Enums Section--

CREATE TYPE transaction_status_enum AS ENUM ('successful', 'mid-successful', 'unsuccessful');
CREATE TYPE transaction_type_enum AS ENUM ('bank', 'wallet');
CREATE TYPE discount_enum AS ENUM ('public', 'private');
CREATE TYPE cart_enum AS ENUM ('locked', 'blocked', 'active');
CREATE TYPE cooling_enum AS ENUM ('liquid', 'air');

--Create Tables--

CREATE TABLE product (
    id              SERIAL PRIMARY KEY, 
    brand           VARCHAR(50) NOT NULL,
    model           VARCHAR(50) NOT NULL,
    current_price   INT,
    stock_count     SMALLINT,
    category        VARCHAR(50),
    product_image   BYTEA
);

CREATE TABLE hdd (
    product_id          INT PRIMARY KEY, 
    capacity            DECIMAL(5, 2),          
    rotational_speed    INT,  
    wattage             INT,           
    depth               DECIMAL(5, 2), 
    height              DECIMAL(5, 2),    
    width               DECIMAL(5, 2),
    FOREIGN KEY (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE gpu (
    product_id  INT PRIMARY KEY, 
    ram_size    INT,         
    clock_speed DECIMAL(5, 2), 
    num_fans    SMALLINT,
    wattage     INT,
    depth       DECIMAL(5, 2), 
    height      DECIMAL(5, 2),    
    width       DECIMAL(5, 2),
    FOREIGN KEY (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ram_stick (
    product_id  INT PRIMARY KEY, 
    generation  VARCHAR(50),
    capacity    DECIMAL(5, 2),    
    frequency   DECIMAL(5, 2),   
    wattage     INT, 
    depth       DECIMAL(5, 2), 
    height      DECIMAL(5, 2),    
    width       DECIMAL(5, 2),   
    FOREIGN KEY (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cooler (
    product_id              INT PRIMARY KEY, 
    cooling_method          cooling_enum,
    fan_size                INT,              
    max_rotational_speed    INT,  
    wattage                 INT,               
    depth                   DECIMAL(5, 2), 
    height                  DECIMAL(5, 2),    
    width                   DECIMAL(5, 2),    
    FOREIGN KEY             (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE motherboard (
    product_id          INT PRIMARY KEY, 
    chipset_name        VARCHAR(50),
    num_memory_slots    SMALLINT,
    memory_speed_range  DECIMAL(5, 2),
    wattage             INT,
    depth               DECIMAL(5, 2), 
    height              DECIMAL(5, 2),    
    width               DECIMAL(5, 2),
    FOREIGN KEY         (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cpu (
    product_id          INT PRIMARY KEY, 
    generation          VARCHAR(50),
    microarchitecture   VARCHAR(50),
    num_cores           SMALLINT,
    num_threads         SMALLINT,
    base_frequency      DECIMAL(5, 2), 
    boost_frequency     DECIMAL(5, 2),
    max_memory_limit    INT,         
    wattage             INT,                
    FOREIGN KEY         (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "case" (
    product_id      INT PRIMARY KEY, 
    product_type    VARCHAR(50),
    color           VARCHAR(50),
    material        VARCHAR(50),
    fan_size        INT,         
    num_fans        SMALLINT,
    wattage         INT,
    depth           DECIMAL(5, 2), 
    height          DECIMAL(5, 2),    
    width           DECIMAL(5, 2),
    FOREIGN KEY     (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
); 

CREATE TABLE ssd (
    product_id  INT PRIMARY KEY, 
    capacity    DECIMAL(5, 2), 
    wattage     INT,
    FOREIGN KEY (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE power_supply (
    product_id          INT PRIMARY KEY, 
    supported_wattage   INT,
    depth               DECIMAL(5, 2), 
    height              DECIMAL(5, 2),    
    width               DECIMAL(5, 2),
    FOREIGN KEY         (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

--Create Compatible Tables--

CREATE TABLE compatible_mc_socket (
    cpu_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL, 
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (cpu_id) REFERENCES cpu (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_cc_socket (
    cpu_id      INT NOT NULL, 
    cooler_id   INT NOT NULL, 
    FOREIGN KEY (cooler_id) REFERENCES cooler (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cpu_id) REFERENCES cpu (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_gm_slot (
    gpu_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL, 
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (gpu_id) REFERENCES gpu (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_rm_slot (
    ram_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL, 
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (ram_id) REFERENCES ram_stick (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_gp_connector (
    gpu_id          INT NOT NULL, 
    power_supply_id INT NOT NULL, 
    FOREIGN KEY     (gpu_id) REFERENCES gpu (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (power_supply_id) REFERENCES power_supply (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_sm_slot (
    ssd_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL, 
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (ssd_id) REFERENCES ssd (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE client (
    client_id          SERIAL PRIMARY KEY, 
    phone_number       VARCHAR(15) NOT NULL UNIQUE,
    first_name         VARCHAR(50) NOT NULL,
    last_name          VARCHAR(50) NOT NULL,
    wallet_balance     DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    time_stamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    referral_code      VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE vip_client (
    client_id       INT PRIMARY KEY, 
    expiration_time TIMESTAMP NOT NULL,
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE address_client (
    client_id       INT NOT NULL, 
    province        VARCHAR(20) NOT NULL,
    remain_address  VARCHAR(191) NOT NULL,
    PRIMARY KEY     (client_id, province, remain_address),
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE shopping_cart (
    cart_number    SERIAL NOT NULL, 
    client_id      INT NOT NULL,
    cart_status    cart_enum NOT NULL,
    PRIMARY KEY    (client_id, cart_number),
    FOREIGN KEY    (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE discount_code (
    code            INT PRIMARY KEY, 
    amount          DECIMAL(10, 2) CHECK (amount > 0),
    discount_limit  DECIMAL(5, 2) CHECK (discount_limit > 0),
    usage_limit     SMALLINT DEFAULT 0 CHECK (usage_limit >= 0) , 
    expiration_time TIMESTAMP,
    code_type       discount_enum NOT NULL
);

CREATE TABLE private_code (
    code        INT PRIMARY KEY, 
    client_id   INT NOT NULL,
    time_stamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (code) REFERENCES discount_code (code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE transaction (
    tracking_code       INT PRIMARY KEY, 
    transaction_status  transaction_status_enum NOT NULL,
    time_stamp          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bank_transaction (
    tracking_code   INT PRIMARY KEY, 
    card_number     INT NOT NULL,
    FOREIGN KEY     (tracking_code) REFERENCES transaction (tracking_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE locked_shopping_cart (
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   SERIAL NOT NULL,
    PRIMARY KEY     (client_id, cart_number, locked_number),
    FOREIGN KEY     (client_id, cart_number) REFERENCES shopping_cart (client_id, cart_number) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE deposit_wallet (
    tracking_code   INT PRIMARY KEY, 
    client_id       INT NOT NULL,
    amount          DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (tracking_code) REFERENCES transaction (tracking_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE subscribes (
    tracking_code   INT PRIMARY KEY, 
    client_id       INT NOT NULL,
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (tracking_code) REFERENCES transaction (tracking_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE refers (
    referee_id  VARCHAR(20) PRIMARY KEY, 
    referrer_id VARCHAR(20) NOT NULL,
    FOREIGN KEY (referee_id) REFERENCES client (referral_code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (referrer_id) REFERENCES client (referral_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE added_to (
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   INT NOT NULL,
    product_id      INT NOT NULL, 
    quantity        SMALLINT CHECK (quantity > 0),
    cart_price      DECIMAL(12, 2) CHECK (cart_price >= 0),
    PRIMARY KEY     (client_id, cart_number, locked_number, product_id),
    FOREIGN KEY     (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (client_id, cart_number, locked_number) REFERENCES locked_shopping_cart (client_id, cart_number, locked_number) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE applied_to (
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   INT NOT NULL,
    discount_code   INT NOT NULL, 
    time_stamp      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY     (client_id, cart_number, locked_number, discount_code),
    FOREIGN KEY     (discount_code) REFERENCES discount_code (code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (client_id, cart_number, locked_number) REFERENCES locked_shopping_cart (client_id, cart_number, locked_number) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE issued_for (
    tracking_code   INT PRIMARY KEY,
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   INT NOT NULL,
    FOREIGN KEY     (client_id, cart_number, locked_number) REFERENCES locked_shopping_cart (client_id, cart_number, locked_number) ON UPDATE CASCADE ON DELETE CASCADE
);

--Triggers--

CREATE OR REPLACE FUNCTION ref_handler() 
RETURNS TRIGGER AS $$
DECLARE
    referrer            VARCHAR(20);
    referee             VARCHAR(20) := NEW.referee_id;
    current_level       INT := 1;
    discount_percentage DECIMAL(12, 2);
    new_discount_code   INT;
    client_id_val       INT;
BEGIN
    -- Apply a 50% discount to the **new referee** (first-time user)
    SELECT client_id INTO client_id_val FROM client WHERE referral_code = referee;
    
    INSERT INTO discount_code (code, amount, discount_limit, expiration_time, code_type)
    VALUES (
        nextval('discount_code_code_seq'), 
        0.5,  
        1000000, 
        NOW() + INTERVAL '1 week', 
        'private'
    ) RETURNING code INTO new_discount_code;
    
    INSERT INTO private_code (code, client_id, time_stamp)
    VALUES (new_discount_code, client_id_val, NOW());

    SELECT r.referrer_id INTO referrer FROM refers r WHERE r.referee_id = referee;

    WHILE referrer IS NOT NULL LOOP
        discount_percentage := 50 / (2 * current_level);

        SELECT client_id INTO client_id_val FROM client WHERE referral_code = referrer;

        IF discount_percentage < 1 THEN
            -- Fixed discount (50,000 Tomans)
            INSERT INTO discount_code (code, amount, discount_limit, expiration_time, code_type)
            VALUES (
                nextval('discount_code_code_seq'), 
                50000,  
                50000,  
                NOW() + INTERVAL '1 week', 
                'private'
            ) RETURNING code INTO new_discount_code;
        ELSE 
            -- Percentage-based discount
            INSERT INTO discount_code (code, amount, discount_limit, expiration_time, code_type)
            VALUES (
                nextval('discount_code_code_seq'), 
                discount_percentage / 100,  
                1000000,  
                NOW() + INTERVAL '1 week', 
                'private'
            ) RETURNING code INTO new_discount_code;
        END IF;

        INSERT INTO private_code (code, client_id, time_stamp)
        VALUES (new_discount_code, client_id_val, NOW());

        SELECT r.referrer_id INTO referrer FROM refers r WHERE r.referee_id = referrer;

        current_level := current_level + 1;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER referral_trigger
AFTER INSERT ON refers
FOR EACH ROW
EXECUTE FUNCTION ref_handler();

CREATE OR REPLACE FUNCTION product_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_count SMALLINT;
BEGIN
    SELECT p.stock_count INTO stock_count
    FROM product p
    WHERE p.id = NEW.product_id;

    IF stock_count < NEW.quantity THEN
        RAISE EXCEPTION 
        'Not Enough Stock For product_id: %', NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER out_of_stock_trigger
BEFORE INSERT OR UPDATE ON added_to
FOR EACH ROW
EXECUTE FUNCTION product_stock();

CREATE OR REPLACE FUNCTION reduce_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE product
    SET stock_count = stock_count - NEW.quantity
    WHERE id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reduce_stock_trigger
AFTER INSERT ON added_to
FOR EACH ROW
EXECUTE FUNCTION reduce_stock();

CREATE OR REPLACE FUNCTION cart_limit()
RETURNS TRIGGER AS $$
DECLARE
    cart_count INT;
    is_vip BOOLEAN;
BEGIN
    
    SELECT EXISTS (
        SELECT 1
        FROM vip_client
        WHERE client_id = NEW.client_id
    ) INTO is_vip;

    SELECT COUNT(*) INTO cart_count
    FROM shopping_cart
    WHERE client_id = NEW.client_id;

    IF is_vip THEN
        IF cart_count >= 5 THEN
            RAISE EXCEPTION 'VIP Cant Have More Than Five Shopping Carts';
        END IF;
    ELSE
        IF cart_count >= 1 THEN
            RAISE EXCEPTION 'Register Cant Have More Than One Shopping Carts';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cart_limit_trigger
BEFORE INSERT ON shopping_cart
FOR EACH ROW
EXECUTE FUNCTION cart_limit();

CREATE OR REPLACE FUNCTION append_discount()
RETURNS TRIGGER AS $$
DECLARE
    code_record RECORD;
BEGIN
    SELECT D.usage_count, D.usage_limit, D.expiration_time
    INTO code_record
    FROM discount_code AS D
    WHERE D.code = NEW.code;
    IF code_record IS NULL THEN
        RAISE EXCEPTION 'This Discount Code Is Invalid';
    END IF;
    IF code_record.expiration_time < NOW() THEN
        RAISE EXCEPTION 'This Discount Code Has Been Expired';
    END IF;
    IF code_record.usage_count >= code_record.usage_limit THEN
        RAISE EXCEPTION 'This Discount Code Is No Longer Available';
    END IF;
    RETURN NEW;

END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER check_expiration_limit_discount_trigger
BEFORE INSERT ON applied_to
FOR EACH ROW
EXECUTE FUNCTION append_discount();

CREATE OR REPLACE FUNCTION blocked_cart()
RETURNS TRIGGER AS $$
DECLARE
    cart_status_val cart_status_enum;
BEGIN
    SELECT cart_status
    INTO cart_status_val
    FROM shopping_cart
    WHERE cart_number = NEW.cart_number 
      AND client_id = NEW.client_id;

    IF cart_status_val = 'blocked' THEN
        RAISE EXCEPTION 'Cart % is blocked.', NEW.cart_number;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER adding_blocked_cart_trigger
BEFORE INSERT OR UPDATE ON added_to
FOR EACH ROW
EXECUTE FUNCTION blocked_cart();

CREATE TRIGGER issued_for_blocked_cart_trigger
BEFORE INSERT OR UPDATE ON issued_for
FOR EACH ROW
EXECUTE FUNCTION blocked_cart();

CREATE TRIGGER applied_to_blocked_cart_trigger
BEFORE INSERT OR UPDATE ON applied_to
FOR EACH ROW
EXECUTE FUNCTION blocked_cart();