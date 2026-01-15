from datetime import datetime, timedelta
import random

# Ngày cố định cho các trường mặc định (nếu không động)
FIXED_DATE = '2025-01-01'

# Phạm vi ngày tạo dữ liệu
start_date = datetime(2025, 10, 1)
end_date = datetime.now()

# Danh sách tuyến
tuyens = [1, 2, 3, 4]

# Giá vé (VNĐ, không thập phân)
gia = {1: 260000, 2: 260000, 3: 165000, 4: 165000}

# Xe LIMOU34 tốt: MaXe 6,7,8,9
xe_limou = [6, 7, 8, 9]

# Nhân viên: tài xế 11-20, lơ xe 21-40
tai_xe_ids = list(range(11, 21))
lo_xe_ids = list(range(21, 41))

# Tạo 100 số điện thoại khách hàng
khach_sdts = []
for i in range(1, 101):
    sdt = '090' + str(random.randint(1000000, 9999999)).zfill(7)
    khach_sdts.append(sdt)

# Điểm đi/đến theo tuyến
diem_di_dict = {1: 1, 2: 12, 3: 23, 4: 34}
diem_den_dict = {1: 11, 2: 22, 3: 33, 4: 44}

# Danh sách ghế cho LIMOU34
ghe_list = [
    'A01', 'A02', 'A03', 'A04', 'A05', 'A06', 'A07', 'A08', 'A09', 'A10',
    'A11', 'A12', 'A13', 'A14', 'A15', 'A16', 'A17',
    'B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B08', 'B09', 'B10',
    'B11', 'B12', 'B13', 'B14', 'B15', 'B16', 'B17'
]

# Tên khách hàng (không dấu)
ten_prefix = ['Nguyen Van ', 'Tran Thi ', 'Le Van ', 'Pham Thi ', 'Hoang Van ', 'Vu Thi ', 'Do Van ', 'Ngo Thi ']
ten_suffix = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P']

# Thời điểm hiện tại
now = datetime.now()

# Track số vé mỗi SDT mua trên mỗi chuyến (để đảm bảo <= 5 vé)
ve_per_sdt_chuyen = {}

# Counters
ma_chuyen = 1
ma_hoa_don = 1
ma_ve = 1

# Lists để batch insert
chuyen_values = []
phan_cong_values = []
ve_values = []
hoa_don_values = []
chi_tiet_values = []

# Vòng lặp theo ngày
current_date = start_date
while current_date <= end_date:
    is_weekend = current_date.weekday() >= 5
    num_chuyen_per_tuyen = 6 if is_weekend else 4
    interval_hours = 4 if is_weekend else 6

    for tuyen_idx, tuyen in enumerate(tuyens, 1):
        start_hour = tuyen_idx - 1
        for slot in range(num_chuyen_per_tuyen):
            hour = start_hour + slot * interval_hours
            if hour >= 24:
                hour -= 24
            thoi_gian_kh = current_date.replace(hour=hour, minute=0, second=0, microsecond=0)

            ma_xe = random.choice(xe_limou)
            loai_chuyen = 'Cuối tuần' if is_weekend else 'Ngày thường'
            gia_ve = gia[tuyen]
            trang_thai = 'Hoàn thành' if thoi_gian_kh < now else 'Dự kiến'
            so_ghe = 34

            # Ngày tạo chuyến: random 1-7 ngày trước ngày khởi hành
            days_before = random.randint(1, 7)
            ngay_tao_chuyen_dt = thoi_gian_kh - timedelta(days=days_before)
            ngay_tao_chuyen_str = ngay_tao_chuyen_dt.strftime('%Y-%m-%d %H:%M:%S')

            # Insert chuyến xe
            chuyen_values.append((
                ma_xe, tuyen,
                f"'{thoi_gian_kh.strftime('%Y-%m-%d %H:%M:%S')}'",
                f"N'{loai_chuyen}'",
                gia_ve,
                f"N'{trang_thai}'",
                so_ghe,
                f"'{ngay_tao_chuyen_str}'",
                f"'{ngay_tao_chuyen_str}'"
            ))

            # Phân công
            tai_xe = random.choice(tai_xe_ids)
            num_lo = random.randint(2, 3)
            lo_xe = random.sample(lo_xe_ids, num_lo)
            phan_cong_values.append((ma_chuyen, tai_xe, f"'{ngay_tao_chuyen_str}'", f"'{ngay_tao_chuyen_str}'"))
            for lx in lo_xe:
                phan_cong_values.append((ma_chuyen, lx, f"'{ngay_tao_chuyen_str}'", f"'{ngay_tao_chuyen_str}'"))

            # Vé
            num_ve_total = random.randint(so_ghe // 2, so_ghe)
            random.shuffle(ghe_list)
            ghe_ban = ghe_list[:num_ve_total]

            diem_len = diem_di_dict[tuyen]
            diem_xuong = diem_den_dict[tuyen]

            assigned = 0
            while assigned < num_ve_total:
                sdt = random.choice(khach_sdts)
                current_count = ve_per_sdt_chuyen.get((sdt, ma_chuyen), 0)
                can_buy = min(5 - current_count, num_ve_total - assigned)
                if can_buy <= 0:
                    continue

                # Thời gian tạo hóa đơn: random giữa ngày tạo chuyến và giờ khởi hành
                time_delta = thoi_gian_kh - ngay_tao_chuyen_dt
                random_seconds = random.uniform(0, time_delta.total_seconds())
                hoa_don_time_dt = ngay_tao_chuyen_dt + timedelta(seconds=random_seconds)
                hoa_don_time_str = hoa_don_time_dt.strftime('%Y-%m-%d %H:%M:%S')

                # Hóa đơn
                hinh_thuc = random.choice(['Momo', 'ZaloPay', 'Ngân Hàng', 'Tiền mặt'])
                ma_nv_ban = random.choice(range(6, 11)) if random.random() < 0.5 else 'NULL'
                tri_gia = gia_ve * can_buy
                hoa_don_values.append((
                    f"'{sdt}'",
                    tri_gia,
                    f"'{hoa_don_time_str}'",
                    "N'Đã thanh toán'",
                    f"N'{hinh_thuc}'",
                    ma_nv_ban,
                    f"'{hoa_don_time_str}'",
                    f"'{hoa_don_time_str}'"
                ))

                for _ in range(can_buy):
                    ghe = ghe_ban[assigned]
                    ma_ve_str = f"VE{str(ma_ve).zfill(6)}"
                    ve_values.append((
                        f"'{ma_ve_str}'",
                        ma_chuyen,
                        diem_len,
                        diem_xuong,
                        f"'{ghe}'",
                        "N'Đã bán'",
                        f"'{hoa_don_time_str}'",
                        f"'{hoa_don_time_str}'"
                    ))

                    chi_tiet_values.append((
                        ma_hoa_don,
                        f"'{ma_ve_str}'",
                        gia_ve,
                        f"'{hoa_don_time_str}'",
                        f"'{hoa_don_time_str}'"
                    ))

                    assigned += 1
                    ma_ve += 1

                ve_per_sdt_chuyen[(sdt, ma_chuyen)] = current_count + can_buy
                ma_hoa_don += 1

            ma_chuyen += 1

    current_date += timedelta(days=1)

# Hàm batch insert
def batch_insert(table, columns, values_list, batch_size=50):
    if not values_list:
        return ""
    sql = f"INSERT INTO [dbo].[{table}] ({', '.join(columns)}) VALUES\n"
    batches = [values_list[i:i + batch_size] for i in range(0, len(values_list), batch_size)]
    result = []
    for batch in batches:
        lines = [f"({', '.join(map(str, row))})" for row in batch]
        result.append(sql + ",\n".join(lines) + ";\n")
    return "".join(result)

# Populate NHAN_VIEN
nhan_vien_values = []
for i in range(1, 41):
    name = random.choice(ten_prefix) + random.choice(ten_suffix)
    sdt = '090' + str(random.randint(1000000, 9999999)).zfill(7)
    email = name.lower().replace(' ', '') + str(i) + '@example.com'
    cv = ['Quản trị viên'] * 5 + ['Nhân viên phòng vé'] * 5 + ['Tài xế'] * 10 + ['Lơ xe'] * 20
    cv = cv[i-1]
    nhan_vien_values.append((i, f"N'{name}'", f"'{email}'", f"'{sdt}'", f"N'{cv}'", f"'{FIXED_DATE}'", f"'{FIXED_DATE}'"))

files_content = {
    '07_NHAN_VIEN.sql': "SET IDENTITY_INSERT [dbo].[NHAN_VIEN] ON\nGO\n" +
                     batch_insert('NHAN_VIEN', ['MaNhanVien', 'HoVaTen', 'DiaChiEmail', 'SoDienThoai', 'ChucVu', 'NgayTao', 'NgayCapNhatCuoi'], nhan_vien_values, 50) +
                     "SET IDENTITY_INSERT [dbo].[NHAN_VIEN] OFF\nGO\n",

    '08_KHACH_HANG.sql': "-- Populate KHACH_HANG\n" +
                      batch_insert('KHACH_HANG', ['SoDienThoai', 'HoVaTen', 'DiaChiEmail', 'MaKhachHang', 'NgayTao', 'NgayCapNhatCuoi'], 
                                   [(f"'{sdt}'", f"N'{random.choice(ten_prefix) + random.choice(ten_suffix) + str(i)}'", f"'{random.choice(ten_prefix).lower().replace(' ', '') + str(i)}@example.com'", f"'KH{str(i).zfill(3)}'", f"'{FIXED_DATE}'", f"'{FIXED_DATE}'") for i, sdt in enumerate(khach_sdts, 1)], 50),

    '09_CHUYEN_XE.sql': batch_insert('CHUYEN_XE', ['MaXe', 'MaTuyenXe', 'ThoiGianKhoiHanh', 'LoaiChuyen', 'GiaVeCoBan', 'TrangThai', 'SoGheConLai', 'NgayTao', 'NgayCapNhatCuoi'], chuyen_values, 50),

    '10_PHAN_CONG.sql': batch_insert('PHAN_CONG', ['MaChuyenXe', 'MaNhanVien', 'NgayTao', 'NgayCapNhatCuoi'], phan_cong_values, 100),

    '11_VE_XE.sql': batch_insert('VE_XE', ['MaVe', 'MaChuyenXe', 'DiemLenXe', 'DiemXuongXe', 'MaGhe', 'TrangThai', 'NgayTao', 'NgayCapNhatCuoi'], ve_values, 100),

    '12_HOA_DON_MUA_VE.sql': batch_insert('HOA_DON_MUA_VE', ['SoDienThoai', 'TriGiaHoaDon', 'NgayLapHoaDon', 'TrangThai', 'HinhThucThanhToan', 'MaNhanVienBanVe', 'NgayTao', 'NgayCapNhatCuoi'], hoa_don_values, 100),

    '13_CHI_TIET_HOA_DON.sql': batch_insert('CHI_TIET_HOA_DON', ['MaHoaDon', 'MaVe', 'GiaVeThucTe', 'NgayTao', 'NgayCapNhatCuoi'], chi_tiet_values, 100)
}

# Ghi ra file
for filename, content in files_content.items():
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

print("Đã tạo các file SQL sau:")
for f in files_content.keys():
    print(f"  - {f}")
print("Chạy file 00_TRUNCATE_ALL.sql trước nếu muốn xóa dữ liệu cũ.")