/* SQL Project Portfolio part 2 using MSSM*/

-- 1. Cleaning data in SQL queries

Select *
from NashvilleHousing

-- 2. Standardize Date format

Select SaleDate --, convert (Date, saleDate)
from NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT (date, saleDate)

Alter Table NashvilleHousing Alter column SaleDate Date

-- 3. Populate property address data for null 

	Select PropertyAddress
	from NashvilleHousing
	where PropertyAddress is null

	--Using selfjoin to verify the data

	Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.propertyAddress, b.PropertyAddress)
	from NashvilleHousing as a
	join NashvilleHousing as b
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

	-- Now update address
Update a
SET PropertyAddress = isnull (a.propertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 4. Breaking out address into individual column (Address, City, State)

	Select PropertyAddress
	from NashvilleHousing
	
--separate by Street and City
	Select SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Ad,
	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
	from NashvilleHousing

--Create 2 new columns and add Address and City

Alter Table NashvilleHousing 
Add Address nvarchar(255); 

Alter Table NashvilleHousing
Add City nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update NashvilleHousing
set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
from NashvilleHousing

--Change owner address to street, city, sate with Parse and Replace

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from NashvilleHousing


Alter Table NashvilleHousing 
Add OwnerSplitAddress nvarchar(255); 

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
from NashvilleHousing


-- 5. change Y and N to Yes and No in "Sold as Vacant" field

Update NashvilleHousing
SET SoldAsVacant = 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
 when SoldAsVacant = 'N' THEN 'No'
 Else SoldAsVacant
 End
 from NashvilleHousing

 Select  Distinct (SoldAsVacant), Count(SoldAsVacant)
 from NashvilleHousing
  Group by SoldAsVacant
 order by Count(SoldAsVacant)

 
-- 6. Remove Duplicates using CTE

With RowNumCTE as (
Select *,
	ROW_NUMBER() over ( 
	partition by ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	order by UniqueID 
	)row_num
from NashvilleHousing
)
Select *
from RowNumCTE
where row_num >1
order by PropertyAddress

--Delete
--from RowNumCTE
--where row_num >1
--order by PropertyAddress



-- 7. Delete unusual columns

Alter Table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
from NashvilleHousing