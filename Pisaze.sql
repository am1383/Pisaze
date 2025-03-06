--PiSaze Database Final Project--

--Bar Asas ER TA

--Create & Connect to the database

CREATE DATABASE pisaze;

\c pisaze

--Eextension For Job Scheduled

CREATE EXTENSION IF NOT EXISTS pg_cron;


--ENUM Section

CREATE TYPE cart_enum     AS ENUM ('active', 'blocked', 'locked');
CREATE TYPE discount_enum AS ENUM ('private', 'public');
CREATE TYPE transaction_status_enum AS ENUM ('successful', 'mid-successful', 'unsuccessful');
CREATE TYPE transaction_type_enum   AS ENUM ('wallet', 'bank');
CREATE TYPE cooling_enum  AS ENUM ('air', 'liquid');

--Table Section

CREATE TABLE product (
    id                  SERIAL PRIMARY KEY, 
    brand               VARCHAR(50) NOT NULL,
    model               VARCHAR(50) NOT NULL,
    category            VARCHAR(50),
    current_price       INT,
    stock_count         SMALLINT,
    image               BYTEA
);

CREATE TABLE motherboard (
    product_id          INT PRIMARY KEY, 
    wattage             INT,
    chipset_name        VARCHAR(50),
    num_memory_slots    SMALLINT,
    memory_speed_range  DECIMAL(5, 2),
    depth               DECIMAL(5, 2), 
    height              DECIMAL(5, 2),    
    width               DECIMAL(5, 2),
    FOREIGN KEY         (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE hdd (
    product_id          INT PRIMARY KEY, 
    rotational_speed    INT,  
    wattage             INT,      
    capacity            DECIMAL(5, 2),             
    depth               DECIMAL(5, 2), 
    height              DECIMAL(5, 2),    
    width               DECIMAL(5, 2),
    FOREIGN KEY         (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cooler (
    product_id           INT PRIMARY KEY, 
    cooling_method       cooling_enum,
    fan_size             INT,              
    max_rotational_speed INT,  
    wattage              INT,               
    depth                DECIMAL(5, 2), 
    height               DECIMAL(5, 2),    
    width                DECIMAL(5, 2),    
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cpu (
    product_id           INT PRIMARY KEY, 
    max_memory_limit     INT,         
    wattage              INT,   
    generation           VARCHAR(50),
    microarchitecture    VARCHAR(50),
    num_cores            SMALLINT,
    num_threads          SMALLINT,
    base_frequency       DECIMAL(5, 2), 
    boost_frequency      DECIMAL(5, 2),             
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE "case" (
    product_id           INT PRIMARY KEY, 
    fan_size             INT,         
    wattage              INT,
    num_fans             SMALLINT,
    type                 VARCHAR(50),
    color                VARCHAR(50),
    material             VARCHAR(50),
    depth                DECIMAL(5, 2), 
    height               DECIMAL(5, 2),    
    width                DECIMAL(5, 2),
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ram_stick (
    product_id           INT PRIMARY KEY, 
    wattage              INT, 
    generation           VARCHAR(191),
    capacity             DECIMAL(5, 2),    
    frequency            DECIMAL(5, 2),   
    height               DECIMAL(5, 2),    
    depth                DECIMAL(5, 2), 
    width                DECIMAL(5, 2),   
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE power_supply (
    product_id           INT PRIMARY KEY, 
    supported_wattage    INT,
    height               DECIMAL(5, 2), 
    depth                DECIMAL(5, 2),    
    width                DECIMAL(5, 2),
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ssd (
    product_id           INT PRIMARY KEY, 
    wattage              INT,
    capacity             DECIMAL(5, 2), 
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE gpu (
    product_id           INT PRIMARY KEY, 
    ram_size             INT,         
    wattage              INT,
    num_fans             SMALLINT,
    depth                DECIMAL(5, 2), 
    clock_speed          DECIMAL(5, 2), 
    height               DECIMAL(5, 2),    
    width                DECIMAL(5, 2),
    FOREIGN KEY          (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_cc_socket (
    cpu_id          INT NOT NULL, 
    cooler_id       INT NOT NULL,
    PRIMARY KEY     (cpu_id, cooler_id), 
    FOREIGN KEY     (cooler_id) REFERENCES cooler (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (cpu_id)    REFERENCES cpu (product_id)    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_rm_slot (
    ram_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL, 
    PRIMARY KEY     (ram_id, motherboard_id),
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (ram_id)         REFERENCES ram_stick (product_id)   ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_gp_connector (
    gpu_id          INT NOT NULL, 
    power_supply_id INT NOT NULL, 
    PRIMARY KEY     (gpu_id, power_supply_id),
    FOREIGN KEY     (power_supply_id) REFERENCES power_supply (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (gpu_id)          REFERENCES gpu (product_id)          ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_gm_slot (
    gpu_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL,
    PRIMARY KEY     (gpu_id, motherboard_id), 
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (gpu_id)         REFERENCES gpu (product_id)         ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_mc_socket (
    cpu_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL, 
    PRIMARY KEY     (cpu_id, motherboard_id), 
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (cpu_id)         REFERENCES cpu (product_id)         ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE compatible_sm_slot (
    ssd_id          INT NOT NULL, 
    motherboard_id  INT NOT NULL,
    PRIMARY KEY     (ssd_id, motherboard_id), 
    FOREIGN KEY     (ssd_id)         REFERENCES ssd (product_id)         ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (motherboard_id) REFERENCES motherboard (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE client (
    client_id       SERIAL PRIMARY KEY, 
    phone_number    VARCHAR(15) NOT NULL UNIQUE,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    referral_code   VARCHAR(20) NOT NULL UNIQUE,
    wallet_balance  DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    time_stamp      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

CREATE TABLE vip_client (
    client_id       INT PRIMARY KEY, 
    expiration_time TIMESTAMP   NOT NULL,
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE shopping_cart (
    cart_number     SERIAL    NOT NULL, 
    client_id       INT       NOT NULL,
    cart_status     cart_enum NOT NULL,
    PRIMARY KEY     (client_id, cart_number),
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE address_of_client (
    client_id       INT          NOT NULL, 
    province        VARCHAR(20)  NOT NULL,
    remain_address  VARCHAR(191) NOT NULL,
    PRIMARY KEY     (client_id, province, remain_address),
    FOREIGN KEY     (client_id) REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE discount_code (
    code            SERIAL PRIMARY KEY, 
    discount_limit  DECIMAL(12, 2)     CHECK (discount_limit > 0),
    amount          DECIMAL(12, 2)     CHECK (amount > 0),
    usage_limit     SMALLINT DEFAULT 1 CHECK (usage_limit >= 0) , 
    expiration_time TIMESTAMP,
    code_type       discount_enum      NOT NULL
);

CREATE TABLE private_code (
    code            INT PRIMARY KEY, 
    client_id       INT NOT NULL,
    time_stamp      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY     (client_id) REFERENCES client (client_id)   ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (code)      REFERENCES discount_code (code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE transaction (
    tracking_code       INT PRIMARY KEY, 
    transaction_status  transaction_status_enum NOT NULL,
    transaction_type    transaction_type_enum NOT NULL,
    time_stamp          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locked_shopping_cart (
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   SERIAL NOT NULL,
    time_stamp      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY     (client_id, cart_number, locked_number),
    FOREIGN KEY     (client_id, cart_number) REFERENCES shopping_cart (client_id, cart_number) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE bank_transaction (
    tracking_code   INT PRIMARY KEY, 
    card_number     INT NOT NULL,
    FOREIGN KEY     (tracking_code) REFERENCES transaction (tracking_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE deposit_wallet (
    tracking_code   INT PRIMARY KEY, 
    client_id       INT NOT NULL,
    amount          DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY     (client_id)     REFERENCES client (client_id)          ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (tracking_code) REFERENCES transaction (tracking_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE subscribes (
    tracking_code   INT PRIMARY KEY, 
    client_id       INT NOT NULL,
    FOREIGN KEY     (client_id)     REFERENCES client (client_id)          ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (tracking_code) REFERENCES transaction (tracking_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE refers (
    referee_id      VARCHAR(20) PRIMARY KEY, 
    referrer_id     VARCHAR(20) NOT NULL,
    FOREIGN KEY     (referee_id)  REFERENCES client (referral_code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (referrer_id) REFERENCES client (referral_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE added_to (
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   INT NOT NULL,
    product_id      INT NOT NULL, 
    quantity        INT DEFAULT 1  CHECK (quantity > 0),
    cart_price      DECIMAL(12, 2) CHECK (cart_price >= 0),
    PRIMARY KEY     (client_id, cart_number, locked_number, product_id),
    FOREIGN KEY     (product_id) REFERENCES product (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY     (client_id, cart_number, locked_number) REFERENCES locked_shopping_cart (client_id, cart_number, locked_number) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE issued_for (
    tracking_code   INT PRIMARY KEY,
    cart_number     INT NOT NULL, 
    client_id       INT NOT NULL,
    locked_number   INT NOT NULL,
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

--Function Section

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
            INSERT INTO discount_code (code, amount, discount_limit, expiration_time, code_type)
            VALUES (
                nextval('discount_code_code_seq'), 
                50000,  
                50000,  
                NOW() + INTERVAL '1 week', 
                'private'
            ) RETURNING code INTO new_discount_code;
        ELSE 
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

CREATE OR REPLACE FUNCTION blocked_cart()
RETURNS TRIGGER AS $$
DECLARE
    cart_status_val cart_enum;
BEGIN
    SELECT cart_status
    INTO cart_status_val
    FROM shopping_cart
    WHERE cart_number = NEW.cart_number 
      AND client_id = NEW.client_id;

    IF cart_status_val = 'blocked' THEN
        RAISE EXCEPTION 'Cart % Is Blocked', NEW.cart_number;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION stock_after_add_to_cart()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE product
    SET stock_count = stock_count - NEW.quantity
    WHERE id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION product_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_count_val SMALLINT;
BEGIN
    SELECT stock_count INTO stock_count_val
    FROM product 
    WHERE id = NEW.product_id;

    IF stock_count_val < NEW.quantity THEN
        RAISE EXCEPTION 
        'Not Enough Slot For product_id: %', NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cart_limit()
RETURNS TRIGGER AS $$
DECLARE
    cart_count_active   INT;
    cart_count_total    INT;
    is_vip              BOOLEAN;
BEGIN

    SELECT EXISTS (
        SELECT 1
        FROM vip_client
        WHERE client_id = NEW.client_id
    ) INTO is_vip;

    SELECT COUNT(*) 
    INTO cart_count_active
    FROM shopping_cart
    WHERE client_id = NEW.client_id
      AND cart_status = 'active';

    SELECT COUNT(*) 
    INTO cart_count_total
    FROM shopping_cart
    WHERE client_id = NEW.client_id;

    IF cart_count_total >= 5 THEN 
        RAISE EXCEPTION 'User Cant Have More Than Five Carts';
    END IF;

    IF is_vip THEN
        IF cart_count_active >= 5 THEN
            RAISE EXCEPTION 'VIP Cant Have More Than Five Active Carts';
        END IF;
    ELSE
        IF cart_count_active >= 1 THEN
            RAISE EXCEPTION 'Registered Cant Have More Than One Active Cart';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION append_discount()
RETURNS TRIGGER AS $$
DECLARE
    code_record RECORD := NULL;
    usage INT;
BEGIN
    SELECT d.usage_limit, d.expiration_time
    INTO code_record
    FROM discount_code d
    WHERE d.code = NEW.discount_code;

    IF code_record IS NULL THEN
        RAISE EXCEPTION 'Invalid Code.';
    END IF;

    SELECT COUNT(discount_code)   
    INTO usage
    FROM applied_to
    WHERE discount_code = NEW.discount_code
    GROUP BY discount_code;

    IF code_record.expiration_time < NOW() THEN
        RAISE EXCEPTION 'The Discount Code Has Been Expired.';
    END IF;

    IF usage >= code_record.usage_limit THEN
        RAISE EXCEPTION 'The Usage Limit Has Been Reached.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deposit_amount()
RETURNS TRIGGER AS $$
BEGIN

    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Amount Must Be More Than Zero';
    END IF;

    UPDATE client
    SET wallet_balance = wallet_balance + NEW.amount
    WHERE client_id = NEW.client_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reduce_wallet_subscribes()
RETURNS TRIGGER AS $$
DECLARE
    transaction_type   transaction_type_enum;
    current_balance    DECIMAL(12, 2);
BEGIN

    SELECT transaction_type
    INTO transaction_type
    FROM transaction
    WHERE tracking_code = NEW.tracking_code;

    IF transaction_type = 'wallet' THEN
        SELECT wallet_balance
        INTO current_balance
        FROM client
        WHERE client_id = NEW.client_id;

        IF current_balance >= 50000 THEN
            UPDATE client
            SET wallet_balance = wallet_balance - 50000
            WHERE client_id = NEW.client_id;
        ELSE
            RAISE EXCEPTION 
            'Required: 50,000, Available: %', current_balance;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reduce_wallet_subscribes()
RETURNS TRIGGER AS $$
DECLARE
    transaction_type_val    transaction_type_enum; 
    current_balance         DECIMAL(12, 2);   
    limit_value             DECIMAL(12, 2);            
    total_amount            DECIMAL(12, 2) := 0;   
    discount_amount         DECIMAL(12, 2) := 0;  
    discount_code           INT;                   
BEGIN
    SELECT t.transaction_type
    INTO transaction_type_val
    FROM transaction t
    WHERE t.tracking_code = NEW.tracking_code;

    IF transaction_type_val = 'wallet' THEN

        SELECT c.wallet_balance
        INTO current_balance
        FROM client c
        WHERE c.client_id = NEW.client_id;

        SELECT COALESCE(SUM(a.cart_price), 0) 
        INTO total_amount
        FROM added_to a
        WHERE a.client_id = NEW.client_id
          AND a.cart_number = NEW.cart_number
          AND a.locked_number = NEW.locked_number;

        FOR discount_code, discount_amount, limit_value IN 
            SELECT a.code, d.amount, d.discount_limit
            FROM applied_to a
            JOIN discount_code d ON a.code = d.code
            WHERE a.client_id       = NEW.client_id
              AND a.cart_number     = NEW.cart_number
              AND a.locked_number   = NEW.locked_number
        LOOP
            IF discount_amount <= 1 THEN  
                IF (total_amount * discount_amount) > limit_value THEN
                    total_amount := total_amount - limit_value;  
                ELSE
                    total_amount := total_amount - (total_amount * discount_amount); 
                END IF;
            ELSE  
                total_amount := total_amount - discount_amount;
            END IF; 
        END LOOP;

        IF total_amount < 0 THEN
            total_amount := 0;
        END IF;

        IF current_balance >= total_amount THEN
            UPDATE client
            SET wallet_balance = wallet_balance - total_amount
            WHERE client_id = NEW.client_id;
        ELSE
            RAISE EXCEPTION 'Required: %, Available: %', total_amount, current_balance;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vip_changer()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO vip_client(client_id, expiration_time)
    VALUES (NEW.client_id, NOW() + INTERVAL '1 month')
    ON CONFLICT (client_id) 
    DO UPDATE SET expiration_time = NOW() + INTERVAL '1 month'; 

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unlock_cart_after_payment()
RETURNS TRIGGER AS $$
DECLARE
    is_vip_expired BOOLEAN := FALSE;
BEGIN
    SELECT (v.expiration_time < NOW()) 
    INTO is_vip_expired
    FROM vip_client AS v
    WHERE v.client_id = NEW.client_id;

    IF is_vip_expired AND NEW.cart_number <> 1 THEN
        UPDATE shopping_cart
        SET cart_status   = 'blocked'
        WHERE client_id   = NEW.client_id
          AND cart_number = NEW.cart_number;
    ELSE
        UPDATE shopping_cart
        SET cart_status   = 'active'  
        WHERE client_id   = NEW.client_id
          AND cart_number = NEW.cart_number;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_order()
RETURNS VOID AS $$
DECLARE 
    locked_cart_expired RECORD;
    product_rec RECORD;
BEGIN
    FOR locked_cart_expired IN 
        SELECT *
        FROM locked_shopping_cart NATURAL JOIN shopping_cart 
        WHERE cart_status = 'locked' 
          AND (NOW() - time_stamp) > INTERVAL '3 day'
    LOOP
        FOR product_rec IN 
            SELECT product_id, quantity
            FROM locked_cart_expired NATURAL JOIN added_to
        LOOP
            UPDATE product 
            SET stock_count = stock_count + product_rec.quantity
            WHERE id = product_rec.product_id;
        END LOOP;

        UPDATE shopping_cart
        SET cart_status   = 'blocked'
        WHERE cart_number = locked_cart_expired.cart_number
          AND client_id   = locked_cart_expired.client_id;
        
        UPDATE locked_shopping_cart
        SET time_stamp      = NOW() + INTERVAL '7 days'
        WHERE cart_number   = locked_cart_expired.cart_number
          AND client_id     = locked_cart_expired.client_id
          AND locked_number = locked_cart_expired.locked_number;

    END LOOP;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION monthly_cashchecker()
RETURNS VOID AS $$
DECLARE
    vip_client_record RECORD;
    cashback_amount DECIMAL(12, 2);
BEGIN
    FOR vip_client_record IN 
        SELECT c.client_id, COALESCE(SUM(adt.cart_price), 0) * 0.15 AS total_cashback
        FROM vip_client vp 
        JOIN issued_for info ON vp.client_id = info.client_id
        JOIN transaction t   ON info.tracking_code = t.tracking_code
        JOIN added_to adt    ON info.client_id = adt.client_id 
        AND info.cart_number   = adt.cart_number 
        AND info.locked_number = adt.locked_number
        WHERE t.transaction_status = 'successful'
            AND   t.time_stamp >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
            AND   t.time_stamp < DATE_TRUNC('month', CURRENT_DATE)
        GROUP BY c.client_id
    LOOP
        cashback_amount := vip_client_record.total_cashback;

        UPDATE client
        SET wallet_balance = wallet_balance + cashback_amount
        WHERE client_id    = vip_client_record.client_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION subscription_end()
RETURNS VOID AS $$
DECLARE
    vip_rec RECORD;
BEGIN
    UPDATE shopping_cart
    SET cart_status = 'blocked'
    WHERE client_id IN (
        SELECT client_id FROM vip_client WHERE expiration_time < NOW()
    )
    AND cart_number > 1
    AND cart_status <> 'locked';
END;
$$ LANGUAGE plpgsql;

--Triggers

CREATE TRIGGER vip_trigger
AFTER INSERT ON subscribes 
FOR EACH ROW
EXECUTE FUNCTION vip_changer();

CREATE TRIGGER reduce_stock_trigger
AFTER INSERT ON added_to
FOR EACH ROW
EXECUTE FUNCTION stock_after_add_to_cart();

CREATE TRIGGER cart_limit_trigger
BEFORE INSERT OR UPDATE ON shopping_cart
FOR EACH ROW
EXECUTE FUNCTION cart_limit();

CREATE TRIGGER expiration_limit_discount_trigger
BEFORE INSERT ON applied_to
FOR EACH ROW
EXECUTE FUNCTION append_discount();

CREATE TRIGGER unlock_cart_trigger
AFTER INSERT ON issued_for
FOR EACH ROW
EXECUTE FUNCTION unlock_cart_after_payment();

CREATE TRIGGER reduce_user_wallet_order_trigger
AFTER INSERT ON issued_for
FOR EACH ROW
EXECUTE FUNCTION reduce_wallet_subscribes();

CREATE TRIGGER reduce_user_wallet_trigger
AFTER INSERT ON subscribes
FOR EACH ROW
EXECUTE FUNCTION reduce_wallet_subscribes();

CREATE TRIGGER deposit_into_wallet_trigger
AFTER INSERT ON deposit_wallet
FOR EACH ROW
EXECUTE FUNCTION deposit_amount();

CREATE TRIGGER applied_to_blocked_cart_trigger
BEFORE INSERT OR UPDATE ON applied_to
FOR EACH ROW
EXECUTE FUNCTION blocked_cart();

CREATE TRIGGER issued_for_blocked_cart_trigger
BEFORE INSERT OR UPDATE ON issued_for
FOR EACH ROW
EXECUTE FUNCTION blocked_cart();

CREATE TRIGGER adding_blocked_cart_trigger
BEFORE INSERT OR UPDATE ON added_to
FOR EACH ROW
EXECUTE FUNCTION blocked_cart();

CREATE TRIGGER referral_trigger
AFTER INSERT ON refers
FOR EACH ROW
EXECUTE FUNCTION ref_handler();

CREATE TRIGGER out_of_stock_trigger
BEFORE INSERT OR UPDATE ON added_to
FOR EACH ROW
EXECUTE FUNCTION product_stock();

--Job Scheduler

--Schedule for midnight on the 1st of the month
SELECT cron.schedule(
    '0 0 1 * *', 
    'SELECT monthly_cashchecker();'
);

--Schedule for run daily
SELECT cron.schedule(
    '0 0 * * *',
    'SELECT subscription_end();'
);

--Runs daily at midnight
SELECT cron.schedule(
    '0 0 * * *',
    'SELECT check_order();'
);