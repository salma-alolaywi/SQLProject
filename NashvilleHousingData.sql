select * from [Nashville Housing Data for Data Cleaning].dbo.house;
--------------------------------------
Alter Table [Nashville Housing Data for Data Cleaning].dbo.house
set 'SaleDate' date;

-------------
select convert(date,SaleDate)
from[Nashville Housing Data for Data Cleaning].dbo.house;
------------------------------
select a.propertyaddress ,a.ParcelID ,  b.propertyaddress ,b.ParcelID , ISNULL(a.propertyaddress,B.propertyaddress) 
from[Nashville Housing Data for Data Cleaning].dbo.house A
JOIN [Nashville Housing Data for Data Cleaning].dbo.house b
on a.ParcelID=b.ParcelID
AND A.UniqueId<>b.uniqueId
WHERE a.propertyaddress is null
----------------------
update a
set propertyaddress=ISNULL(a.propertyaddress,B.propertyaddress)
from[Nashville Housing Data for Data Cleaning].dbo.house A
JOIN [Nashville Housing Data for Data Cleaning].dbo.house b
on a.ParcelID=b.ParcelID
AND A.UniqueId<>b.uniqueId
WHERE a.propertyaddress is null
---------------------
--breaking out addres into  address,city,state
select SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) as address2

from[Nashville Housing Data for Data Cleaning].dbo.house 
-----------------
ALTER TABLE [Nashville Housing Data for Data Cleaning].dbo.house
ADD propertySPLITaddress NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning].dbo.house
SET propertySPLITaddress  =SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

ALTER TABLE [Nashville Housing Data for Data Cleaning].dbo.house
ADD PROPERTYSPLITCITY NVARCHAR(255);
UPDATE[Nashville Housing Data for Data Cleaning].dbo.house
SET PROPERTYSPLITCITY =SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) 
-----------------------------

select OWNERADDRESS
from [Nashville Housing Data for Data Cleaning].dbo.house;
--------------------------------------------------------------
SELECT OWNERADDRESS, PARSENAME(REPLACE(OWNERADDRESS,',','.'),3),
PARSENAME(REPLACE(OWNERADDRESS,',','.'),2),
PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)
from [Nashville Housing Data for Data Cleaning].dbo.house;


ALTER TABLE [Nashville Housing Data for Data Cleaning].dbo.house
ADD OWNERADDRESSSPLITaddress NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning].dbo.house
SET OWNERADDRESSSPLITaddress  =PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)

ALTER TABLE [Nashville Housing Data for Data Cleaning].dbo.house
ADD OWNERADDRESSSPLITCITY NVARCHAR(255);
UPDATE[Nashville Housing Data for Data Cleaning].dbo.house
SET OWNERADDRESSSPLITCITY =PARSENAME(REPLACE(OWNERADDRESS,',','.'),2)

ALTER TABLE [Nashville Housing Data for Data Cleaning].dbo.house
ADD OWNERADDRESSSPLITSTAT NVARCHAR(255);
UPDATE[Nashville Housing Data for Data Cleaning].dbo.house
SET OWNERADDRESSSPLITSTAT =PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)

---------------------------
--CHANGE Y AND N TO YEA AND NO IN VACANT FIELD
SELECT distinct(SOLDASVACANT)
from [Nashville Housing Data for Data Cleaning].dbo.house;

select SOLDASVACANT,
CASE when SOLDASVACANT='N' THEN 'NO'
     WHEN SOLDASVACANT='Y' THEN 'YES'
ELSE SOLDASVACANT
END
from [Nashville Housing Data for Data Cleaning].dbo.house;
UPDATE[Nashville Housing Data for Data Cleaning].dbo.house
SET SOLDASVACANT =CASE when SOLDASVACANT='N' THEN 'NO'
     WHEN SOLDASVACANT='Y' THEN 'YES'
ELSE SOLDASVACANT
END

SELECT DISTINCT(SOLDASVACANT),COUNT(SOLDASVACANT)
FROM [Nashville Housing Data for Data Cleaning].dbo.house
group BY SOLDASVACANT
ORDER BY 2
----------------------------------------------------
--remove duplicate:
with rownumcte as(
select *, ROW_NUMBER() over(
PARTITION by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueId) row_num
FROM [Nashville Housing Data for Data Cleaning].dbo.house
)
select * 
from rownumcte
where row_num>1
order by PropertyAddress
-----------------------------------
--delete unused colmun
SELECT *
from [Nashville Housing Data for Data Cleaning].dbo.house;

Alter table [Nashville Housing Data for Data Cleaning].dbo.house
drop column OwnerAddress,TaxDistrict;
            




