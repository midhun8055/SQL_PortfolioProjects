USE PORTFOLIOPROJECT_2
select * from housing


-- standardising the date format

select saledate as original, CONVERT(DATE,saledate) as reformated from housing

update housing
set SaleDate = CONVERT(date,SaleDate)

ALTER TABLE housing
ADD date_reformated date;
update housing
set date_reformated = CONVERT(date,SaleDate)


-- Populate property address data

select b.PropertyAddress, a.PropertyAddress ,a.ParcelID 
from 
housing a join housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.propertyaddress = b.propertyaddress    -- (set propertyaddress = isnull (a.propertyaddress,b.propertyaddress))
from
housing a join housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into individual columns (Address, city, State)

select 
substring (PropertyAddress, 1, CHARINDEX (',',PropertyAddress) - 1) as Address  
,substring (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN(propertyaddress)) as city
from housing

alter table housing
add prop_split_address nvarchar (255)

update housing
set prop_split_address = substring (PropertyAddress, 1, CHARINDEX (',',PropertyAddress) - 1)

alter table housing
add prop_split_city nvarchar (255)

update housing
set prop_split_city = substring (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN(propertyaddress))



-- Looking at the Owner address

select 
PARSENAME(REPLACE(owneraddress,',','.'),3) as address
,PARSENAME(REPLACE(owneraddress,',','.'),2) as city
,PARSENAME(REPLACE(owneraddress,',','.'),1) as state
from housing

alter table housing
add M_owneraddress nvarchar(255);

go

update housing
set M_owneraddress = PARSENAME(REPLACE(owneraddress,',','.'),3);

go

alter table housing
add M_ownercity nvarchar(255);

go

update housing
set M_ownercity = PARSENAME(REPLACE(owneraddress,',','.'),2);

go

alter table housing
add M_ownerstate nvarchar(255);

go

update housing
set M_ownerstate = PARSENAME(REPLACE(owneraddress,',','.'),1);


go

-- change Y and N to Yes and No in "Sold as Vacant" field

select distinct soldasvacant from housing 

update housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					end


--Removing duplicates

-- finding the dupliactes (ones with the row_num > 1)

select *, 
	ROW_NUMBER() over (
	partition by Parcelid,
				 propertyaddress,
				 saleprice,
				 legalreference
				 order by uniqueid
	) row_num

from housing

-- putting this in to a CTE

with duplicte as (
select *, 
	ROW_NUMBER() over (
	partition by Parcelid,
				 propertyaddress,
				 saleprice,
				 legalreference
				 order by uniqueid
	) row_num

from housing
)	
delete from duplicte
where row_num > 1




-- Deleting unused columns

alter table housing
drop column owneraddress, propertyaddress, taxdistrict

select * from housing



















 

