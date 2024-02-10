SELECT *
FROM NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize data format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


------------------------------------------------------------------------------------------------------------------------------------------------

-- Property Address Distinguished

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID



SELECT nh1.[UniqueID ], nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL (nh1.PropertyAddress, nh2.PropertyAddress)
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
	ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
--WHERE nh1.PropertyAddress is null
ORDER BY nh1.ParcelID


UPDATE nh1
SET PropertyAddress = ISNULL (nh1.PropertyAddress, nh2.PropertyAddress)
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
	ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress is null






------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking address into separate columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress
	 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Adress
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Varchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Varchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing


--Breaking down OwnerAddress into separate addresses, Cities and States comulmns

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
	   PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM NashvilleHousing
--WHERE OwnerAddress is not null
ORDER BY OwnerAddress desc


------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing NashvilleHousing table to have addresses, Cities and States comulmns of the owner

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Varchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Varchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Varchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


SELECT *
FROM NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Finding what values are in the "Sold as Vacant" field and how many of them
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END



-------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates (using different method, because "UniqueID" field is not taken as unique value)

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(Partition BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
					  Order BY UniqueID) AS row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)


SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress






-------------------------------------------------------------------------------------------------------------------------------

-- Deleting unused Columns (OwnerAddress, TaxDistrict, PropertyAddress)

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate