SELECT  *
from dbo.Nashville_house


----------------------------------------------------------------------------------------------------------------------------------------
-- NULL PropertyAddress 

---- each parcelID corresponds to one and only one PropertyAddress
---- some PropertyAddress are NULL but we can easly find them by looking up the corresponding parcelID 
----  joinned the table with itself to basically copy the PropertyAddress from "nash_2.PropertyAddress" 
 

UPDATE nash_1 
SET PropertyAddress = ISNULL(nash_1.PropertyAddress,nash_2.PropertyAddress)
from dbo.Nashville_house nash_1
JOIN dbo.Nashville_house nash_2
    ON nash_1.ParcelID = nash_2.ParcelID
        AND nash_1.UniqueID <> nash_2.UniqueID 
WHERE nash_1.PropertyAddress IS NULL  




----------------------------------------------------------------------------------------------------------------------------------------

-- Breaking down Property addresses into individual columns 



SELECT  
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Street, -- start at first letter until ','
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City -- start at ',' until last letter 
from dbo.Nashville_house

---- updating the table 

------ adding street 

ALTER TABLE dbo.Nashville_house
ADD Street NVARCHAR(255);

UPDATE dbo.Nashville_house
SET Street = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) -- start at first letter until ','

------ adding city 

ALTER TABLE dbo.Nashville_house
ADD City NVARCHAR(255);

UPDATE dbo.Nashville_house
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

------ Deleting PropertyAddress since we don't need it anymore 

ALTER TABLE dbo.Nashville_house
DROP COLUMN PropertyAddress


----------------------------------------------------------------------------------------------------------------------------------------

-- Breaking down Owner addresses into individual columns (using PARSENAME)

SELECT
PARSENAME(replace(OwnerAddress,',','.'),1)AS OwnerAddress_state,-- replaced ',' with '.' because PARSENAME only works with '.'
PARSENAME(replace(OwnerAddress,',','.'),2)AS OwnerAddress_City,
PARSENAME(replace(OwnerAddress,',','.'),3) AS OwnerAddress_street

FROM dbo.Nashville_house

---- updating the table 

------ adding OwnerAddress_state
ALTER TABLE dbo.Nashville_house
ADD OwnerAddress_state VARCHAR(255);

UPDATE dbo.Nashville_house
SET OwnerAddress_state = PARSENAME(replace(OwnerAddress,',','.'),1)

------ adding OwnerAddress_City
ALTER TABLE dbo.Nashville_house
ADD OwnerAddress_City VARCHAR(255);

UPDATE dbo.Nashville_house
SET OwnerAddress_City = PARSENAME(replace(OwnerAddress,',','.'),2)

------ adding OwnerAddress_street
ALTER TABLE dbo.Nashville_house
ADD OwnerAddress_street VARCHAR(255);

UPDATE dbo.Nashville_house
SET OwnerAddress_street = PARSENAME(replace(OwnerAddress,',','.'),3)

------ Deleting OwnerAddress since we don't it need anymore 

ALTER TABLE dbo.Nashville_house
DROP COLUMN OwnerAddress

----------------------------------------------------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No.

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM dbo.Nashville_house
GROUP BY SoldAsVacant
------
SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
    WHEN SoldAsVacant LIKE 'N' THEN 'No'
    ELSE SoldAsVacant
    END AS Sold
FROM dbo.Nashville_house

WHERE SoldAsVacant LIKE 'Y' OR SoldAsVacant LIKE 'N'

---- updating the table 

UPDATE dbo.Nashville_house

SET SoldAsVacant = CASE
    WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
    WHEN SoldAsVacant LIKE 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM dbo.Nashville_house


----------------------------------------------------------------------------------------------------------------------------------------

-- Removing duplicates
----- we first need to detect these row that are the same. 
--------I used a CTE to see the duplicates 

WITH CTE_duplicates AS (
SELECT *, ROW_NUMBER() OVER( PARTITION BY ParcelID, 
                                        SaleDate,
                                        SalePrice,
                                        LegalReference
                                ORDER BY UniqueID ) AS row_num -- all rows with row_num 1 will be unique, everything else is a duplicate. 
FROM dbo.Nashville_house)

-- SELECT * 
-- FROM CTE_duplicates
-- WHERE row_num > 1 -- Double checking before deleting 

------ Delete the duplicates 

DELETE 
FROM CTE_duplicates
WHERE row_num > 1

----------------------------------------------------------------------------------------------------------------------------------------


