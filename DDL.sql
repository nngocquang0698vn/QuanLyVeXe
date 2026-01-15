USE MASTER;
GO

ALTER DATABASE QUAN_LY_VE_XE
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE; 
GO


DROP DATABASE IF EXISTS QUAN_LY_VE_XE;
GO

CREATE DATABASE QUAN_LY_VE_XE;
GO

USE QUAN_LY_VE_XE;
GO

EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL"

DROP TABLE IF EXISTS LOAI_XE;
GO

-- Table 01
CREATE TABLE LOAI_XE (
    MaLoaiXe VARCHAR(10) PRIMARY KEY,
    TenLoaiXe NVARCHAR(50) NOT NULL,
	SoCho INT NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 02
DROP TABLE IF EXISTS XE;
GO

CREATE TABLE XE (
    MaXe INT IDENTITY(1,1) PRIMARY KEY,
    BienSo VARCHAR(20) UNIQUE NOT NULL,
    MaLoaiXe VARCHAR(10) FOREIGN KEY REFERENCES LOAI_XE(MaLoaiXe) NOT NULL,
    TrangThai NVARCHAR(50) CHECK ( TrangThai IN (N'Tốt', N'Bảo Trì', N'Ngừng khai thác')) NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO


-- Table 03
DROP TABLE IF EXISTS GHE;
GO

CREATE TABLE GHE (
    MaLoaiXe VARCHAR(10),
    MaGhe VARCHAR(5),
    Tang NVARCHAR(20) CHECK (Tang IN (N'Tầng trên', N'Tầng dưới')) NOT NULL,
    PRIMARY KEY (MaLoaiXe, MaGhe),
    FOREIGN KEY (MaLoaiXe) REFERENCES LOAI_XE(MaLoaiXe),
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 04
DROP TABLE IF EXISTS  DIEM_DON_TRA;
GO

CREATE TABLE DIEM_DON_TRA (
    MaDiem INT IDENTITY(1,1) PRIMARY KEY,
    TenDiem NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(200),
    TinhThanh NVARCHAR(50) NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 05
DROP TABLE IF EXISTS TUYEN_XE;
GO

CREATE TABLE TUYEN_XE (
    MaTuyenXe INT IDENTITY(1,1) PRIMARY KEY,
    DiemDi INT NOT NULL,
    DiemDen INT NOT NULL,
    TenTuyenXe NVARCHAR(100) NOT NULL,
    KhoangCach FLOAT NOT NULL,
    ThoiGianChayDuKien INT NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 06
DROP TABLE IF EXISTS CHI_TIET_TUYEN_XE;
GO
CREATE TABLE CHI_TIET_TUYEN_XE (
    MaChiTietTuyenXe INT IDENTITY(1,1) PRIMARY KEY,
    MaTuyenXe INT FOREIGN KEY REFERENCES TUYEN_XE(MaTuyenXe) NOT NULL,
    MaDiem INT FOREIGN KEY REFERENCES DIEM_DON_TRA(MaDiem) NOT NULL,
    DiemTruoc INT NULL FOREIGN KEY REFERENCES  CHI_TIET_TUYEN_XE(MaChiTietTuyenXe),
    DiemSau INT NULL FOREIGN KEY REFERENCES CHI_TIET_TUYEN_XE(MaChiTietTuyenXe),
    ThoiGianDiChuyenTuDiemTruoc INT NOT NULL DEFAULT 0,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Ràng buộc
-- Mỗi tuyến xe phải có đúng một điểm xuất phát và một điểm kết thúc
-- Điểm xuất phát và điểm kết thúc phải khác tỉnh thành
CREATE OR ALTER TRIGGER TRG_CheckTuyenXeStartEnd
ON CHI_TIET_TUYEN_XE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy tất cả MaTuyenXe bị ảnh hưởng
    DECLARE @affected TABLE (MaTuyenXe INT PRIMARY KEY);
    INSERT INTO @affected (MaTuyenXe)
    SELECT DISTINCT MaTuyenXe FROM inserted
    UNION
    SELECT DISTINCT MaTuyenXe FROM deleted;

    DECLARE @MaTuyenXe INT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT MaTuyenXe FROM @affected;
    OPEN cur;
    FETCH NEXT FROM cur INTO @MaTuyenXe;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @StartCount INT = (SELECT COUNT(*) FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemTruoc IS NULL);
        DECLARE @EndCount INT = (SELECT COUNT(*) FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemSau IS NULL);

        IF @StartCount != 1 OR @EndCount != 1
        BEGIN
            RAISERROR (N'Mỗi tuyến xe phải có đúng một điểm xuất phát và một điểm kết thúc (MaTuyenXe = %d)', 16, 1, @MaTuyenXe);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @DiemDi INT = (SELECT MaChiTietTuyenXe FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemTruoc IS NULL);
        DECLARE @DiemDen INT = (SELECT MaChiTietTuyenXe FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemSau IS NULL);

        DECLARE @TinhDi NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemDi);
        DECLARE @TinhDen NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemDen);

        IF @TinhDi = @TinhDen
        BEGIN
            RAISERROR (N'Điểm xuất phát và điểm kết thúc phải khác tỉnh thành (MaTuyenXe = %d)', 16, 1, @MaTuyenXe);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        FETCH NEXT FROM cur INTO @MaTuyenXe;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- Tính toán bằng TRIGGER
-- TenTuyenXe = {Tỉnh xuất phát} - {Tỉnh Đến}
-- ThoiGianChayDuKien được tính theo giờ (bằng tổng thời gian dự kiến di chuyển giữa 2 điểm trên hành trình)
CREATE OR ALTER TRIGGER TRG_UpdateThoiGianChayAndTenTuyenXe
ON CHI_TIET_TUYEN_XE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @affected TABLE (MaTuyenXe INT PRIMARY KEY);
    INSERT INTO @affected (MaTuyenXe)
    SELECT DISTINCT MaTuyenXe FROM inserted
    UNION
    SELECT DISTINCT MaTuyenXe FROM deleted;

    DECLARE @MaTuyenXe INT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT MaTuyenXe FROM @affected;
    OPEN cur;
    FETCH NEXT FROM cur INTO @MaTuyenXe;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @DiemDi INT = (SELECT DiemDi FROM TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe);
        DECLARE @DiemDen INT = (SELECT DiemDen FROM TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe);
		-- PRINT @DiemDi
		-- PRINT @DiemDen

        IF @DiemDi IS NULL OR @DiemDen IS NULL
        BEGIN
            FETCH NEXT FROM cur INTO @MaTuyenXe;
            CONTINUE;
        END

        DECLARE @TinhDi NVARCHAR(50) = (
            SELECT TOP 1 d.TinhThanh 
            FROM CHI_TIET_TUYEN_XE c 
            JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem 
            WHERE c.MaDiem = @DiemDi
        );

        DECLARE @TinhDen NVARCHAR(50) = (
            SELECT TOP 1 d.TinhThanh 
            FROM CHI_TIET_TUYEN_XE c 
            JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem 
            WHERE c.MaDiem = @DiemDen
        );

        DECLARE @TenTuyenXe NVARCHAR(100) = ISNULL(@TinhDi, N'Không xác định') + N' - ' + ISNULL(@TinhDen, N'Không xác định');
		-- PRINT @TenTuyenXe
        DECLARE @TotalMinutes INT = 0;
        DECLARE @Current INT = (SELECT MaChiTietTuyenXe FROM CHI_TIET_TUYEN_XE where MaDiem = @DiemDi and  MaTuyenXe = @MaTuyenXe) ;

        -- Duyệt toàn bộ chuỗi từ DiemDi đến DiemDen
        WHILE @Current IS NOT NULL
        BEGIN
            DECLARE @ThoiGian INT, @Next INT;
            SELECT 
                @ThoiGian = ThoiGianDiChuyenTuDiemTruoc,
                @Next = DiemSau
            FROM CHI_TIET_TUYEN_XE 
            WHERE MaChiTietTuyenXe = @Current;
			-- PRINT @ThoiGian
            SET @TotalMinutes += ISNULL(@ThoiGian, 0);
            SET @Current = @Next;
        END

        DECLARE @Hours INT = CEILING(@TotalMinutes / 60.0);

        UPDATE TUYEN_XE 
        SET 
            TenTuyenXe = @TenTuyenXe,
            ThoiGianChayDuKien = @Hours,
            NgayCapNhatCuoi = GETDATE()
        WHERE MaTuyenXe = @MaTuyenXe;

        FETCH NEXT FROM cur INTO @MaTuyenXe;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- Table 07
DROP TABLE IF EXISTS NHAN_VIEN;
GO
CREATE TABLE NHAN_VIEN (
    MaNhanVien INT IDENTITY(1,1) PRIMARY KEY,
    HoVaTen NVARCHAR(100) NOT NULL,
    DiaChiEmail VARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) NOT NULL,
    ChucVu NVARCHAR(50) CHECK (ChucVu IN (N'Quản trị viên', N'Nhân viên phòng vé', N'Tài xế', N'Lơ xe')) NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 08
CREATE TABLE KHACH_HANG (
    SoDienThoai VARCHAR(15) PRIMARY KEY,
    HoVaTen NVARCHAR(100) NOT NULL,
    DiaChiEmail VARCHAR(100),
    MaKhachHang VARCHAR(20) UNIQUE,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 09
DROP TABLE IF EXISTS CHUYEN_XE;
GO

CREATE TABLE CHUYEN_XE (
    MaChuyenXe INT IDENTITY(1,1) PRIMARY KEY,
    MaXe INT FOREIGN KEY REFERENCES XE(MaXe) NOT NULL,
    MaTuyenXe INT FOREIGN KEY REFERENCES TUYEN_XE(MaTuyenXe) NOT NULL,
    ThoiGianKhoiHanh DATETIME NOT NULL,
    LoaiChuyen NVARCHAR(50),
    GiaVeCoBan DECIMAL(18,0) NOT NULL, -- VNĐ
    TrangThai NVARCHAR(50) CHECK ( TrangThai IN (N'Dự kiến', N'Mở bán', N'Kết thúc bán vé', N'Sắp chạy', N'Đang chạy', N'Hoàn thành', N'Huỷ')) NOT NULL,
    SoGheConLai INT NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO


-- Table 10
CREATE TABLE PHAN_CONG (
    MaPhanCong INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenXe INT FOREIGN KEY REFERENCES CHUYEN_XE(MaChuyenXe) NOT NULL,
    MaNhanVien INT FOREIGN KEY REFERENCES NHAN_VIEN(MaNhanVien) NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME,
    CONSTRAINT UQ_PhanCong UNIQUE (MaChuyenXe, MaNhanVien)
);
GO

-- Table 11
DROP TABLE IF EXISTS VE_XE;
GO
CREATE TABLE VE_XE (
    MaVe VARCHAR(8) PRIMARY KEY,
    MaChuyenXe INT FOREIGN KEY REFERENCES CHUYEN_XE(MaChuyenXe) NOT NULL,
    DiemLenXe INT FOREIGN KEY REFERENCES CHI_TIET_TUYEN_XE(MaChiTietTuyenXe) NOT NULL,
    DiemXuongXe INT FOREIGN KEY REFERENCES CHI_TIET_TUYEN_XE(MaChiTietTuyenXe) NOT NULL,
    MaGhe VARCHAR(5) NOT NULL,
    TrangThai NVARCHAR(50) CHECK ( TrangThai IN (N'Đã bán', N'Đã huỷ', N'Đã lấy vé vật lý')) NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Ràng buộc bằng Trigger
-- Một vé không thể được bán cho khách hàng!
CREATE OR ALTER TRIGGER TRG_CheckUniqueActiveSeat
ON VE_XE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.TrangThai IN (N'Đã bán', N'Đã lấy vé vật lý')
        AND EXISTS (
            SELECT 1 
            FROM VE_XE v 
            WHERE v.MaChuyenXe = i.MaChuyenXe 
              AND v.MaGhe = i.MaGhe 
              AND v.TrangThai IN (N'Đã bán', N'Đã lấy vé vật lý') 
              AND v.MaVe != i.MaVe
        )
    )
    BEGIN
        RAISERROR (N'Ghế đã được bán hoặc lấy vé (vi phạm ràng buộc ghế duy nhất)', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Mã ghế phải phù hợp với loại xe
CREATE OR ALTER TRIGGER TRG_CheckMaGheValidForXe
ON VE_XE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CHUYEN_XE c ON i.MaChuyenXe = c.MaChuyenXe
        JOIN XE x ON c.MaXe = x.MaXe
        LEFT JOIN GHE g ON x.MaLoaiXe = g.MaLoaiXe AND i.MaGhe = g.MaGhe
        WHERE g.MaGhe IS NULL  -- Ghế không tồn tại cho loại xe đó
    )
    BEGIN
        RAISERROR (N'Mã ghế không phù hợp với loại xe của chuyến', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Điểm đón phải ở tỉnh đi, điểm trả phải ở tỉnh đến
CREATE OR ALTER TRIGGER TRG_CheckDiemDonTraOnTuyen
ON VE_XE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CHUYEN_XE cx ON i.MaChuyenXe = cx.MaChuyenXe
        JOIN TUYEN_XE t ON cx.MaTuyenXe = t.MaTuyenXe
        JOIN CHI_TIET_TUYEN_XE cdi ON t.DiemDi = cdi.MaChiTietTuyenXe
        JOIN DIEM_DON_TRA ddi ON cdi.MaDiem = ddi.MaDiem
        JOIN CHI_TIET_TUYEN_XE cde ON t.DiemDen = cde.MaChiTietTuyenXe
        JOIN DIEM_DON_TRA dde ON cde.MaDiem = dde.MaDiem
        JOIN CHI_TIET_TUYEN_XE cl ON i.DiemLenXe = cl.MaChiTietTuyenXe
        JOIN DIEM_DON_TRA dl ON cl.MaDiem = dl.MaDiem
        JOIN CHI_TIET_TUYEN_XE cxu ON i.DiemXuongXe = cxu.MaChiTietTuyenXe
        JOIN DIEM_DON_TRA dx ON cxu.MaDiem = dx.MaDiem
        WHERE dl.TinhThanh != ddi.TinhThanh 
           OR dx.TinhThanh != dde.TinhThanh
    )
    BEGIN
        RAISERROR (N'Điểm đón phải ở tỉnh đi, điểm trả phải ở tỉnh đến', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Tính toán bằng TRIGGER
-- Tính toán số ghế trống cho mỗi chuyến xe
CREATE OR ALTER TRIGGER TRG_UpdateSoGheConLai
ON VE_XE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy tất cả MaChuyenXe bị ảnh hưởng
    DECLARE @affected TABLE (MaChuyenXe INT PRIMARY KEY);
    INSERT INTO @affected (MaChuyenXe)
    SELECT DISTINCT MaChuyenXe FROM inserted
    UNION
    SELECT DISTINCT MaChuyenXe FROM deleted;

    UPDATE cx
    SET SoGheConLai = (
        SELECT COUNT(*) FROM GHE g
        WHERE g.MaLoaiXe = (SELECT MaLoaiXe FROM XE x WHERE x.MaXe = cx.MaXe)
    ) - (
        SELECT COUNT(*) FROM VE_XE v
        WHERE v.MaChuyenXe = cx.MaChuyenXe 
          AND v.TrangThai IN (N'Đã bán', N'Đã lấy vé vật lý')
    )
    FROM CHUYEN_XE cx
    INNER JOIN @affected a ON cx.MaChuyenXe = a.MaChuyenXe;
END;
GO


-- Table 12
CREATE TABLE HOA_DON_MUA_VE (
    MaHoaDon INT IDENTITY(1,1) PRIMARY KEY,
    SoDienThoai VARCHAR(15) FOREIGN KEY REFERENCES KHACH_HANG(SoDienThoai) NOT NULL,
    TriGiaHoaDon DECIMAL(18,0) NOT NULL, -- VNĐ
    NgayLapHoaDon DATETIME DEFAULT GETDATE(),
    TrangThai NVARCHAR(20) CHECK ( TrangThai IN (N'Đã thanh toán', N'Đã huỷ')) NOT NULL,
    HinhThucThanhToan NVARCHAR(50) CHECK (HinhThucThanhToan IN (N'Momo', N'ZaloPay', N'Ngân Hàng', N'Tiền mặt')) NOT NULL,
    MaNhanVienBanVe INT FOREIGN KEY REFERENCES NHAN_VIEN(MaNhanVien),
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME
);
GO

-- Table 13
CREATE TABLE CHI_TIET_HOA_DON (
    MaHoaDon INT,
    MaVe VARCHAR(8),
    GiaVeThucTe DECIMAL(18,0) NOT NULL, -- VNĐ
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhatCuoi DATETIME,
    PRIMARY KEY (MaHoaDon, MaVe),
    FOREIGN KEY (MaHoaDon) REFERENCES HOA_DON_MUA_VE(MaHoaDon),
    FOREIGN KEY (MaVe) REFERENCES VE_XE(MaVe)
);
GO

-- Sử dụng TRIGGER để tính giá vé thực tế
-- Có thể mở rộng nếu sau này thêm bảng KHUYEN_MAI
CREATE OR ALTER TRIGGER TRG_UpdateGiaVeThucTe
ON CHI_TIET_HOA_DON
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO CHI_TIET_HOA_DON (MaHoaDon, MaVe, GiaVeThucTe, NgayTao, NgayCapNhatCuoi)
    SELECT 
        i.MaHoaDon,
        i.MaVe,
        c.GiaVeCoBan AS GiaVeThucTe,
        i.NgayTao,
        i.NgayCapNhatCuoi
    FROM inserted i
    JOIN VE_XE v ON i.MaVe = v.MaVe
    JOIN CHUYEN_XE c ON v.MaChuyenXe = c.MaChuyenXe;
END;
GO

-- Mỗi hoá đơn mua vé Online (MaNhanVien is NULL) không được mua quá 5 vé
CREATE OR ALTER TRIGGER TRG_CheckMaxVePerCustomerPerChuyen
ON CHI_TIET_HOA_DON
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ kiểm tra nếu có hóa đơn online nào bị ảnh hưởng
    IF NOT EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HOA_DON_MUA_VE h ON i.MaHoaDon = h.MaHoaDon
        WHERE h.MaNhanVienBanVe IS NULL
          AND h.TrangThai = N'Đã thanh toán'
    )
    BEGIN
        RETURN; -- Không có hóa đơn online → thoát sớm
    END;

    -- Tính tổng số vé online (đã thanh toán) của từng khách hàng trên từng chuyến
    -- Bao gồm cả vé cũ + vé mới từ batch insert này
    WITH TotalVeOnline AS (
        SELECT 
            h.SoDienThoai,
            v.MaChuyenXe,
            COUNT(*) AS SoVe
        FROM CHI_TIET_HOA_DON c
        JOIN HOA_DON_MUA_VE h ON c.MaHoaDon = h.MaHoaDon
        JOIN VE_XE v ON c.MaVe = v.MaVe
        WHERE h.MaNhanVienBanVe IS NULL 
          AND h.TrangThai = N'Đã thanh toán'
        GROUP BY h.SoDienThoai, v.MaChuyenXe
    )
    -- Kiểm tra nếu có bất kỳ khách hàng nào vượt quá 5 vé trên chuyến bị ảnh hưởng
    SELECT 1
    FROM TotalVeOnline t
    WHERE t.SoVe > 5
      AND EXISTS (
          -- Chỉ kiểm tra khách hàng/chuyến bị ảnh hưởng bởi batch insert hiện tại
          SELECT 1
          FROM inserted i
          JOIN HOA_DON_MUA_VE h ON i.MaHoaDon = h.MaHoaDon
          JOIN VE_XE v ON i.MaVe = v.MaVe
          WHERE h.MaNhanVienBanVe IS NULL
            AND h.TrangThai = N'Đã thanh toán'
            AND h.SoDienThoai = t.SoDienThoai
            AND v.MaChuyenXe = t.MaChuyenXe
      );

    IF @@ROWCOUNT > 0
    BEGIN
        RAISERROR (N'Khách hàng không được mua online quá 5 vé trên một chuyến xe', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger tính toán lại trị giá hoá đơn
CREATE OR ALTER TRIGGER TRG_UpdateTriGiaHoaDon
ON CHI_TIET_HOA_DON
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy tất cả MaHoaDon bị ảnh hưởng
    DECLARE @affected TABLE (MaHoaDon INT PRIMARY KEY);
    INSERT INTO @affected (MaHoaDon)
    SELECT DISTINCT MaHoaDon FROM inserted
    UNION
    SELECT DISTINCT MaHoaDon FROM deleted;

    UPDATE h
    SET TriGiaHoaDon = ISNULL((
        SELECT SUM(c.GiaVeThucTe)
        FROM CHI_TIET_HOA_DON c
        WHERE c.MaHoaDon = h.MaHoaDon
    ), 0)
    FROM HOA_DON_MUA_VE h
    INNER JOIN @affected a ON h.MaHoaDon = a.MaHoaDon;
END;
GO

EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL"