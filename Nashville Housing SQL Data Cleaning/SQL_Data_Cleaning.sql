/*
	
	Nashville Housing Data Cleaning Queries

*/


/*Cleaning SaleDate; to show date only instead of date and time*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVSTION AND SOLUTION --
SELECT SaleDate FROM NashvilleHousing..NashvilleHouseData

-- REFORMAT COLUMN --
ALTER TABLE NashvilleHousing..NashvilleHouseData
ALTER COLUMN SaleDate DATE


/*Populating empty property address feilds*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVSTION AND SOLUTION --
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NashvilleHouseData a
JOIN NashvilleHousing..NashvilleHouseData b
	ON a.ParcelID = b.ParcelID
	AND b.[UniqueID ] <> a.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- POPUALTING FIELDS --
UPDATE a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NashvilleHouseData a
JOIN NashvilleHousing..NashvilleHouseData b
	ON a.ParcelID = b.ParcelID
	AND b.[UniqueID ] <> a.[UniqueID ]
WHERE a.PropertyAddress IS NULL


/*Organizing different sections of the Property Address into differnt columns*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVSTION AND SOLUTION --
SELECT SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)-1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM NashvilleHousing..NashvilleHouseData

-- ADDING COLUMNS
ALTER TABLE NashvilleHousing..NashvilleHouseData
ADD PropertyAddressLine VARCHAR(255);
ALTER TABLE NashvilleHousing..NashvilleHouseData
ADD PropertyAddressCity VARCHAR(255);

-- POPULATION THE COLUMNS --
UPDATE NashvilleHousing..NashvilleHouseData
SET PropertyAddressLine = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)-1)
UPDATE NashvilleHousing..NashvilleHouseData
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



/*Organizing different sections of the Owner's Address into differnt columns*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVSTION AND SOLUTION --
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing..NashvilleHouseData

-- POPULATION --
-- Adding Owner's Address, City, and State Columns to table --
ALTER TABLE NashvilleHousing..NashvilleHouseData
ADD OwnerAddressLine VARCHAR(255);
ALTER TABLE NashvilleHousing..NashvilleHouseData
ADD OwnerAddressCity VARCHAR(255);
ALTER TABLE NashvilleHousing..NashvilleHouseData
ADD OwnerAddressState VARCHAR(255);

-- Updating the new columns --
UPDATE NashvilleHousing..NashvilleHouseData
SET OwnerAddressLine = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
UPDATE NashvilleHousing..NashvilleHouseData
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE NashvilleHousing..NashvilleHouseData
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



/*Change Y and N to Yes and No in 'Sold as Vacant*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVATION --
SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM NashvilleHousing..NashvilleHouseData
GROUP BY SoldAsVacant
ORDER BY 2

-- SOLUTION --
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing..NashvilleHouseData

-- POPULATION --
UPDATE NashvilleHousing..NashvilleHouseData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END


/*Change Y and N to Yes and No in 'Sold as Vacant*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVATION --
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing..NashvilleHouseData
ORDER BY ParcelID

-- SOLUTION --
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing..NashvilleHouseData
--ORDER BY ParcelID
--WHERE row_num > 1
) SELECT * FROM RowNumCTE
	WHERE row_num > 1
	ORDER BY PropertyAddress

-- REMOVING THE DUPLICATES --
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing..NashvilleHouseData
--ORDER BY ParcelID
--WHERE row_num > 1
) DELETE FROM RowNumCTE
	WHERE row_num > 1


/*Removing unused or redundant columns*/
-------------------------------------------------------------------------------------------------------------------------------
-- OBSERVATION --
SELECT * FROM NashvilleHousing..NashvilleHouseData

-- REMOVING COLUMNS
ALTER TABLE NashvilleHousing..NashvilleHouseData
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict
