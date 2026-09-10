"""
Script làm sạch dữ liệu lãi suất (lai_suat_raw.csv -> lai_suat_clean.csv)
---------------------------------------------------------------------------
Cách chạy:
    python clean_lai_suat.py
"""

import pandas as pd
import re

INPUT_FILE = "lai_suat_raw.csv"
OUTPUT_FILE = "lai_suat_clean.csv"

# Ánh xạ từ text kỳ hạn sang số tháng (để dễ sắp xếp/tính toán/vẽ biểu đồ)
TERM_TO_MONTHS = {
    "Không kỳ hạn": 0,
    "1 tháng": 1,
    "3 tháng": 3,
    "6 tháng": 6,
    "9 tháng": 9,
    "12 tháng": 12,
    "13 tháng": 13,
    "18 tháng": 18,
    "24 tháng": 24,
    "36 tháng": 36,
}


def clean_rate(text):
    """Chuyển '6,05' (định dạng số kiểu VN) thành số thực 6.05.
    Trả về None nếu là dấu '-' hoặc không phải số (missing data hợp lệ)."""
    if pd.isna(text):
        return None

    text = str(text).strip()

    # Dấu '-' hoặc rỗng nghĩa là ngân hàng không áp dụng kỳ hạn này
    if text in ("-", "", "N/A", "n/a"):
        return None

    # Đổi dấu phẩy thập phân kiểu VN sang dấu chấm kiểu chuẩn quốc tế
    text = text.replace(",", ".")

    # Loại bỏ ký tự % nếu có lẫn vào
    text = text.replace("%", "").strip()

    try:
        return float(text)
    except ValueError:
        # Trường hợp lạ không đoán trước được -> để None, không đoán bừa
        return None


def main():
    df = pd.read_csv(INPUT_FILE)
    print(f"Đọc {len(df)} dòng từ {INPUT_FILE}")

    # 1. Chuyển lãi suất text -> số thực
    df["interest_rate"] = df["rate_text"].apply(clean_rate)

    # 2. Thống kê nhanh missing data để biết mức độ ảnh hưởng
    missing_count = df["interest_rate"].isna().sum()
    print(f"Số dòng thiếu lãi suất (kỳ hạn không áp dụng): {missing_count}/{len(df)}")

    # 3. Chuyển kỳ hạn text -> số tháng
    df["term_months"] = df["term"].map(TERM_TO_MONTHS)

    # 4. Sắp xếp lại cột cho gọn
    df = df[["bank", "deposit_type", "term", "term_months", "interest_rate"]]

    # 5. Sắp xếp theo ngân hàng, loại hình, rồi kỳ hạn tăng dần
    df = df.sort_values(by=["bank", "deposit_type", "term_months"]).reset_index(drop=True)

    df.to_csv(OUTPUT_FILE, index=False, encoding="utf-8-sig")
    print(f"\nĐã lưu {len(df)} dòng dữ liệu sạch vào: {OUTPUT_FILE}")
    print("\n5 dòng đầu tiên:")
    print(df.head())


if __name__ == "__main__":
    main()
