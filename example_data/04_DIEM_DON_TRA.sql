SET IDENTITY_INSERT [dbo].[DIEM_DON_TRA] ON
INSERT INTO [dbo].[DIEM_DON_TRA]
           ([MaDiem]
		   ,[TenDiem]
           ,[DiaChi]
           ,[TinhThanh]
           ,[NgayTao]
           ,[NgayCapNhatCuoi])
     VALUES
           (1, N'BX Miền Tây', N'VP BX Miền Tây: 395 Kinh Dương Vương , P.An Lạc , Q.Bình Tân , TP.HCM', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (2, N'BX An Sương', N'Bến Xe An Sương, Quốc Lộ 22, Ấp Đông Lân, Bà Điểm, Hóc Môn, TP Hồ Chí Minh', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (3, N'205 Phạm Ngũ Lão', N'VP Phạm Ngũ Lão: 205 Phạm Ngũ Lão, P.Phạm Ngũ Lão , Q.1 , TP.HCM', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (4, N'231-233 Lê Hồng Phong', N'VP Lê Hồng Phong: 231 Lê Hồng Phong , P.4 , Q.5 , TP.HCM', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (5, N'Hàng Xanh', N'VP Hàng Xanh: 486H-486J Điện Biên Phủ, P.21, Q. Bình Thạnh', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (6, N'Tân Phú', N'782 QL 20, TT Tân Phú, H. Tân Phú, Tỉnh Đồng Nai', N'Đồng Nai', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (7, N'Bảo Lộc', N'399 Trần Phú, Lộc Sơn, Bảo Lộc, Lâm Đồng, Việt Nam', N'Lâm Đồng', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (8, N'Lộc An - Bảo Lộc', N'Đường QL20, Thôn 3, xã Lộc An, H.Bảo Lâm, Lâm Đồng', N'Lâm Đồng', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (9, N'Di Linh', N'Bến xe Di Linh, Đường Hùng Vương, Thị Trấn Di Linh, Tỉnh Lâm Đồng', N'Lâm Đồng', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (10, N'Đức Trọng', N'795 Q Lộ 20 TT LIên Nghĩa _ H.Đức Trọng _ T.Lâm Đồng', N'Lâm Đồng', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (11, N'Đà Lạt', N'VP Đà Lạt, 01 Tô Hiến Thành , P.3 , TP.Đà Lạt, Lâm Đồng', N'Đà Lạt', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
		   ---
           (12, N'Cần Thơ', N'VP Bến xe Trung Tâm Cần Thơ: P.Hưng Thạnh , Q. Cái Răng , TP.Cần Thơ', N'Cần Thơ', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (13, N'Thân Cửu Nghĩa - Tiền Giang', N'Đường tỉnh 878, ấp 1, xã Tam Hiệp, huyện Châu Thành, tỉnh Tiền Giang', N'Tiền Giang', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (14, N'BV BÌNH DÂN', N'BỆNH VIỆN BÌNH DÂN, TP. Hồ Chí Minh', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (15, N'BV Y Dược', N'03 Mạc Thiên Tích, P11, Q5, TP.HCM', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (16, N'Đồng Đen', N'VP Đồng Đen: 288 Đồng Đen, P. 10, Q. Tân Bình, TP Hồ Chí Minh', N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (17, N'Benh Vien Nhi', N'15 Võ Trần Chí, Tân Kiên, Bình Chánh, TpHCM',  N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (18, N'BV Chợ Rẫy', N'Số 20 Phạm Hữu Chí, phường 12, Quận 5, Tp HCM',  N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (19, N'Bệnh Viện Ung Bướu', N'68 Nơ Trang Long, Phường 14, Quận Bình Thạnh, TP. Hồ Chí Minh',  N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (20, N'BV THONG NHAT', N'Số 1 Lý Thường Kiệt, Phường 7, Tân Bình, Hồ Chí Minh',  N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (21, N'BX QUAN 8', N'BX QUAN 8 , 932 TA QUANG BUU, HCM',  N'TP. HCM', CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME));

SET IDENTITY_INSERT [dbo].[DIEM_DON_TRA] OFF
GO

SELECT * FROM DIEM_DON_TRA
GO