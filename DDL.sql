CREATE DATABASE QUAN_LY_VE_XE;
GO

USE QUAN_LY_VE_XE;
GO

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
    TrangThai NVARCHAR(50) CHECK (TrangThai IN (N'Tốt', N'Bảo Trì', N'Ngừng khai thác')) NOT NULL,
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
    Tang NVARCHAR(20) CHECK (Tang IN (N'Tầng trên', N'Tầng dưới')) NOT NULL
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
    DECLARE @MaTuyenXe INT;
    IF EXISTS (SELECT * FROM INSERTED)
        SELECT TOP 1 @MaTuyenXe = MaTuyenXe FROM INSERTED;
    ELSE IF EXISTS (SELECT * FROM DELETED)
        SELECT TOP 1 @MaTuyenXe = MaTuyenXe FROM DELETED;

    DECLARE @StartCount INT = (SELECT COUNT(*) FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemTruoc IS NULL);
    DECLARE @EndCount INT = (SELECT COUNT(*) FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemSau IS NULL);

    IF @StartCount != 1 OR @EndCount != 1
    BEGIN
        RAISERROR (N'Mỗi tuyến xe phải có đúng một điểm xuất phát và một điểm kết thúc', 16, 1);
        ROLLBACK TRANSACTION;
    END

    DECLARE @DiemDi INT = (SELECT MaChiTietTuyenXe FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemTruoc IS NULL);
    DECLARE @DiemDen INT = (SELECT MaChiTietTuyenXe FROM CHI_TIET_TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe AND DiemSau IS NULL);

    DECLARE @TinhDi NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemDi);
    DECLARE @TinhDen NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemDen);

    IF @TinhDi = @TinhDen
    BEGIN
        RAISERROR (N'Điểm xuất phát và điểm kết thúc phải khác tỉnh thành', 16, 1);
        ROLLBACK TRANSACTION;
    END
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
    DECLARE @MaTuyenXe INT;
    IF EXISTS (SELECT * FROM INSERTED)
        SELECT TOP 1 @MaTuyenXe = MaTuyenXe FROM INSERTED;
    ELSE IF EXISTS (SELECT * FROM DELETED)
        SELECT TOP 1 @MaTuyenXe = MaTuyenXe FROM DELETED;

    DECLARE @DiemDi INT = (SELECT DiemDi FROM TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe);
    DECLARE @DiemDen INT = (SELECT DiemDen FROM TUYEN_XE WHERE MaTuyenXe = @MaTuyenXe);

    DECLARE @TinhDi NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemDi);
    DECLARE @TinhDen NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemDen);
    DECLARE @TenTuyenXe NVARCHAR(100) = @TinhDi + N' - ' + @TinhDen;

    DECLARE @TotalMinutes INT = 0;
    DECLARE @Current INT = @DiemDi;

    WHILE @Current IS NOT NULL
    BEGIN
        DECLARE @ThoiGian INT, @Next INT;
        SELECT @ThoiGian = ThoiGianDiChuyenTuDiemTruoc, @Next = DiemSau FROM CHI_TIET_TUYEN_XE WHERE MaChiTietTuyenXe = @Current;
        SET @TotalMinutes = @TotalMinutes + @ThoiGian;
        SET @Current = @Next;
    END

    DECLARE @Hours INT = ROUND(@TotalMinutes / 60.0, 0);

    UPDATE TUYEN_XE SET 
        TenTuyenXe = @TenTuyenXe,
        ThoiGianChayDuKien = @Hours
    WHERE MaTuyenXe = @MaTuyenXe;
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
    TrangThai NVARCHAR(50) CHECK (TrangThai IN (N'Dự kiến', N'Mở bán', N'Kết thúc bán vé', N'Sắp chạy', N'Đang chạy', N'Hoàn thành', N'Huỷ')) NOT NULL,
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
    DECLARE @MaChuyenXe INT, @MaGhe VARCHAR(5), @TrangThai NVARCHAR(50), @MaVe VARCHAR(8);
    SELECT @MaChuyenXe = MaChuyenXe, @MaGhe = MaGhe, @TrangThai = TrangThai, @MaVe = MaVe FROM INSERTED;

    IF @TrangThai IN (N'Đã bán', N'Đã lấy vé vật lý')
    BEGIN
        IF EXISTS (SELECT 1 FROM VE_XE WHERE MaChuyenXe = @MaChuyenXe AND MaGhe = @MaGhe AND TrangThai IN (N'Đã bán', N'Đã lấy vé vật lý') AND MaVe != @MaVe)
        BEGIN
            RAISERROR (N'Ghế đã được bán hoặc lấy vé', 16, 1);
            ROLLBACK TRANSACTION;
        END
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
    DECLARE @MaVe VARCHAR(8) = (SELECT MaVe FROM INSERTED);
    DECLARE @MaChuyenXe INT = (SELECT MaChuyenXe FROM INSERTED);
    DECLARE @DiemLen INT = (SELECT DiemLenXe FROM INSERTED);
    DECLARE @DiemXuong INT = (SELECT DiemXuongXe FROM INSERTED);

    DECLARE @MaTuyenXe INT = (SELECT MaTuyenXe FROM CHUYEN_XE WHERE MaChuyenXe = @MaChuyenXe);
    DECLARE @TinhDi NVARCHAR(50) = (SELECT d.TinhThanh FROM TUYEN_XE t JOIN CHI_TIET_TUYEN_XE c ON t.DiemDi = c.MaChiTietTuyenXe JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE t.MaTuyenXe = @MaTuyenXe);
    DECLARE @TinhDen NVARCHAR(50) = (SELECT d.TinhThanh FROM TUYEN_XE t JOIN CHI_TIET_TUYEN_XE c ON t.DiemDen = c.MaChiTietTuyenXe JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE t.MaTuyenXe = @MaTuyenXe);

    DECLARE @TinhLen NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemLen);
    DECLARE @TinhXuong NVARCHAR(50) = (SELECT d.TinhThanh FROM CHI_TIET_TUYEN_XE c JOIN DIEM_DON_TRA d ON c.MaDiem = d.MaDiem WHERE c.MaChiTietTuyenXe = @DiemXuong);

    IF @TinhLen != @TinhDi OR @TinhXuong != @TinhDen
    BEGIN
        RAISERROR (N'Điểm đón phải ở tỉnh đi, điểm trả phải ở tỉnh đến', 16, 1);
        ROLLBACK TRANSACTION;
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
    DECLARE @MaChuyenXe INT;
    IF EXISTS (SELECT * FROM INSERTED)
        SELECT TOP 1 @MaChuyenXe = MaChuyenXe FROM INSERTED;
    ELSE IF EXISTS (SELECT * FROM DELETED)
        SELECT TOP 1 @MaChuyenXe = MaChuyenXe FROM DELETED;
    DECLARE @TotalGhe INT = (
        SELECT COUNT(*) FROM GHE 
        WHERE MaLoaiXe = (SELECT MaLoaiXe FROM XE WHERE MaXe = (SELECT MaXe FROM CHUYEN_XE WHERE MaChuyenXe = @MaChuyenXe))
    );
    DECLARE @Sold INT = (
        SELECT COUNT(*) FROM VE_XE 
        WHERE MaChuyenXe = @MaChuyenXe AND TrangThai IN (N'Đã bán', N'Đã lấy vé vật lý')
    );
    UPDATE CHUYEN_XE SET SoGheConLai = @TotalGhe - @Sold WHERE MaChuyenXe = @MaChuyenXe;
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
    DECLARE @MaHoaDon INT = (SELECT TOP 1 MaHoaDon FROM INSERTED);
    DECLARE @SoDienThoai VARCHAR(15) = (SELECT SoDienThoai FROM HOA_DON_MUA_VE WHERE MaHoaDon = @MaHoaDon);
    DECLARE @MaNhanVien INT = (SELECT MaNhanVienBanVe FROM HOA_DON_MUA_VE WHERE MaHoaDon = @MaHoaDon);
    IF @MaNhanVien IS NULL
    BEGIN
        DECLARE @MaVe VARCHAR(8) = (SELECT TOP 1 MaVe FROM INSERTED);
        DECLARE @MaChuyenXe INT = (SELECT MaChuyenXe FROM VE_XE WHERE MaVe = @MaVe);
        DECLARE @Count INT = (
            SELECT COUNT(*) FROM CHI_TIET_HOA_DON c 
            JOIN HOA_DON_MUA_VE h ON c.MaHoaDon = h.MaHoaDon 
            JOIN VE_XE v ON c.MaVe = v.MaVe
            WHERE h.SoDienThoai = @SoDienThoai 
            AND v.MaChuyenXe = @MaChuyenXe 
            AND h.MaNhanVienBanVe IS NULL 
            AND h.TrangThai = N'Đã thanh toán'
        );
        IF @Count > 5
        BEGIN
            RAISERROR (N'Khách hàng không được mua quá 5 vé trên một chuyến xe', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
GO

-- Trigger tính toán lịa trị giá hoá đơn
