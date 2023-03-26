select "PropertyAddress"
FROM "NashvilleHousing"
-- WHERE "PropertyAddress" IS NULL

---- Populate Property Address data
--using parcelID, fill the NULL values in propertyaddress
SELECT a."UniqueID", a."ParcelID", a."PropertyAddress", b."UniqueID", b."ParcelID", b."PropertyAddress"
,COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM "NashvilleHousing" AS a JOIN "NashvilleHousing" AS b
ON a."ParcelID" = b."ParcelID" AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL
-- ORDER BY "ParcelID"

--updates the value of NULL values in the propertyaddress using the property address where parcelID is same
UPDATE "NashvilleHousing"
SET "PropertyAddress" = COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM "NashvilleHousing" AS a JOIN "NashvilleHousing" AS b
ON a."ParcelID" = b."ParcelID" AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT  "PropertyAddress"
FROM "NashvilleHousing"

SELECT "PropertyAddress",
SUBSTRING("PropertyAddress", 1, strpos("PropertyAddress", ',') -1 ) as Address
, SUBSTRING("PropertyAddress", strpos("PropertyAddress", ',') + 1 , LENGTH("PropertyAddress")) as Address
FROM "NashvilleHousing"

ALTER TABLE "NashvilleHousing"
Add "PropertySplitAddress" character varying(255)

Update "NashvilleHousing"
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, strpos("PropertyAddress", ',') -1 )

ALTER TABLE "NashvilleHousing"
Add "PropertySplitCity" character varying(255)

Update "NashvilleHousing"
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", strpos("PropertyAddress", ',') + 1 , LENGTH("PropertyAddress"))

SELECT *
FROM "NashvilleHousing"

select "OwnerAddress"
FROM "NashvilleHousing"

SELECT 
split_part(REPLACE("OwnerAddress", ',', '.') , '.', 1)
,split_part(REPLACE("OwnerAddress", ',', '.') , '.', 2)
,split_part(REPLACE("OwnerAddress", ',', '.') , '.', 3)
FROM "NashvilleHousing"


ALTER TABLE "NashvilleHousing"
Add "OwnerSplitAddress" character varying(255)

Update "NashvilleHousing"
SET "OwnerSplitAddress" = split_part(REPLACE("OwnerAddress", ',', '.') , '.', 1)

ALTER TABLE "NashvilleHousing"
Add "OwnerSplitCity" character varying(255)

Update "NashvilleHousing"
SET "OwnerSplitCity" = split_part(REPLACE("OwnerAddress", ',', '.') , '.', 2)

ALTER TABLE "NashvilleHousing"
Add "OwnerSplitState" character varying(255)

Update "NashvilleHousing"
SET "OwnerSplitState" = split_part(REPLACE("OwnerAddress", ',', '.') , '.', 3)

Select *
FROM "NashvilleHousing"

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct("SoldAsVacant"), Count("SoldAsVacant")
FROM "NashvilleHousing"
Group by "SoldAsVacant"
order by 2

SELECT "SoldAsVacant",
CASE "SoldAsVacant"
WHEN 'N' THEN 'No'
WHEN 'Y' THEN 'Yes'
ELSE "SoldAsVacant"
END AS updated_SoldAsVacant
FROM "NashvilleHousing"


Update "NashvilleHousing"
SET "SoldAsVacant" = CASE "SoldAsVacant" 
					 WHEN 'N' THEN 'No'
					 WHEN 'Y' THEN 'Yes'
					 ELSE "SoldAsVacant"
					 END
					 
-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SalePrice",
				 "SaleDate",
				 "LegalReference"
				 ORDER BY
					"UniqueID"
					) row_num

FROM "NashvilleHousing"
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by "PropertyAddress"

Select *
FROM "NashvilleHousing"


-- Delete Unused Columns
-- Select *
-- FROM "NashvilleHousing"


-- ALTER TABLE "NashvilleHousing"
-- DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
