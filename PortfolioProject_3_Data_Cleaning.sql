
--CLEANING DATA IN SQL QUERIES

SELECT
	*
FROM DataCleaning..NashvilleHousing;

--STANDARDIZE DATE FORMAT




ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT
	SaleDateConverted
FROM 
	DataCleaning..NashvilleHousing;

--POPULATE PROPERTY ADRESS DATA

SELECT
	*
FROM
	DataCleaning..NashvilleHousing
WHERE 
	PropertyAddress IS NULL


SELECT
	a.ParcelID,a.PropertyAddress,a2.ParcelID,a2.PropertyAddress
	, ISNULL(a.PropertyAddress,a2.PropertyAddress)
FROM
	DataCleaning..NashvilleHousing a
JOIN DataCleaning..NashvilleHousing a2
	ON a.ParcelID=a2.ParcelID
	AND a.[UniqueID ] <> a2.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL;



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,a2.PropertyAddress)
FROM
	DataCleaning..NashvilleHousing a
JOIN DataCleaning..NashvilleHousing a2
	ON a.ParcelID=a2.ParcelID
	AND a.[UniqueID ] <> a2.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL;


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE)

SELECT
	PropertyAddress
FROM
	DataCleaning..NashvilleHousing;

-- SEARCHED UNTIL THE CHARINDEX VALUE!!!
SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Adress
FROM
	DataCleaning..NashvilleHousing;

--TO GET RID OF SEARCHED VALUE "-1" CAN BE INSERTED!!! 

SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Adress
FROM
	DataCleaning..NashvilleHousing;

--BY USING THIS QUERY, VALUES ARE SEPERATED AS EXPECTED
SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Adress
FROM
	DataCleaning..NashvilleHousing;

ALTER TABLE DataCleaning..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE DataCleaning..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

UPDATE DataCleaning..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

SELECT
	*
FROM 
	DataCleaning..NashvilleHousing;

--TO DIVIDE DATA, PARSENAME() IS USED THIS TIME!!! 

SELECT
	OwnerAddress
FROM 
	DataCleaning..NashvilleHousing;

SELECT
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS ADRESS, --PARSENAME() IS ONLY USEFUL WITH PERIODS SO WE NEED TO REPLACE IT
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS CITY, --IT PARSE THE NAME WITH STARTING AT THE END OF THE STRING
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS STATE	
FROM 
	DataCleaning..NashvilleHousing;

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


--CHANGE Y AND N TO YES ADN NO IN "SOLID AS VACANT" FIELD


SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant) AS Count
FROM 
	DataCleaning..NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	2 ASC;

SELECT
	SoldAsVacant,
	CASE 
	WHEN SoldAsVacant ='Y' Then 'Yes'
	WHEN SoldAsVacant='N' Then 'No'
	ELSE SoldAsVacant 
	END as UpdatedStatement
FROM 
	DataCleaning..NashvilleHousing

--UPDATING OUR VALUES

UPDATE DataCleaning..NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant ='Y' Then 'Yes'
	WHEN SoldAsVacant='N' Then 'No'
	ELSE SoldAsVacant 
	END;

--REMOVING DUPLICATES(IT IS NOT COMMONLY DONE TO RAW DATA)
--TO FIND DUPLICATES QUERY BELOW CAN BE USED
--TO APPLY WHERE CONDITION CTE MUST BE USED BECAUSE WHERE CONDITION
--CAN NOT BE APPLIED IN WINDOW FUNCTIONS 

WITH RowNumCTE AS (
SELECT
	*,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelId,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
					UniqueID) row_num
FROM
	DataCleaning..NashvilleHousing
)

--DELETING THE DUPLICATES
DELETE
	
FROM	
	RowNumCTE
WHERE
	row_num > 1;

/*SELECT
	*
FROM
	RowNumCTE
WHERE 
	row_num >1 ;
*/


--DELETING UNUSED COLUMNS

SELECT
	*
FROM
	DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

