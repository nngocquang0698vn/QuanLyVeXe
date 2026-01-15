SET IDENTITY_INSERT [dbo].[TUYEN_XE] ON
GO

INSERT INTO [dbo].[TUYEN_XE]
           (
		   [MaTuyenXe]
		   ,[DiemDi]
           ,[DiemDen]
           ,[TenTuyenXe]
           ,[KhoangCach]
           ,[ThoiGianChayDuKien]
           ,[NgayTao]
           ,[NgayCapNhatCuoi]
		   )
     VALUES
           (1, 1, 11, N'TP. HCM - Đà Lạt', 310, 8, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (2, 11, 1, N'Đà Lạt - TP. HCM', 310, 8, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (3, 12, 2, N'Cần Thơ - TP. HCM', 160, 4, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
           (4, 2, 12, N'TP. HCM - Cần Thơ', 160, 4, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME));

SET IDENTITY_INSERT [dbo].[TUYEN_XE] OFF
GO

SELECT * FROM TUYEN_XE
GO


-- TEST TRIGGER
-- SET IDENTITY_INSERT [dbo].[TUYEN_XE] ON
-- GO
-- INSERT INTO [dbo].[TUYEN_XE]
--            (
-- 		   [MaTuyenXe]
-- 		   ,[DiemDi]
--            ,[DiemDen]
--            ,[TenTuyenXe]
--            ,[KhoangCach]
--            ,[ThoiGianChayDuKien]
--            ,[NgayTao]
--            ,[NgayCapNhatCuoi]
-- 		   )
--      VALUES
--            (1, 1, 11, N'A', 310, 1, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
--            (2, 11, 1, N'B', 310, 1, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
--            (3, 12, 2, N'C', 160, 1, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME)),
--            (4, 2, 12, N'D', 160, 1, CAST('01-01-2025' AS DATETIME), CAST('01-01-2025' AS DATETIME));
-- SET IDENTITY_INSERT [dbo].[TUYEN_XE] OFF
-- GO

-- SELECT * FROM TUYEN_XE
-- GO