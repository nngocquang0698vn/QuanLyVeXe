
SET IDENTITY_INSERT [dbo].[XE] ON

INSERT INTO [dbo].[XE]
           ([MaXe]
		   ,[BienSo]
           ,[MaLoaiXe]
           ,[TrangThai]
           ,[NgayTao]
           ,[NgayCapNhatCuoi])
     VALUES
           (1, '51A-10001', 'GIUONG28', N'Ngừng khai thác', CAST('01-01-2025' AS DATETIME), CAST('06-30-2025' AS DATETIME)),
           (2, '51A-10002', 'GIUONG28', N'Ngừng khai thác', CAST('01-01-2025' AS DATETIME), CAST('06-30-2025' AS DATETIME)),
           (3, '51A-10003', 'GIUONG28', N'Ngừng khai thác', CAST('01-01-2025' AS DATETIME), CAST('06-30-2025' AS DATETIME)),
           (4, '51A-10004', 'GIUONG28', N'Ngừng khai thác', CAST('01-01-2025' AS DATETIME), CAST('06-30-2025' AS DATETIME)),
           (5, '51A-10005', 'GIUONG28', N'Ngừng khai thác', CAST('01-01-2025' AS DATETIME), CAST('06-30-2025' AS DATETIME)),
           (6, '51A-20001', 'LIMOU34', N'Tốt', CAST('01-01-2025' AS DATETIME), CAST('01-12-2026' AS DATETIME)),
           (7, '51A-20002', 'LIMOU34', N'Tốt', CAST('01-01-2025' AS DATETIME), CAST('01-12-2026' AS DATETIME)),
           (8, '51A-20003', 'LIMOU34', N'Tốt', CAST('01-01-2025' AS DATETIME), CAST('01-12-2026' AS DATETIME)),
           (9, '51A-20004', 'LIMOU34', N'Tốt', CAST('01-01-2025' AS DATETIME), CAST('01-12-2026' AS DATETIME)),
           (10, '51A-20005', 'LIMOU34', N'Bảo Trì', CAST('01-01-2025' AS DATETIME), CAST('01-01-2026' AS DATETIME));
GO

SET IDENTITY_INSERT [dbo].[XE] OFF
SELECT * FROM [XE];
GO