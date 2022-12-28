select *
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------

----Standardize date format


select SaleDate
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted=convert(date, SaleDate)


--------------------------------------------------------------------------------------

----Populate Property Address data

select PropertyAddress
from PortfolioProject..NashvilleHousing

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select ParcelID, PropertyAddress
from PortfolioProject..NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------

----Breaking out Address into individual columns( address,city,sate)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address1,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address2
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress));

select PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=parsename(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=parsename(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------

----Change Y And N to Yes and No in "SoldAsVacant" column

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

select distinct(SoldAsVacant)
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------

----Remove Duplicates

with RowNumCTE as(
select *,
      row_number() over (
     partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by UniqueID
				  ) as row_num
from PortfolioProject..NashvilleHousing
)
delete---------then deleting
from RowNumCTE
where row_num > 1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------

----Deleting Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress