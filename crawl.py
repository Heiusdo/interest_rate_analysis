"""
Script crawl lãi suất ngân hàng từ webgia.com bằng Selenium
--------------------------------------------------------------
Cách chạy:
    python crawl_lai_suat.py

Vì trang này ẩn số liệu thật bằng JavaScript (thay bằng text giả trong HTML
thô), ta cần dùng Selenium để mở trình duyệt Chrome thật, đợi JavaScript
render xong, rồi mới đọc HTML đã hoàn chỉnh (có số liệu thật).
"""

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import pandas as pd
import time

URL = "https://webgia.com/lai-suat/"

# Thứ tự các kỳ hạn xuất hiện trong bảng (đúng theo cấu trúc trang đã kiểm tra)
TERMS = [
    "Không kỳ hạn", "1 tháng", "3 tháng", "6 tháng", "9 tháng",
    "12 tháng", "13 tháng", "18 tháng", "24 tháng", "36 tháng",
]


def get_rendered_html(url):
    """Mở trình duyệt Chrome ẩn (headless), đợi JS chạy xong, trả về HTML đầy đủ."""
    options = webdriver.ChromeOptions()
    options.add_argument("--headless=new")   # chạy ẩn, không hiện cửa sổ Chrome
    options.add_argument("--window-size=1920,1080")

    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)

    print(f"Đang mở trang: {url}")
    driver.get(url)

    time.sleep(5)  # ⚠️ đợi JavaScript render xong, có thể cần tăng nếu mạng chậm

    html = driver.page_source
    driver.quit()
    return html


def parse_table(table_tag, deposit_type):
    """Tách dữ liệu từ 1 bảng (quầy hoặc online)."""
    rows = []

    # ⚠️ CẦN KIỂM TRA LẠI: bỏ qua 2 dòng đầu (header), lấy các dòng dữ liệu thật
    all_trs = table_tag.find_all("tr")
    data_trs = all_trs[2:]  # bỏ 2 dòng tiêu đề (tên bảng + tên kỳ hạn)

    for tr in data_trs:
        cells = tr.find_all("td")
        if len(cells) < 2:
            continue

        bank_name = cells[0].get_text(strip=True)

        for i, term in enumerate(TERMS):
            col_index = i + 1
            if col_index < len(cells):
                rate_text = cells[col_index].get_text(strip=True)
                rows.append({
                    "bank": bank_name,
                    "term": term,
                    "deposit_type": deposit_type,
                    "rate_text": rate_text,
                })

    return rows


def main():
    html = get_rendered_html(URL)
    soup = BeautifulSoup(html, "html.parser")

    tables = soup.find_all("table")
    print(f"Tìm thấy {len(tables)} bảng trên trang.")

    all_rows = []
    if len(tables) >= 2:
        # ⚠️ CẦN KIỂM TRA: bảng đầu tiên là "Quầy", bảng thứ 2 là "Online"
        all_rows += parse_table(tables[0], "Quầy")
        all_rows += parse_table(tables[1], "Online")
    else:
        print("CẢNH BÁO: không tìm đủ 2 bảng, kiểm tra lại cấu trúc trang.")

    df = pd.DataFrame(all_rows)
    df.to_csv("lai_suat_raw.csv", index=False, encoding="utf-8-sig")
    print(f"Đã crawl được {len(df)} dòng, lưu vào lai_suat_raw.csv")
    print("\n5 dòng đầu tiên:")
    print(df.head())


if __name__ == "__main__":
    main()