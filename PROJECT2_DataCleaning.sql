/*Cleaning Data in SQL Queries */

Select * 
From SQL_DataCleaning.dbo.NashvilleHousing

--*Standarize Date format*

Select SaleDate, CONVERT (Date, SaleDate)
From SQL_DataCleaning.dbo.NashvilleHousing


ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
Add SaleDateConverted Date; 

Update SQL_DataCleaning.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT (Date, SaleDate);

Select SaleDateConverted
From SQL_DataCleaning.dbo.NashvilleHousing

---Populate Property Adress Data

SELECT *
FROM SQL_DataCleaning.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQL_DataCleaning.dbo.NashvilleHousing AS a
JOIN SQL_DataCleaning.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQL_DataCleaning.dbo.NashvilleHousing AS a
JOIN SQL_DataCleaning.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Dividir la información de la dirección en diferentes columnas (Dirección, ciudad, estado)

Select PropertyAddress
From SQL_DataCleaning.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM SQL_DataCleaning.dbo.NashvilleHousing


ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar (255);

Update SQL_DataCleaning.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar (255); 

Update SQL_DataCleaning.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM SQL_DataCleaning.dbo.NashvilleHousing

SELECT OwnerAddress
FROM SQL_DataCleaning.dbo.NashvilleHousing

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.'), 1),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)
FROM SQL_DataCleaning.dbo.NashvilleHousing

------------
ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar (255);

Update SQL_DataCleaning.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar (255); 

Update SQL_DataCleaning.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar (255); 

Update SQL_DataCleaning.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)

--Cambiar Y y N a Yes y No en el campo "Sold as Vacant"

SELECT DISTINCT (SoldAsVacant), count (SoldAsVacant)
FROM SQL_DataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM SQL_DataCleaning.dbo.NashvilleHousing
ORDER BY 1

UPDATE SQL_DataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Remover duplicados

WITH RownumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM SQL_DataCleaning.dbo.NashvilleHousing
--ORDER BY ParcelID
)

--DELETE
--FROM RownumCTE
--WHERE row_num > 1

SELECT * 
FROM RownumCTE
WHERE row_num > 1


--- Borrar columnas que no se usan

SELECT *
FROM SQL_DataCleaning.dbo.NashvilleHousing

ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQL_DataCleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate