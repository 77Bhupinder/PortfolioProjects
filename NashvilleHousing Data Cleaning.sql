/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
From PortfolioProject..NashvilleHousing

--Standardize Date Format

Select SaleDate , CONVERT(date,SaleDate)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = convert(date,SaleDate)

--Populate Property Address Data


Select * 
From PortfolioProject..NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



Update a
set PropertyAddress = ISNULL( a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address,City,State)


Select PropertyAddress
From PortfolioProject..NashvilleHousing
order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)



Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing



select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);


Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "SoldAsVacant"

select Distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,Case when SoldAsVacant = 'Y' then 'Yes'
						 when SoldAsVacant = 'N' then 'No'
						 Else SoldAsVacant
						 End
from NashvilleHousing


Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
						 when SoldAsVacant = 'N' then 'No'
						 Else SoldAsVacant
						 End



						 ---------------------------------------------------------------------------------------------------------------
--Remove Duplicates


With RowNumCTE as(
Select *,ROW_NUMBER() over(
Partition by ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
			 order by UniqueID) as row_num

From PortfolioProject..NashvilleHousing)

select*
From RowNumCTE
Where row_num > 1



---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict