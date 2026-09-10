-- =========================================================
-- Bước 1: Import CSV vào bảng staging
-- ⚠️ SỬA đường dẫn bên dưới cho đúng với vị trí file trên máy bạn
-- =========================================================
USE interest_rate_analysis;

-- Xóa dữ liệu cũ nếu import lại (tránh trùng lặp)
TRUNCATE TABLE stg_interest_rates;

LOAD DATA LOCAL INFILE 'C:/Users/Admin/Documents/NEW_JOURNEY/PROJECT_2/lai_suat_clean.csv'
INTO TABLE stg_interest_rates
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(bank, deposit_type, term, term_months, @interest_rate)
SET interest_rate = NULLIF(TRIM(@interest_rate), '');

-- Kiểm tra đã import đúng số dòng chưa (phải ra 450)
SELECT COUNT(*) AS total_rows FROM stg_interest_rates;


-- =========================================================
-- Bước 2: Chuẩn hóa - tách danh sách ngân hàng DUY NHẤT ra bảng banks
-- =========================================================
-- Tạm tắt kiểm tra khóa ngoại để có thể TRUNCATE bảng banks
-- (banks đang bị interest_rates tham chiếu qua FOREIGN KEY,
--  MySQL chặn TRUNCATE dù bảng interest_rates đã rỗng)
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE interest_rates;
TRUNCATE TABLE banks;

SET FOREIGN_KEY_CHECKS = 1;  -- bật lại ngay, tránh quên mất

INSERT INTO banks (bank_name)
SELECT DISTINCT bank FROM stg_interest_rates;

-- Kiểm tra: phải ra đúng 29 ngân hàng
SELECT COUNT(*) AS total_banks FROM banks;


-- =========================================================
-- Bước 3: Đổ dữ liệu vào interest_rates, JOIN với banks để lấy bank_id
-- =========================================================
INSERT INTO interest_rates (bank_id, deposit_type, term_label, term_months, interest_rate)
SELECT
    b.bank_id,
    s.deposit_type,
    s.term,
    s.term_months,
    s.interest_rate
FROM stg_interest_rates s
JOIN banks b ON s.bank = b.bank_name;

-- Kiểm tra: phải ra đúng 450 dòng, khớp với staging
SELECT COUNT(*) AS total_interest_rates FROM interest_rates;


-- =========================================================
-- Bước 4: Thử 1 câu JOIN đơn giản để xem kết quả cuối cùng
-- =========================================================
SELECT
    b.bank_name,
    ir.deposit_type,
    ir.term_label,
    ir.interest_rate
FROM interest_rates ir
JOIN banks b ON ir.bank_id = b.bank_id
LIMIT 20;

SELECT * FROM banks



