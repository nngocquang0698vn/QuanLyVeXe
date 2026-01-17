------
-- Rang buoc: Moi Tuyen Xe chi co mot diem xuat phat va mot diem ket thuc


-- Test case 01:
-- 'Điểm xuất phát và điểm kết thúc phải khác tỉnh thành'
UPDATE CHI_TIET_TUYEN_XE
SET MaDiem = 1 -- tp.hcm 
WHERE MaChiTietTuyenXe = 11 -- doi diem den tu da lat sang tp. hcm

--Msg 50000, Level 16, State 1, Procedure TRG_CheckTuyenXeStartEnd, Line 29 [Batch Start Line 375]
--Điểm xuất phát và điểm kết thúc phải khác tỉnh thành
--Msg 3609, Level 16, State 1, Line 376
--The transaction ended in the trigger. The batch has been aborted.

-- Test case 02:
-- Vi pham rang buoc: mot tuyen xe chi co 1 diem bat dau va 1 diem ket thuc
UPDATE CHI_TIET_TUYEN_XE
SET DiemTruoc = NULL 
WHERE MaChiTietTuyenXe = 5 -- day la diem giua

--Msg 50000, Level 16, State 1, Procedure TRG_CheckTuyenXeStartEnd, Line 17 [Batch Start Line 386]
--Mỗi tuyến xe phải có đúng một điểm xuất phát và một điểm kết thúc
--Msg 3609, Level 16, State 1, Line 387
--The transaction ended in the trigger. The batch has been aborted.
------
--
