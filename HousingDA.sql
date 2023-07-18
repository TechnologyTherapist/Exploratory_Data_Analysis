--create database Housing;
use WorkingProject;
Create Database WorkingProject;
select * from sys.tables;

SELECT * 
FROM WorkingProject.dbo.Sheet1$;

-------------------------------------------------------DATA CLEANING PROCESS-----------------------------------------------------
--STANDARDIZE DATE FORMAT
SELECT SaleDate,CONVERT(DATE,SALEDATE)
FROM WorkingProject.dbo.Sheet1$;

UPDATE WorkingProject.dbo.Sheet1$
SET SALEDATE=CONVERT(DATE,SALEDATE)

ALTER TABLE WorkingProject.dbo.Sheet1$
ADD SaleDateConvert DATE;

UPDATE WorkingProject.dbo.Sheet1$
SET SALEDATECONVERT=CONVERT(DATE,SALEDATE)

Select SaleDateConvert From WorkingProject.dbo.Sheet1$;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data
Select PropertyAddress
From WorkingProject.dbo.Sheet1$
Where PropertyAddress is Null;

Select Distinct(PropertyAddress) 
From WorkingProject.dbo.Sheet1$;

Select ParcelId,PropertyAddress 
From WorkingProject.dbo.Sheet1$
Order By ParcelID;

Select d1.ParcelID,d1.PropertyAddress,d2.ParcelID,d2.PropertyAddress, ISNULL(d1.PropertyAddress,d2.PropertyAddress)
From WorkingProject.dbo.Sheet1$ d1
Join WorkingProject.dbo.Sheet1$ d2 
   on d1.ParcelID=d2.ParcelID
   And d1.UniqueID <> d2.UniqueID
Where d1.PropertyAddress is Null;

Update d1
Set PropertyAddress=ISNULL(d1.PropertyAddress,d2.PropertyAddress)
From WorkingProject.dbo.Sheet1$ d1
Join WorkingProject.dbo.Sheet1$ d2 
   on d1.ParcelID=d2.ParcelID
   And d1.UniqueID <> d2.UniqueID
Where d1.PropertyAddress IS NUll;

Select Distinct(PropertyAddress) from WorkingProject.dbo.Sheet1$;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address,City, State)
Select *
From WorkingProject.dbo.Sheet1$;

--Alter Table Working.dbo.Sheet1$
--Drop Column PropertySplitState;

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
From WorkingProject.dbo.Sheet1$;

Alter Table WorkingProject.dbo.Sheet1$
Add PropertySplitAddress Nvarchar(255);

Update WorkingProject.dbo.Sheet1$
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Select PropertySplitAddress
From WorkingProject.dbo.Sheet1$;


Select
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From WorkingProject.dbo.Sheet1$;

Alter Table WorkingProject.dbo.Sheet1$
Add PropertySplitCity Nvarchar(255);

Update WorkingProject.dbo.Sheet1$
Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select PropertySplitCity
From WorkingProject.dbo.Sheet1$;

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From WorkingProject.dbo.Sheet1$;

Alter Table WorkingProject.dbo.Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update WorkingProject.dbo.Sheet1$
Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);

Alter Table WorkingProject.dbo.Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update WorkingProject.dbo.Sheet1$
Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);

Alter Table WorkingProject.dbo.Sheet1$
Add OwnerSplitState Nvarchar(255);

Update WorkingProject.dbo.Sheet1$
Set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select *
From WorkingProject.dbo.Sheet1$;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes And No in "Sold as Vacant" Field

Select *
From WorkingProject.dbo.Sheet1$;

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From WorkingProject.dbo.Sheet1$
Group By SoldAsVacant
Order By 2;

Select SoldAsVacant
,Case When SoldAsVacant='Y' Then 'Yes'
      When SoldAsVacant='N' Then 'No'
	  ELSE SoldAsVacant
	  END
From WorkingProject.dbo.Sheet1$

Update WorkingProject.dbo.Sheet1$
SET SoldAsVacant=Case When SoldAsVacant='Y' Then 'Yes'
      When SoldAsVacant='N' Then 'No'
	  ELSE SoldAsVacant
	  END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicate

WITH RowNumCTE as(
Select *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
   PropertyAddress,
   SalePrice,
   SaleDate,
   LegalReference
   ORDER BY
   UniqueID)row_num
From WorkingProject.dbo.Sheet1$
--ORDER BY ParcelID
)
Select * 
From RowNumCTE
Where row_num>1
ORDER BY PropertyAddress;

WITH RowNumCTE as(
Select *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
   PropertyAddress,
   SalePrice,
   SaleDate,
   LegalReference
   ORDER BY
   UniqueID)row_num
From WorkingProject.dbo.Sheet1$
--ORDER BY ParcelID
)
Delete
From RowNumCTE
Where row_num>1;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select * 
From WorkingProject.dbo.Sheet1$;

Alter Table WorkingProject.dbo.Sheet1$
Drop Column OwnerAddress,TaxDistrict,PropertyAddress;