# Phân tích Lãi suất Tiết kiệm Ngân hàng Việt Nam

Project phân tích dữ liệu end-to-end: crawl dữ liệu thật từ web (vượt qua chặn JavaScript bằng Selenium), thiết kế database quan hệ chuẩn hóa bằng MySQL, trực quan hóa bằng Power BI.

## Mục tiêu
Thu thập và so sánh lãi suất tiết kiệm của các ngân hàng tại Việt Nam theo từng kỳ hạn và loại hình gửi (tại quầy / trực tuyến), nhằm tìm ra ngân hàng và kỳ hạn có lãi suất tốt nhất.

## Công nghệ sử dụng
- Python (Selenium, BeautifulSoup, pandas) — crawl dữ liệu từ trang có chặn JavaScript, làm sạch dữ liệu
- MySQL — thiết kế database chuẩn hóa (staging table + 2 bảng quan hệ), viết truy vấn phân tích (JOIN, Self-JOIN, LEFT JOIN, GROUP BY, CASE WHEN)
- Power BI — xây dựng mối quan hệ giữa các bảng, viết DAX measures, trực quan hóa dashboard

## Quy trình thực hiện
1. Thu thập dữ liệu: Crawl 450 dòng lãi suất từ 29 ngân hàng bằng Selenium (trang gốc chặn crawl thông thường bằng JavaScript) — `crawl_lai_suat.py`
2. Làm sạch dữ liệu: Chuẩn hóa định dạng số kiểu Việt Nam, xử lý missing data (kỳ hạn không được công bố) — `clean_lai_suat.py`
3. Thiết kế database: Nạp dữ liệu vào bảng staging, sau đó chuẩn hóa ra 2 bảng có quan hệ (`banks`, `interest_rates`) qua khóa ngoại — `create_database_p2.sql`, `load_and_normalize.sql`
4. Viết truy vấn phân tích: 6 câu SQL sử dụng JOIN, Self-JOIN, LEFT JOIN, GROUP BY, CASE WHEN — `analysis_queries_p2.sql`
5. Trực quan hóa: Thiết lập quan hệ 1-nhiều trong Power BI, viết 6 DAX measures, dựng dashboard — `dax_measures_p2.txt`, `interest_rate_dashboard.pbix`

## Insight chính

- Về xu hướng theo kỳ hạn: Lãi suất tăng mạnh nhất ở giai đoạn đầu, từ mức gần 0% (không kỳ hạn) lên khoảng 6%/năm chỉ trong 6-9 tháng, sau đó gần như đi ngang từ kỳ hạn 12 tháng đến 36 tháng — cho thấy các ngân hàng không có nhiều động lực khuyến khích gửi dài hạn hơn 1 năm.
- Về mặt bằng chung: Lãi suất trung bình toàn hệ thống đạt 5.11%/năm, dao động từ 0% đến 9%/năm.
- Về ngân hàng dẫn đầu: PGBank có lãi suất trung bình cao nhất trong số 29 ngân hàng khảo sát, phản ánh xu hướng các ngân hàng quy mô nhỏ hơn phải đưa ra lãi suất hấp dẫn hơn để cạnh tranh thu hút tiền gửi.

## Dashboard

<p align="center">
  <img src="/images/interest_rate_dashboard-1.png" alt="Power BI Dashboard" width="80%">
</p>


## Cách chạy lại project
1. Cài đặt: `pip install selenium webdriver-manager beautifulsoup4 pandas --break-system-packages`
2. Chạy `crawl_lai_suat.py` để thu thập dữ liệu mới nhất (cần Google Chrome đã cài sẵn)
3. Chạy `clean_lai_suat.py` để làm sạch dữ liệu thô
4. Chạy `create_database_p2.sql` để tạo database và các bảng
5. Chạy `load_and_normalize.sql` để nạp và chuẩn hóa dữ liệu (nhớ sửa đường dẫn file CSV cho đúng máy bạn)
6. Mở `interest_rate_dashboard.pbix` bằng Power BI Desktop, kết nối lại nguồn dữ liệu nếu cần

## Tác giả
Hieu — Data Analyst Portfolio Project
