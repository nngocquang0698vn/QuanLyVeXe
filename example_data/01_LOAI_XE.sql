INSERT INTO [dbo].[LOAI_XE]
           ([MaLoaiXe]
           ,[TenLoaiXe]
           ,[SoCho]
           ,[NgayTao]
           ,[NgayCapNhatCuoi])
     VALUES
           ('LIMOU34', N'Xe limousine 34 chỗ', 34, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           ('GIUONG28', N'Xe giường nằm 28 chỗ', 28, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME));
GO

SELECT * FROM [dbo].[LOAI_XE]
GO
