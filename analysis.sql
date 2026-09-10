-- =========================================================
-- BỘ QUERY PHÂN TÍCH LÃI SUẤT NGÂN HÀNG
-- Database: interest_rate_analysis | Bảng: banks, interest_rates
-- =========================================================

USE interest_rate_analysis;


-- ---------------------------------------------------------
-- Q1. Top 10 ngân hàng có lãi suất kỳ hạn 12 tháng (Online) cao nhất
-- Kỹ thuật: INNER JOIN, WHERE, ORDER BY, LIMIT
-- ---------------------------------------------------------
SELECT
    b.bank_name,
    ir.interest_rate
FROM interest_rates ir
JOIN banks b ON ir.bank_id = b.bank_id
WHERE ir.term_months = 12
  AND ir.deposit_type = 'Online'
  AND ir.interest_rate IS NOT NULL
ORDER BY ir.interest_rate DESC
LIMIT 10;


-- ---------------------------------------------------------
-- Q2. So sánh lãi suất trung bình: gửi tại Quầy vs Online
-- Kỹ thuật: GROUP BY, AVG
-- ---------------------------------------------------------
SELECT
    deposit_type,
    ROUND(AVG(interest_rate), 2) AS lai_suat_trung_binh,
    COUNT(*) AS so_dong_du_lieu
FROM interest_rates
WHERE interest_rate IS NOT NULL
GROUP BY deposit_type;


-- ---------------------------------------------------------
-- Q3. Ngân hàng nào có SỐ KỲ HẠN không công bố lãi suất (NULL) nhiều nhất?
-- Kỹ thuật: JOIN, GROUP BY, đếm có điều kiện bằng SUM(CASE WHEN...)
-- ---------------------------------------------------------
SELECT
    b.bank_name,
    SUM(CASE WHEN ir.interest_rate IS NULL THEN 1 ELSE 0 END) AS so_ky_han_khong_cong_bo,
    COUNT(*) AS tong_so_ky_han
FROM interest_rates ir
JOIN banks b ON ir.bank_id = b.bank_id
GROUP BY b.bank_name
ORDER BY so_ky_han_khong_cong_bo DESC
LIMIT 10;




-- ---------------------------------------------------------
-- Q4. Kỳ hạn nào có lãi suất trung bình cao nhất (tìm "điểm ngọt" gửi tiền)
-- Kỹ thuật: GROUP BY, AVG, ORDER BY
-- ---------------------------------------------------------
SELECT
    term_months,
    ROUND(AVG(interest_rate), 2) AS lai_suat_trung_binh
FROM interest_rates
WHERE interest_rate IS NOT NULL
GROUP BY term_months
ORDER BY lai_suat_trung_binh DESC;


-- ---------------------------------------------------------
-- Q5. Chênh lệch lãi suất Online vs Quầy cho TỪNG ngân hàng (kỳ hạn 12 tháng)
-- Kỹ thuật: Self-JOIN (JOIN bảng interest_rates với chính nó)
-- ---------------------------------------------------------
SELECT
    b.bank_name,
    quay.interest_rate  AS lai_suat_quay,
    online.interest_rate AS lai_suat_online,
    (online.interest_rate - quay.interest_rate) AS chenh_lech
FROM banks b
JOIN interest_rates quay
    ON quay.bank_id = b.bank_id AND quay.deposit_type = 'Quầy' AND quay.term_months = 12
JOIN interest_rates online	
    ON online.bank_id = b.bank_id AND online.deposit_type = 'Online' AND online.term_months = 12
WHERE quay.interest_rate IS NOT NULL AND online.interest_rate IS NOT NULL
ORDER BY chenh_lech DESC;


-- ---------------------------------------------------------
-- Q6. Ngân hàng nào KHÔNG có hình thức gửi Online (chỉ có Quầy)?
-- Kỹ thuật: LEFT JOIN + kiểm tra NULL để tìm "không tồn tại"
-- ---------------------------------------------------------
SELECT DISTINCT b.bank_name
FROM banks b
LEFT JOIN interest_rates ir
    ON b.bank_id = ir.bank_id AND ir.deposit_type = 'Online'
WHERE ir.id IS NULL;

SELECT b.bank_name, ir.deposit_type, ir.term_label, ir.interest_rate
FROM interest_rates ir
JOIN banks b ON ir.bank_id = b.bank_id
WHERE ir.interest_rate = 0;