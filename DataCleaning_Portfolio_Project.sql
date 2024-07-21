-- CLEANING DATA IN SQL 

SELECT *
FROM NashvilleHousing

-- STANDARDIZE DATE FORMAT 
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
	SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
	SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing


-- POPULATING PROPERTY ADDRESS DATA 
SELECT PropertyAddress
FROM NashvilleHousing

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


--SELF JOIN 
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null


-- UPDATING THE TABLE 
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null


-- BREAKING ADDRESS INTO INDIVIDUAL COLUMNS OF ADDRESS, CITY AND STATE 
SELECT PropertyAddress
FROM NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
FROM NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar (255);

UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar (255);


UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing


-- OWNER'S ADDRESS 
SELECT OwnerAddress
FROM NashvilleHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing
--WHERE OwnerAddress IS NOT NULL


ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress Nvarchar (255);

UPDATE NashvilleHousing
	SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity Nvarchar (255);

UPDATE NashvilleHousing
	SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
	ADD OwnerSplitState Nvarchar (255);

UPDATE NashvilleHousing
	SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM NashvilleHousing


--CHANGE Y TO 'Yes' AND N TO 'No' in "SoldAsVacant" field
SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldasVacant = 'N' then 'No'
	 else SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
	SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	                        when SoldasVacant = 'N' then 'No'
	                        else SoldAsVacant
                       END


-- REMOVING DUPLICATES 
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID ) row_num
FROM NashvilleHousing)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID ) row_num
FROM NashvilleHousing)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


-- DELETE UNUSED COLUMNS 
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate