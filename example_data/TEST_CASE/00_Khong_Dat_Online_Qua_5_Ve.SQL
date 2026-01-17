-- Test Case

-- Một khách hàng mua 6 vé online
SET IDENTITY_INSERT [dbo].[CHUYEN_XE] OFF
GO
SET IDENTITY_INSERT [dbo].[CHUYEN_XE] OFF
SET IDENTITY_INSERT [dbo].[HOA_DON_MUA_VE] OFF


BEGIN TRANSACTION
	SET IDENTITY_INSERT [dbo].[CHUYEN_XE] ON
	INSERT INTO [dbo].[CHUYEN_XE] (MaChuyenXe, MaXe, MaTuyenXe, ThoiGianKhoiHanh, LoaiChuyen, GiaVeCoBan, TrangThai, SoGheConLai, NgayTao, NgayCapNhatCuoi) VALUES
	(2, 9, 1, '2025-10-01 06:00:00', N'Ngày thường', 260000, N'Hoàn thành', 34, '2025-09-24 06:00:00', '2025-09-24 06:00:00');
	SET IDENTITY_INSERT [dbo].[CHUYEN_XE] OFF

	INSERT INTO [dbo].[PHAN_CONG] (MaChuyenXe, MaNhanVien, NgayTao, NgayCapNhatCuoi) VALUES
	(2, 20, '2025-09-24 06:00:00', '2025-09-24 06:00:00'),
	(2, 28, '2025-09-24 06:00:00', '2025-09-24 06:00:00'),
	(2, 24, '2025-09-24 06:00:00', '2025-09-24 06:00:00');

	INSERT INTO [dbo].[VE_XE] (MaVe, MaChuyenXe, DiemLenXe, DiemXuongXe, MaGhe, TrangThai, NgayTao, NgayCapNhatCuoi) VALUES
	('VE000023', 2, 1, 11, 'A03', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000024', 2, 1, 11, 'B08', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000025', 2, 1, 11, 'A05', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000026', 2, 1, 11, 'B14', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000027', 2, 1, 11, 'B17', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000028', 2, 1, 11, 'B13', N'Đã bán', '2025-09-28 16:37:51', '2025-09-28 16:37:51');
	
	SET IDENTITY_INSERT [dbo].[HOA_DON_MUA_VE] ON
	INSERT INTO [dbo].[HOA_DON_MUA_VE] (MaHoaDon, SoDienThoai, TriGiaHoaDon, NgayLapHoaDon, TrangThai, HinhThucThanhToan, MaNhanVienBanVe, NgayTao, NgayCapNhatCuoi) VALUES
	(6, '0905886225', 0, '2025-09-29 00:15:22', N'Đã thanh toán', N'ZaloPay', NULL, '2025-09-29 00:15:22', '2025-09-29 00:15:22');
	SET IDENTITY_INSERT [dbo].[HOA_DON_MUA_VE] OFF

	INSERT INTO [dbo].[CHI_TIET_HOA_DON] (MaHoaDon, MaVe, GiaVeThucTe, NgayTao, NgayCapNhatCuoi) VALUES
	(6, 'VE000023', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000024', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000025', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000026', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000027', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000028', 260000, '2025-09-28 16:37:51', '2025-09-28 16:37:51')
COMMIT TRANSACTION;

SELECT * FROM [CHUYEN_XE];
SELECT * FROM [PHAN_CONG]
SELECT * FROM [VE_XE];
SELECT * FROM [HOA_DON_MUA_VE];
SELECT * FROM [CHI_TIET_HOA_DON]


-- Hoa don mua hon 5 ve khong dat online

BEGIN TRANSACTION
	SET IDENTITY_INSERT [dbo].[CHUYEN_XE] ON
	INSERT INTO [dbo].[CHUYEN_XE] (MaChuyenXe, MaXe, MaTuyenXe, ThoiGianKhoiHanh, LoaiChuyen, GiaVeCoBan, TrangThai, SoGheConLai, NgayTao, NgayCapNhatCuoi) VALUES
	(2, 9, 1, '2025-10-01 06:00:00', N'Ngày thường', 260000, N'Hoàn thành', 34, '2025-09-24 06:00:00', '2025-09-24 06:00:00');
	SET IDENTITY_INSERT [dbo].[CHUYEN_XE] OFF

	INSERT INTO [dbo].[PHAN_CONG] (MaChuyenXe, MaNhanVien, NgayTao, NgayCapNhatCuoi) VALUES
	(2, 20, '2025-09-24 06:00:00', '2025-09-24 06:00:00'),
	(2, 28, '2025-09-24 06:00:00', '2025-09-24 06:00:00'),
	(2, 24, '2025-09-24 06:00:00', '2025-09-24 06:00:00');

	INSERT INTO [dbo].[VE_XE] (MaVe, MaChuyenXe, DiemLenXe, DiemXuongXe, MaGhe, TrangThai, NgayTao, NgayCapNhatCuoi) VALUES
	('VE000023', 2, 1, 11, 'A03', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000024', 2, 1, 11, 'B08', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000025', 2, 1, 11, 'A05', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000026', 2, 1, 11, 'B14', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000027', 2, 1, 11, 'B17', N'Đã bán', '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	('VE000028', 2, 1, 11, 'B13', N'Đã bán', '2025-09-28 16:37:51', '2025-09-28 16:37:51');
	
	SET IDENTITY_INSERT [dbo].[HOA_DON_MUA_VE] ON
    -- MaNhanVienBanVe = NULL Tuc la khong dat online, dat truc tiep tai van phong
	INSERT INTO [dbo].[HOA_DON_MUA_VE] (MaHoaDon, SoDienThoai, TriGiaHoaDon, NgayLapHoaDon, TrangThai, HinhThucThanhToan, MaNhanVienBanVe, NgayTao, NgayCapNhatCuoi) VALUES
	(6, '0905886225', 0, '2025-09-29 00:15:22', N'Đã thanh toán', N'ZaloPay', 8, '2025-09-29 00:15:22', '2025-09-29 00:15:22');
	SET IDENTITY_INSERT [dbo].[HOA_DON_MUA_VE] OFF

	INSERT INTO [dbo].[CHI_TIET_HOA_DON] (MaHoaDon, MaVe, GiaVeThucTe, NgayTao, NgayCapNhatCuoi) VALUES
	(6, 'VE000023', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000024', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000025', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000026', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000027', 260000, '2025-09-29 00:15:22', '2025-09-29 00:15:22'),
	(6, 'VE000028', 260000, '2025-09-28 16:37:51', '2025-09-28 16:37:51')
ROLLBACK TRANSACTION; -- Rollback vi khong muon tao du lieu