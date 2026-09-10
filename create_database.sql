-- =========================================================
-- Bước 1: Tạo database
-- =========================================================
CREATE DATABASE IF NOT EXISTS interest_rate_analysis
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE interest_rate_analysis;

-- =========================================================
-- Bước 2: Tạo bảng STAGING - nơi nạp dữ liệu thô vào trước
-- (giống hệt cấu trúc file CSV, chưa chuẩn hóa quan hệ)
-- =========================================================
CREATE TABLE IF NOT EXISTS stg_interest_rates (
    bank            VARCHAR(100) NOT NULL,
    deposit_type    VARCHAR(20)  NOT NULL,
    term            VARCHAR(50)  NOT NULL,
    term_months     INT          NOT NULL,
    interest_rate   DECIMAL(5,2) NULL       -- NULL = kỳ hạn không áp dụng
);

-- =========================================================
-- Bước 3: Tạo 2 bảng CHUẨN HÓA (đích cuối cùng)
-- =========================================================

-- Bảng banks: mỗi ngân hàng chỉ xuất hiện DUY NHẤT 1 lần
CREATE TABLE IF NOT EXISTS banks (
    bank_id     INT AUTO_INCREMENT PRIMARY KEY,
    bank_name   VARCHAR(100) NOT NULL UNIQUE
);

-- Bảng interest_rates: mỗi dòng là 1 mức lãi suất, tham chiếu tới banks qua bank_id
CREATE TABLE IF NOT EXISTS interest_rates (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    bank_id         INT NOT NULL,
    deposit_type    VARCHAR(20)  NOT NULL,
    term_label      VARCHAR(50)  NOT NULL,
    term_months     INT          NOT NULL,
    interest_rate   DECIMAL(5,2) NULL,
    FOREIGN KEY (bank_id) REFERENCES banks(bank_id)
);

