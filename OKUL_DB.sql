USE [master]
GO
/****** Object:  Database [Okul]    Script Date: 7.08.2022 17:06:11 ******/
CREATE DATABASE [Okul]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Okul', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Okul.mdf' , SIZE = 4288KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Okul_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Okul_log.ldf' , SIZE = 1072KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Okul] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Okul].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Okul] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Okul] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Okul] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Okul] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Okul] SET ARITHABORT OFF 
GO
ALTER DATABASE [Okul] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Okul] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Okul] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Okul] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Okul] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Okul] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Okul] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Okul] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Okul] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Okul] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Okul] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Okul] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Okul] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Okul] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Okul] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Okul] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Okul] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Okul] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Okul] SET  MULTI_USER 
GO
ALTER DATABASE [Okul] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Okul] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Okul] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Okul] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [Okul] SET DELAYED_DURABILITY = DISABLED 
GO
USE [Okul]
GO
/****** Object:  UserDefinedFunction [dbo].[DonemNotOrtalamasi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[DonemNotOrtalamasi](@Ogrenci_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc  int
set @sonuc= (select a.DonemNotOrtalamasi
from

(select o.Id as Ogrenci_Id, 
og.Donem_Id , (([dbo].[FN$IlgiliDonemdekiOgrencininSayiDegerleriToplami](@Donem_Id,@Ogrenci_Id)) /(dbo.FN$OgrencininAldigiToplamKrediSayisi(@Ogrenci_Id,@Donem_Id)))
 as DonemNotOrtalamasi
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id and og.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by  o.Id,
          og.Donem_Id 
       	     
) A
)
 return @sonuc
 end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$IlgiliDonemdekiOgrencininAldigiDersinSayiDegeri]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$IlgiliDonemdekiOgrencininAldigiDersinSayiDegeri] 
(
 @Ogrenci_Id int,
 @Ders_Id int,
 @Donem_Id int
)
RETURNS tinyint
AS 
    BEGIN
	 declare @HarfNotu char(2),
	         @Ortalama decimal(18,2),
			 @KrediSayisi tinyint,
			 @HarfNotununSayiDegeri tinyint,
			 @DersinSayiDegeri tinyint

 select @Ortalama = ood.Vize*0.4+ood.Final*0.6,
        @KrediSayisi = d.KrediSayisi
 from dbo.[OgrenciOgretmenDers] as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 inner join dbo.Ders as d on d.Id = od.Ders_Id and d.Statu = 1
 where ood.Statu = 1
 and ood.Ogrenci_Id = @Ogrenci_Id
 and od.Ders_Id  =@Ders_Id
 and od.Donem_Id = @Donem_Id

 set @Ortalama = ROUND(@Ortalama,0)

 SET @HarfNotu = (SELECT 
       case when @Ortalama between 93 and 100 then  'AA'
	        when @Ortalama between 85 and 92  then  'BA'
	        when @Ortalama between 76 and 84  then  'BB'
	        when @Ortalama between 66 and 75  then  'CB'
			when @Ortalama between 46 and 65  then  'CC'
			when @Ortalama between 31 and 45  then  'DC'
			when @Ortalama between 15 and 30  then  'DD'
	   else 'FF' end )

SET @HarfNotununSayiDegeri = (SELECT 
       case when @HarfNotu='AA' then  4
	        when @HarfNotu='BA' then  3.5
	        when @HarfNotu='BB' then  3
	        when @HarfNotu='CB' then  2.5
			when @HarfNotu='CC' then  2
			when @HarfNotu='DC' then  1.5
			when @HarfNotu='DD' then  1
	   else 0 end)

SELECT @DersinSayiDegeri = @HarfNotununSayiDegeri*@KrediSayisi 

	 return @DersinSayiDegeri

	 end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$IlgiliDonemdekiOgrencininDersHarfNotu]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--1-)girdiler -> öğrenci,ders,donem
--çıktılar --> sadece harf notu

--select [dbo].[FN$IlgiliDonemdekiOgrencininDersHarfNotu](2,5,1)

CREATE FUNCTION [dbo].[FN$IlgiliDonemdekiOgrencininDersHarfNotu] 
(
 @Ogrenci_Id int,
 @Ders_Id int,
 @Donem_Id int
)
RETURNS CHAR(2)
AS 
    BEGIN
	 declare @HarfNotu char(2) ,
	         @Ortalama tinyint

 select @Ortalama = ood.Vize*0.4+ood.Final*0.6
 from dbo.[OgrenciOgretmenDers] as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 where ood.Statu = 1
 and ood.Ogrenci_Id = @Ogrenci_Id
 and od.Ders_Id  =@Ders_Id
 and od.Donem_Id = @Donem_Id


 SET @HarfNotu = (SELECT 
       case when @Ortalama between 93 and 100 then  'AA'
	        when @Ortalama between 85 and 92  then  'BA'
	        when @Ortalama between 76 and 84  then  'BB'
	        when @Ortalama between 66 and 75  then  'CB'
			when @Ortalama between 46 and 65  then  'CC'
			when @Ortalama between 31 and 45  then  'DC'
			when @Ortalama between 15 and 30  then  'DD'
	   else 'FF' end )

	 return @HarfNotu

    END

 -- select ood.Vize as vize,
 --        ood.Final as final,
 --        ood.Vize*0.4 vize_40,
 --        ood.Final*0.6 final_60,
	--	 ood.Vize*0.4+ood.Final*0.6 as ort
 --from dbo.[OgrenciOgretmenDers] as ood
 --inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 --where ood.Statu = 1
 --and ood.Ogrenci_Id = @Ogrenci_Id
 --and od.Ders_Id  =@Ders_Id
 --and od.Donem_Id = @Donem_Id
GO
/****** Object:  UserDefinedFunction [dbo].[FN$IlgiliDonemdekiOgrencininSayiDegerleriToplami]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FN$IlgiliDonemdekiOgrencininSayiDegerleriToplami] 
(
 @Donem_Id int,
 @Ogrenci_Id int
 )
returns int
as
begin
declare @sonuc as int

set  @sonuc = 
(select SUM(a.DersinSayiDegeri) 
from (
       select ood.Ogrenci_Id,
              od.Donem_Id,
       	   d.Id as Ders_Id,
       	   dbo.FN$IlgiliDonemdekiOgrencininAldigiDersinSayiDegeri(@Ogrenci_Id,d.Id,@Donem_Id) as DersinSayiDegeri
       from dbo.OgrenciOgretmenDers as ood 
       inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
       inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
       inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
       inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
       where 
       ood.Statu=1
       and do.Id = @Donem_Id
       and ood.Ogrenci_Id=@Ogrenci_Id
       group by  ood.Ogrenci_Id,
                 od.Donem_Id,
       	      d.Id
) A
)


return @sonuc
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$IlgiliDonemdekiOgretmeneAitDersOrtalamasi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FN$IlgiliDonemdekiOgretmeneAitDersOrtalamasi]
 (
 @Donem_Id int,
 @Ogretmen_Id int,
 @Ders_Id int)

 returns char(2)
as
begin
      declare 

              @HarfNotu char(2),
	          @Ortalama tinyint,
			  @sonuc tinyint

	set @sonuc=	(select (sum(a.Ortalama)/count(*)) as 'not ortalaması'  from
	(select od.Ogretmen_Id,
	od.Donem_Id,
	   de.Id as Ders_Id,

	   ood.Vize*0.4+ood.Final*0.6 as Ortalama
	   from dbo.OgrenciOgretmenDers as ood 
	   inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
	   inner join dbo.Ogretmen as o on o.Id=od.Ogretmen_Id and o.Statu=1
	   inner join dbo.Donem as d on d.Id=od.Donem_Id and d.Statu=1
	   inner join dbo.Ders as de on de.Id=od.Ders_Id and de.Statu=1
	   where ood.Statu=1
	   and d.Id =@Donem_Id
       and od.Ogretmen_Id=@Ogretmen_Id
       and od.Ders_Id= @Ders_Id 
	   group by od.Ogretmen_Id,od.Donem_Id,de.Id,ood.Vize,ood.Final)
	   a

	   )
	



	return @sonuc
	end

GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgrencininAldigiDersSayisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OgrencininAldigiDersSayisi](@Ogrenci_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc as int


set  @sonuc = (select  count(*) 
from
(select o.Id as Ogrenci_Id, o.Adi+' '+o.SoyAdi as adisoyadi, 
Ders_Id,do.Adi as dönemadi
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id
inner join dbo.Ders as d on d.Id=og.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by o.Id,og.Ders_Id,o.Adi,o.SoyAdi,do.Adi
)B
group by b.Ogrenci_Id)

return @sonuc
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgrencininAldigiHocaSayisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN$OgrencininAldigiHocaSayisi](@Ogrenci_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc as int


set  @sonuc = (select  count(*) 
from

(select o.Id as Ogrenci_Id, o.Adi+' '+o.SoyAdi as adisoyadi, 
og.Ogretmen_Id,do.Adi as dönemadi
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id
inner join dbo.Ders as d on d.Id=og.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
inner join dbo.Ogretmen as ogt on ogt.Id=og.Ogretmen_Id and ogt.Statu=1
where ood.Statu=1
and og.Donem_Id = 1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by o.Id,og.Ogretmen_Id,o.Adi,o.SoyAdi,do.Adi
)B
group by b.Ogrenci_Id,b.adisoyadi,b.dönemadi)

return @sonuc
end

GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgrencininAldigiToplamKrediSayisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OgrencininAldigiToplamKrediSayisi](@Ogrenci_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc as int


set  @sonuc = (select  sum(b.KrediSayisi)
from

(select o.Id as Ogrenci_Id, o.Adi+' '+o.SoyAdi as adisoyadi,
Ders_Id,do.Adi as dönemadi,d.KrediSayisi
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id and og.Statu=1
inner join dbo.Ders as d on d.Id=og.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by o.Id,og.Ders_Id,o.Adi,o.SoyAdi,do.Adi,d.KrediSayisi)b
group by b.Ogrenci_Id,b.adisoyadi,b.dönemadi)




return @sonuc
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgrencininIlgiliDerstekiSiralamasi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OgrencininIlgiliDerstekiSiralamasi] 
(
  @Ogrenci_Id int,
  @Ders_Id int
)
RETURNS tinyint
AS 
    BEGIN
	return (
	          select a.Sira from (
	                           select o.Id as Ogrenci_Id,
	          		                  o.Adi+' '+o.SoyAdi as AdiSoyadi,
                                      d.Id as Ders_Id,
                                      d.Adi as DersAdi,
	                                  ood.Vize,
	                                  ood.Final,
	                                  (ood.Vize*0.4+ood.Final*0.6) as Ortalama,
	                                  ROW_NUMBER() OVER (ORDER BY (ood.Vize*0.4+ood.Final*0.6) desc) AS Sira
                               from dbo.OgrenciOgretmenDers as ood
                               inner join dbo.Ogrenci as o on o.Id = ood.Ogrenci_Id and o.Statu = 1
                               inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
                               inner join dbo.Ders as d on d.Id = od.Ders_Id and d.Statu = 1
                               where  ood.Statu =1
                               and od.Ders_Id = @Ders_Id
                          ) as a
               where a.Ogrenci_Id = @Ogrenci_Id
	)

    END
GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgrencininTumBilgileriniGetir]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OgrencininTumBilgileriniGetir]
(
  @Ogrenci_Id int,
  @Donem_Id int
)
    RETURNS @table TABLE (
       AdiSoyadi nvarchar(64),
	   AldigiDersSayisi tinyint,
	   EnBasariliDers nvarchar(16),
	   KrediSayisi tinyint
    )
AS
BEGIN
   declare  @AdiSoyadi nvarchar(64),
	        @AldigiDersSayisi tinyint,
	        @EnBasariliDers nvarchar(16),
	        @KrediSayisi tinyint

 
 select @AdiSoyadi = Adi+' '+SoyAdi from dbo.Ogrenci 
 where Id = @Ogrenci_Id and Statu = 1

 select @AldigiDersSayisi = 
 COUNT(*) from dbo.OgrenciOgretmenDers as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 where Ogrenci_Id = @Ogrenci_Id
 and od.Donem_Id = @Donem_Id
 and ood.Statu = 1
 group by ood.Ogrenci_Id



 select @KrediSayisi = (select  sum(b.KrediSayisi)
from

(select d.KrediSayisi,d.Adi
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id and og.Statu=1
inner join dbo.Ders as d on d.Id=og.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by d.KrediSayisi,d.Adi)b
)


select   @EnBasariliDers =(select a.Adi from   (select top 1 d.Adi  ,(ood.Vize*0.4)+(ood.Final*0.6) as ortalama
 from dbo.[OgrenciOgretmenDers] as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 inner join dbo.Ders as d on d.Id=od.Ders_Id and d.statu=1
 where ood.Statu = 1
 and ood.Ogrenci_Id =@Ogrenci_Id
 and od.Donem_Id =@Donem_Id 
 order by ortalama desc)a
 )
       INSERT INTO @table(AdiSoyadi,AldigiDersSayisi,EnBasariliDers,KrediSayisi)
        SELECT 
		    @AdiSoyadi ,
	        @AldigiDersSayisi ,
	        @EnBasariliDers ,
	        @KrediSayisi 
    RETURN;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgretmenBasariHarfNotu]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[FN$OgretmenBasariHarfNotu](@Ogretmen_Id int,@Ders_Id int,@Donem_Id int)
returns char(2)
as
begin
declare 
        @dersbasariortalamasi int,
		@DersBasariHarfNotu char(2)
		

select 
@dersbasariortalamasi=((dbo.FN$OgretmeneAitHerbirDersinOrtalamaToplamlari(@Ogretmen_Id , @Ders_Id , @Donem_Id )) /(dbo.FN$OgretmeninVerdigiDerseGoreOgrenciSayisi(@Ogretmen_Id ,@Ders_Id ,@Donem_Id)))
 


set @dersbasariortalamasi = ROUND(@dersbasariortalamasi,0)
SET @DersBasariHarfNotu = (SELECT 
       case when  @dersbasariortalamasi between 93 and 100 then  'AA'
	        when  @dersbasariortalamasi between 85 and 92  then  'BA'
	        when  @dersbasariortalamasi between 76 and 84  then  'BB'
	        when  @dersbasariortalamasi between 66 and 75  then  'CB'
			when  @dersbasariortalamasi between 46 and 65  then  'CC'
			when  @dersbasariortalamasi between 31 and 45  then  'DC'
			when  @dersbasariortalamasi between 15 and 30  then  'DD'
	   else 'FF' end )
 

 return @DersBasariHarfNotu
 end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgretmeneAitHerbirDersinOrtalamaToplamlari]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FN$OgretmeneAitHerbirDersinOrtalamaToplamlari](@Ogretmen_Id int,@Ders_Id int,@Donem_Id int)
returns int
as
begin
     declare 
	         @sonuc int


set  @sonuc = (select sum(b.ortalama)  from
(select  d.Id as ders , (ood.Vize*0.4+ood.Final*0.6) as ortalama,do.Id as güzdönemi from dbo.OgrenciOgretmenDers as ood 
inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
where 
ood.Statu=1
and
od.Donem_Id=1
and d.Id = @Ders_Id
and do.Id = @Donem_Id
and od.Ogretmen_Id=@Ogretmen_Id
group by d.Id,ood.Vize*0.4+ood.Final*0.6,do.Id) b
group by b.ders,b.güzdönemi)


return @sonuc
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgretmeninVerdigiDerseGoreOgrenciSayisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OgretmeninVerdigiDerseGoreOgrenciSayisi](@Ogretmen_Id int,@Ders_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc as int


set  @sonuc= (select count(*) as ogrencisayisi   from

(select o.Id as Ogretmen_Id, og.Id as Ogrenci_Id,(o.Adi+o.SoyAdi) as adsoyad, d.Id as Ders_Id, do.Id as Dönem_Id  from dbo.OgrenciOgretmenDers as ood
inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
inner join dbo.Ogretmen as o on o.Id=od.Ogretmen_Id and o.Statu=1
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
inner join dbo.Ogrenci as og on og.Id=ood.Ogrenci_Id and og.statu=1
where 
od.Donem_Id=1
and 
ood.Statu=1
and d.Id=@Ders_Id
and do.Id=@Donem_Id
and o.Id=@Ogretmen_Id
group by o.Id,d.Id,do.Id,og.Id,o.Adi+o.SoyAdi)c

group by c.Ogretmen_Id, c.adsoyad,c.Dönem_Id 
)

return @sonuc
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgretmenlerinIlgiliDonemdekiDerseGoreBasariHarfNotu]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FN$OgretmenlerinIlgiliDonemdekiDerseGoreBasariHarfNotu]
(

  @Donem_Id int,
  @Ogretmen_Id int ,
  @Ders_Id int
)
    RETURNS @table TABLE (
       AdiSoyadi nvarchar(64),
	   DersAdi nvarchar(16),
	   DersiAlanOgrenciSayisi int,
	   BasariNotuOrtalamasi tinyint,
	   BasariHarfNotu Char(2)
    )
AS
BEGIN
   declare  @AdiSoyadi nvarchar(64),
	        @DersAdi nvarchar(16),
	        @DersiAlanOgrenciSayisi int,
	        @BasariNotuOrtalamasi tinyint,
	        @BasariHarfNotu Char(2)
 
 select @AdiSoyadi = Adi+' '+SoyAdi from dbo.Ogretmen 
 where Id = @Ogretmen_Id and Statu = 1

 select @DersAdi= Adi from dbo.Ders
 where Id=@ders_Id

 (select @DersiAlanOgrenciSayisi= count(*)    from

(select o.Id as Ogretmen_Id, og.Id as Ogrenci_Id,(o.Adi+o.SoyAdi) as adsoyad, d.Id as Ders_Id, do.Id as Dönem_Id  from dbo.OgrenciOgretmenDers as ood
inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
inner join dbo.Ogretmen as o on o.Id=od.Ogretmen_Id and o.Statu=1
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
inner join dbo.Ogrenci as og on og.Id=ood.Ogrenci_Id and og.statu=1
where 
od.Donem_Id=1
and 
ood.Statu=1
and d.Id=@Ders_Id
and do.Id=@Donem_Id
and o.Id=@Ogretmen_Id
group by o.Id,d.Id,do.Id,og.Id,o.Adi+o.SoyAdi)c

group by c.Ogretmen_Id, c.adsoyad,c.Dönem_Id 
)


select  @BasariNotuOrtalamasi=((dbo.FN$OgretmeneAitHerbirDersinOrtalamaToplamlari(@Ogretmen_Id , @Ders_Id , @Donem_Id )) /(dbo.FN$OgretmeninVerdigiDerseGoreOgrenciSayisi(@Ogretmen_Id ,@Ders_Id ,@Donem_Id)))

select  @BasariHarfNotu=[dbo].FN$OgretmenBasariHarfNotu(@Ogretmen_Id,@Ders_Id,@Donem_Id  )

 INSERT INTO @table(AdiSoyadi,DersAdi,DersiAlanOgrenciSayisi,  BasariNotuOrtalamasi,BasariHarfNotu)
       

	   
	    SELECT 				 
		    @AdiSoyadi,
			@DersAdi,
			@DersiAlanOgrenciSayisi,
			@BasariNotuOrtalamasi,
			@BasariHarfNotu
    RETURN;
END;


GO
/****** Object:  UserDefinedFunction [dbo].[FN$OgretmenOgrenciAdaGoreFiltrele]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OgretmenOgrenciAdaGoreFiltrele]
(
  @Metin nvarchar(20)
)
    RETURNS @contacts TABLE (
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        person_type VARCHAR(20)
    )
AS
BEGIN
    INSERT INTO @contacts(first_name,last_name,person_type)
    SELECT 
        Adi as first_name, 
        SoyAdi as last_name, 
        'Ogrenci' as person_type
    FROM
       dbo.Ogrenci
	   where ltrim(rtrim(Adi))+' '+ltrim(rtrim(SoyAdi)) like '%'+@Metin+'%'

    INSERT INTO @contacts(first_name,last_name,person_type)
    SELECT 
        Adi as first_name, 
        SoyAdi as last_name, 
        'Ogretmen' as person_type
    FROM
        dbo.Ogretmen
		where ltrim(rtrim(Adi))+' '+ltrim(rtrim(SoyAdi)) like '%'+@Metin+'%'
    RETURN;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[FN$OkulTest]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN$OkulTest]()
    RETURNS @contacts TABLE (
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        person_type VARCHAR(20)
    )
AS
BEGIN
    INSERT INTO @contacts(first_name,last_name,person_type)
    SELECT 
        Adi as first_name, 
        SoyAdi as last_name, 
        'Ogrenci' as person_type
    FROM
       dbo.Ogrenci

    INSERT INTO @contacts(first_name,last_name,person_type)
    SELECT 
        Adi as first_name, 
        SoyAdi as last_name, 
        'Ogretmen' as person_type
    FROM
        dbo.Ogretmen
    RETURN;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[Fn_Birlestir]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Fn_Birlestir](@Ad Nvarchar(20),@Soyad Nvarchar(30))
Returns Nvarchar(51)
As
Begin
Return @Ad + Space(1)+ @Soyad
End
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Ders_Gecme_Bilgisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[fn_Ders_Gecme_Bilgisi]
(
    @vize INT,
    @final INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @gectibilgisi NVARCHAR(50);
    DECLARE @ortalama INT;
    SET @ortalama = @vize * 0.4 + @final * 0.6;
    IF (@ortalama > 50)
        SET @gectibilgisi = 'geçtiniz';
    ELSE
        SET @gectibilgisi = 'kaldınız'+' '+ convert(nvarchar,50-@ortalama)+' '+'puana'+' '+'ihtiyacınız var'
    RETURN  @gectibilgisi
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Harf_Bilgisi2]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_Harf_Bilgisi2]
(

    @vize INT,
    @final INT
	
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @harfbilgisi NVARCHAR(10),
            @Ortalama INT
   SET @Ortalama = @vize * 0.4 + @final * 0.6;
    IF @ortalama between 50 and 60 set @harfbilgisi='DD'
	IF @ortalama between 61 and 70 set @harfbilgisi='CC' 
	IF @ortalama between 71 and 80 set @harfbilgisi='CB'
	IF @ortalama between 81 and 90 set @harfbilgisi='BB'
	IF @ortalama between 91 and 100 set @harfbilgisi='AA'
	IF(@ortalama <50) set @harfbilgisi='FF'
	RETURN   @harfbilgisi
END;

GO
/****** Object:  UserDefinedFunction [dbo].[OgrenciDonemNotOrtalaması]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[OgrenciDonemNotOrtalaması](@Ogrenci_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc as int
set @sonuc= (select a.DonemNotOrtalaması
from

(select o.Id as Ogrenci_Id, 
og.Donem_Id , ((dbo.FN$IlgiliDonemdekiOgrencininSayiDegerleriToplami(@Ogrenci_Id ,@Donem_Id)) /(dbo.FN$OgrencininAldigiToplamKrediSayisi(@Ogrenci_Id,@Donem_Id)))
 as DonemNotOrtalaması
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id and og.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by  o.Id,
          og.Donem_Id
       	     
) A
)
 return @sonuc
 end

GO
/****** Object:  UserDefinedFunction [dbo].[OgrenciDonemNotOrtalamasi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[OgrenciDonemNotOrtalamasi](@Ogrenci_Id int,@Donem_Id int)
returns int
as
begin
declare @sonuc as int
set @sonuc= (select a.DonemNotOrtalaması
from

(select o.Id as Ogrenci_Id, 
og.Donem_Id , ((dbo.FN$IlgiliDonemdekiOgrencininSayiDegerleriToplami(@Ogrenci_Id ,@Donem_Id)) /(dbo.FN$OgrencininAldigiToplamKrediSayisi(@Ogrenci_Id,@Donem_Id)))
 as DonemNotOrtalaması
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id and og.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id =  @Ogrenci_Id
and do.Id = @Donem_Id
group by  o.Id,
          og.Donem_Id
       	     
) A
)
 return @sonuc
 end

GO
/****** Object:  UserDefinedFunction [dbo].[Ogrenciler]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE function [dbo].[Ogrenciler]
  (
  )
  returns @Ogrencitablo table
  (
  Id int,
  isim nvarchar(20),
  soyisim nvarchar(20)
  )
  as
  begin
  insert into @ogrencitablo (Id,isim,soyisim)values 
  (1,'esma','aydın')
  return
  end
GO
/****** Object:  UserDefinedFunction [dbo].[Topla]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Topla](@sayı1 as int, @sayı2 as int)
returns int
as
begin
declare @sonuç as int
set @sonuç=@sayı1+@sayı2
return @sonuç


end
GO
/****** Object:  Table [dbo].[Ders]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Kodu] [nvarchar](10) NOT NULL,
	[Adi] [nvarchar](50) NOT NULL,
	[KrediSayisi] [tinyint] NOT NULL,
	[Statu] [bit] NOT NULL CONSTRAINT [df_status]  DEFAULT ((1)),
	[KayitTarihi] [datetime] NOT NULL CONSTRAINT [df_tarihDers]  DEFAULT (getdate()),
 CONSTRAINT [PK_Ders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Donem]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Donem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Adi] [nvarchar](50) NOT NULL,
	[Yil] [int] NOT NULL,
	[Statu] [bit] NOT NULL CONSTRAINT [df_statuss]  DEFAULT ((1)),
	[KayitTarihi] [datetime] NULL CONSTRAINT [df_Cityss]  DEFAULT (getdate()),
 CONSTRAINT [PK_Donem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ogrenci]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ogrenci](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Adi] [nvarchar](50) NOT NULL,
	[SoyAdi] [nvarchar](50) NOT NULL,
	[Tc] [char](11) NOT NULL,
	[Email] [nvarchar](30) NULL,
	[Statu] [bit] NOT NULL CONSTRAINT [df_statu]  DEFAULT ((1)),
	[KayitTarihi] [datetime] NOT NULL CONSTRAINT [df_tarih]  DEFAULT (getdate()),
	[Dogum_Tarihi] [datetime] NULL,
 CONSTRAINT [PK_Ogrenci] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OgrenciOgretmenDers]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OgrenciOgretmenDers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ogrenci_Id] [int] NOT NULL,
	[OgretmenDers_Id] [int] NOT NULL,
	[Vize] [tinyint] NOT NULL,
	[Final] [tinyint] NOT NULL,
	[Statu] [bit] NOT NULL CONSTRAINT [df_OgrenciOgretmenDers]  DEFAULT ((1)),
	[KayitTarihi] [datetime] NOT NULL CONSTRAINT [df_OgrenciOgretmenDerss]  DEFAULT (getdate()),
	[Ortalama] [int] NULL,
 CONSTRAINT [PK_OgrenciOgretmenDers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ogretmen]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ogretmen](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Adi] [nvarchar](50) NOT NULL,
	[SoyAdi] [nvarchar](50) NOT NULL,
	[Tc] [char](11) NOT NULL,
	[Unvan] [nvarchar](50) NOT NULL,
	[Bransi] [nvarchar](50) NOT NULL,
	[Statu] [bit] NOT NULL CONSTRAINT [df_statusss]  DEFAULT ((1)),
	[KayitTarihi] [datetime] NOT NULL CONSTRAINT [df_statssuss]  DEFAULT (getdate()),
 CONSTRAINT [PK_Ogretmen] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OgretmenDers]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OgretmenDers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ogretmen_Id] [int] NOT NULL,
	[Ders_Id] [int] NOT NULL,
	[Donem_Id] [int] NOT NULL,
	[GunAdi] [nvarchar](50) NOT NULL,
	[BaslangicSaati] [time](7) NOT NULL,
	[BitisSaati] [time](7) NOT NULL,
	[Kontenjan] [tinyint] NOT NULL,
	[Statu] [bit] NOT NULL CONSTRAINT [df_sddtatusss]  DEFAULT ((1)),
	[KayitTarihi] [datetime] NOT NULL CONSTRAINT [df_statggssuss]  DEFAULT (getdate()),
 CONSTRAINT [PK_OgretmenDers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[DogummTarihiId]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[DogummTarihiId](@Yas int)
 returns table
 as 
 return
 select *,(DATEPART(year,getdate())- DATEPART(year,o.Dogum_Tarihi)) AS YAS from dbo.Ogrenci as o  where 

 (DATEPART(year,getdate())- DATEPART(year,o.Dogum_Tarihi)) < @Yas
 AND O.Statu=1
GO
/****** Object:  UserDefinedFunction [dbo].[fn_donem]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_donem](@donem int)
returns table
as
return(select
* from dbo.OgretmenDers where Donem_Id
=@donem)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_hazır]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_hazır](@uid tinyint)
returns table
as
return(select
* from dbo.OgretmenDers where Donem_Id
=@uid)
GO
/****** Object:  UserDefinedFunction [dbo].[getkredisayisibyKrediSayisiid]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[getkredisayisibyKrediSayisiid](@id int)
returns table
as
return
select * from dbo.Ders where KrediSayisi=@İd
GO
/****** Object:  UserDefinedFunction [dbo].[GirilenDegerdenKücükYasBilgisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GirilenDegerdenKücükYasBilgisi](@Yas int)
 returns table
 as 
 return
 select *,(DATEPART(year,getdate())- DATEPART(year,o.Dogum_Tarihi)) AS YAS from dbo.Ogrenci as o  where 

 (DATEPART(year,getdate())- DATEPART(year,o.Dogum_Tarihi)) < @Yas
 AND O.Statu=1
GO
/****** Object:  UserDefinedFunction [dbo].[GirilenDeğerdennDahaBüyükOrtalamayıGetirir]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GirilenDeğerdennDahaBüyükOrtalamayıGetirir](@girilendeğer int)
  returns table
  as
  return 
   select * from (
	                           select 
	                                  ood.Vize,
	                                  ood.Final,
	                                  (ood.Vize*0.4+ood.Final*0.6) as Ortalama
	                                  
                               from dbo.OgrenciOgretmenDers as ood
                            
                               where  ood.Statu =1
                               
                          ) as a
                where a.Ortalama>@girilendeğer
	
GO
/****** Object:  UserDefinedFunction [dbo].[IlgiliDerseAitGünVeSaatBilgisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[IlgiliDerseAitGünVeSaatBilgisi](@ders int)
returns table
as
return
select od.Ders_Id, d.Adi,od.GunAdi,od.BaslangicSaati,od.BitisSaati from dbo.OgretmenDers as od 
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
where Ders_Id=@ders
and
od.Statu=1

GO
/****** Object:  UserDefinedFunction [dbo].[IlgiliDerseAitOgretmenBilgisi]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[IlgiliDerseAitOgretmenBilgisi](@Ders int)
 returns table
 as
 return
 select od.Ders_Id,d.Adi as dersadi,(o.Adi+' '+o.SoyAdi) as ogretmenadsoyad from dbo.OgretmenDers as od 
 inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
 inner join dbo.Ogretmen as o on o.Id=od.Ogretmen_Id and o.Statu=1
 where Ders_Id=@Ders
 and
 od.Statu=1
GO
/****** Object:  UserDefinedFunction [dbo].[vizepuan]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[vizepuan](@gelenpuan int)
  returns table
  as
  return (select * from dbo.OgrenciOgretmenDers where Vize>@gelenpuan)
GO
/****** Object:  View [dbo].[Ogrenciname]    Script Date: 7.08.2022 17:06:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[Ogrenciname]
as
select Adi from Ogrenci
GO
SET IDENTITY_INSERT [dbo].[Ders] ON 

INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (5, N'MEB-112', N'Mat', 4, 1, CAST(N'2022-03-26 22:24:37.890' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (6, N'İMÖP 356', N'Geo', 4, 1, CAST(N'2022-03-27 11:32:21.303' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (8, N'Meb365', N'Yazılım', 3, 1, CAST(N'2022-03-27 18:35:32.800' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (9, N'Meb658', N'Bilişim', 4, 1, CAST(N'2022-03-27 18:35:47.043' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (10, N'Meb356', N'Türkçe', 5, 1, CAST(N'2022-03-27 18:36:07.883' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (11, N'Meb872', N'Tarih', 6, 1, CAST(N'2022-03-27 18:36:20.427' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (12, N'Meb986', N'Sosyoloji', 4, 1, CAST(N'2022-03-27 18:36:35.770' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (13, N'Meb485', N'İngilizce', 4, 1, CAST(N'2022-03-27 18:37:20.027' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (14, N'Meb654', N'Psikoloji', 4, 1, CAST(N'2022-03-27 18:37:33.277' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (16, N'Meb741', N'Çocuk Gelişimi', 3, 1, CAST(N'2022-03-27 18:38:09.980' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (17, N'Meb872', N'İlahiyat', 4, 1, CAST(N'2022-03-27 18:38:24.603' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (18, N'Meb450', N'Eğitim', 7, 1, CAST(N'2022-03-27 18:38:37.610' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (19, N'Meb740', N'Gelişim', 4, 1, CAST(N'2022-03-27 18:42:44.990' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (20, N'2154', N'Modelleme', 4, 1, CAST(N'2022-04-03 20:40:35.323' AS DateTime))
INSERT [dbo].[Ders] ([Id], [Kodu], [Adi], [KrediSayisi], [Statu], [KayitTarihi]) VALUES (21, N'1478', N'Özel Eğitim', 3, 1, CAST(N'2022-04-03 20:41:00.673' AS DateTime))
SET IDENTITY_INSERT [dbo].[Ders] OFF
SET IDENTITY_INSERT [dbo].[Donem] ON 

INSERT [dbo].[Donem] ([Id], [Adi], [Yil], [Statu], [KayitTarihi]) VALUES (1, N'Güz 2021', 2021, 1, CAST(N'2022-03-27 22:31:23.607' AS DateTime))
INSERT [dbo].[Donem] ([Id], [Adi], [Yil], [Statu], [KayitTarihi]) VALUES (18, N'Bahar 2022', 2022, 1, CAST(N'2022-03-27 22:31:23.607' AS DateTime))
SET IDENTITY_INSERT [dbo].[Donem] OFF
SET IDENTITY_INSERT [dbo].[Ogrenci] ON 

INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (2, N'Can', N'Güler', N'37076133202', NULL, 1, CAST(N'2022-03-26 22:19:37.010' AS DateTime), CAST(N'1997-04-17 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (3, N'Emel', N'Güler', N'37079133148', NULL, 1, CAST(N'2022-03-26 22:19:57.970' AS DateTime), CAST(N'1997-04-23 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (6, N'Ahmet', N'Sayın', N'44556666666', NULL, 1, CAST(N'2022-03-26 22:20:21.823' AS DateTime), CAST(N'1997-05-17 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (7, N'Ayşe', N'Sayın', N'1542683321 ', NULL, 1, CAST(N'2022-03-27 11:04:06.460' AS DateTime), CAST(N'1997-05-16 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (8, N'Ekin', N'Koç', N'25647855231', NULL, 1, CAST(N'2022-03-27 11:04:51.847' AS DateTime), CAST(N'1997-02-02 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (9, N'Eflin', N'Su', N'87542586221', NULL, 1, CAST(N'2022-03-27 11:05:15.813' AS DateTime), CAST(N'1997-02-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (10, N'Aydın', N'Hakim', N'78542369555', NULL, 1, CAST(N'2022-03-27 11:05:32.610' AS DateTime), CAST(N'1997-08-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (11, N'Aykut', N'Selim', N'98653255874', NULL, 1, CAST(N'2022-03-27 11:05:55.050' AS DateTime), CAST(N'1997-09-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (12, N'Selin', N'Aydın', N'98632569887', NULL, 1, CAST(N'2022-03-27 11:06:17.423' AS DateTime), CAST(N'1997-12-12 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (13, N'Havvanur', N'El', N'96536588745', NULL, 1, CAST(N'2022-03-27 11:06:35.927' AS DateTime), CAST(N'1997-12-12 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (14, N'    Pınar', N'Deniz', N'536985248  ', NULL, 1, CAST(N'2022-03-27 11:06:55.750' AS DateTime), CAST(N'1997-11-15 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (15, N'Akif', N'Yılmaz', N'36598774521', NULL, 1, CAST(N'2022-03-27 11:07:24.840' AS DateTime), CAST(N'1997-10-10 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (16, N'Melina', N'Aksu', N'9856325417 ', NULL, 1, CAST(N'2022-03-27 11:07:42.697' AS DateTime), CAST(N'1996-05-05 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (17, N'Elanur', N'Ekim', N'1254877555 ', NULL, 1, CAST(N'2022-03-27 11:07:59.933' AS DateTime), CAST(N'1996-05-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (18, N'Aslıhan', N'Öztürk', N'7854125874 ', NULL, 1, CAST(N'2022-03-27 11:08:21.400' AS DateTime), CAST(N'1998-06-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (19, N'Aslı', N'Yalnız', N'23659845521', NULL, 1, CAST(N'2022-03-27 11:08:47.433' AS DateTime), CAST(N'1996-05-05 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (20, N'Melek', N'Öztürk', N'326598547  ', NULL, 1, CAST(N'2022-03-27 11:09:07.373' AS DateTime), CAST(N'1996-04-13 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (21, N'Aynur', N'Terzi', N'98653265874', NULL, 1, CAST(N'2022-03-27 11:09:27.340' AS DateTime), CAST(N'1996-04-13 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (23, N'Eylem', N'Bozkurt', N'326598745  ', NULL, 1, CAST(N'2022-03-27 11:09:55.837' AS DateTime), CAST(N'1996-05-25 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (24, N'Eylem', N'Ayhan', N'326598545  ', NULL, 1, CAST(N'2022-03-27 11:10:15.780' AS DateTime), CAST(N'1996-05-26 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (25, N'Aykut', N'Soner', N'2564478554 ', NULL, 1, CAST(N'2022-03-27 11:10:30.170' AS DateTime), CAST(N'1996-07-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (26, N'Aydın', N'Eyhem', N'785421665  ', NULL, 1, CAST(N'2022-03-27 11:10:53.430' AS DateTime), CAST(N'1996-05-02 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (27, N'Emel', N'Kayhan', N'9856325471 ', NULL, 1, CAST(N'2022-03-27 11:11:15.043' AS DateTime), CAST(N'1996-06-03 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (28, N'Barış', N'Aksu', N'2365985623 ', NULL, 1, CAST(N'2022-03-27 11:11:29.353' AS DateTime), CAST(N'1996-03-15 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (29, N'Selvi', N'Aksoy', N'2145785421 ', NULL, 1, CAST(N'2022-03-27 11:11:46.253' AS DateTime), CAST(N'1996-03-15 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (30, N'    Mustafa', N'Can', N'4589652555 ', NULL, 1, CAST(N'2022-03-27 11:12:14.010' AS DateTime), CAST(N'1996-05-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (31, N'Saime', N'Çınar', N'2365985474 ', NULL, 1, CAST(N'2022-03-27 11:12:32.403' AS DateTime), CAST(N'1996-04-07 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (32, N'Selçuk', N'Konya', N'23659874551', NULL, 1, CAST(N'2022-03-27 11:12:47.800' AS DateTime), CAST(N'1994-04-04 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (33, N'Mehmet', N'Kara', N'2136659855 ', NULL, 1, CAST(N'2022-03-27 11:13:02.967' AS DateTime), CAST(N'1994-02-02 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (34, N'Aren', N'Öz', N'8956247855 ', NULL, 1, CAST(N'2022-03-27 11:13:19.290' AS DateTime), CAST(N'1991-02-12 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (35, N'Selen', N'Seymen', N'78596655477', NULL, 1, CAST(N'2022-03-27 11:14:03.110' AS DateTime), CAST(N'1991-11-14 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (36, N'Emre', N'Selvi', N'1256398555 ', NULL, 1, CAST(N'2022-03-27 11:14:19.220' AS DateTime), CAST(N'1993-12-10 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (37, N'Sevgi', N'Soydan', N'1254778554 ', NULL, 1, CAST(N'2022-03-27 11:14:31.810' AS DateTime), CAST(N'1992-12-14 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (38, N'Serpil', N'Demirbilek', N'1254788547 ', NULL, 1, CAST(N'2022-03-27 11:14:51.070' AS DateTime), CAST(N'1988-05-05 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (39, N'Melek', N'Sedir', N'2369856558 ', NULL, 1, CAST(N'2022-03-27 11:15:13.910' AS DateTime), CAST(N'1988-04-07 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (40, N'Aylin', N'Küp', N'236598774  ', NULL, 1, CAST(N'2022-03-27 11:15:32.863' AS DateTime), CAST(N'1987-06-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (41, N'Mert', N'Varol', N'32658988744', NULL, 1, CAST(N'2022-03-27 11:15:47.043' AS DateTime), CAST(N'1987-04-12 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (42, N'Emir', N'Bekçi', N'23655988744', NULL, 1, CAST(N'2022-03-27 11:15:57.380' AS DateTime), CAST(N'1987-12-15 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (43, N'Kayra', N'Batın', N'32659854777', NULL, 1, CAST(N'2022-03-27 11:16:32.920' AS DateTime), CAST(N'1987-05-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (44, N'Batı', N'Tuna', N'12547885554', NULL, 1, CAST(N'2022-03-27 11:16:47.060' AS DateTime), CAST(N'1983-05-05 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (46, N'Kuzey', N'Emir', N'1455874522 ', NULL, 1, CAST(N'2022-03-27 11:17:06.957' AS DateTime), CAST(N'1983-02-04 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (49, N'Akif', N'Can', N'2547147785 ', NULL, 1, CAST(N'2022-03-27 11:17:31.910' AS DateTime), CAST(N'1982-05-04 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (50, N'Ali', N'Alioğlu', N'215487547  ', N' ', 1, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1996-11-04 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (51, N'İhsan', N'İhsanoğlu', N'215487547  ', N' ', 1, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1995-05-06 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (52, N'İhsan Ali', N'İhsanoğlu', N'215487547  ', N' ', 1, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2000-02-05 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (53, N'Ece', N'Aydın', N'251547554  ', NULL, 1, CAST(N'2022-04-10 15:10:59.953' AS DateTime), CAST(N'2004-12-12 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (54, N'Efe', N'Arman', N'12548755   ', NULL, 1, CAST(N'2022-04-10 15:11:30.043' AS DateTime), CAST(N'2001-02-02 00:00:00.000' AS DateTime))
INSERT [dbo].[Ogrenci] ([Id], [Adi], [SoyAdi], [Tc], [Email], [Statu], [KayitTarihi], [Dogum_Tarihi]) VALUES (55, N'fevzi', N'Çakmak', N'56985635477', N' ', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1905-06-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Ogrenci] OFF
SET IDENTITY_INSERT [dbo].[OgrenciOgretmenDers] ON 

INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (1, 2, 1, 35, 58, 1, CAST(N'2022-03-27 21:33:16.810' AS DateTime), 48)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (2, 3, 5, 45, 45, 1, CAST(N'2022-03-27 21:33:36.963' AS DateTime), 45)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (3, 6, 4, 25, 12, 1, CAST(N'2022-03-27 21:34:01.853' AS DateTime), 17)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (4, 7, 5, 100, 100, 1, CAST(N'2022-03-27 21:34:21.220' AS DateTime), 100)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (7, 10, 8, 56, 76, 1, CAST(N'2022-03-27 21:35:11.940' AS DateTime), 68)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (8, 11, 10, 65, 95, 1, CAST(N'2022-03-27 21:35:27.433' AS DateTime), 83)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (9, 12, 11, 23, 32, 1, CAST(N'2022-03-27 21:35:45.190' AS DateTime), 28)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (10, 13, 13, 2, 6, 1, CAST(N'2022-03-27 21:36:21.620' AS DateTime), 4)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (29, 2, 5, 45, 75, 1, CAST(N'2022-03-29 19:34:57.907' AS DateTime), 63)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (30, 2, 4, 25, 62, 1, CAST(N'2022-03-29 19:35:08.520' AS DateTime), 47)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (32, 6, 24, 25, 25, 1, CAST(N'2022-03-29 19:35:30.217' AS DateTime), 25)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (33, 6, 8, 25, 36, 1, CAST(N'2022-03-29 19:35:39.323' AS DateTime), 31)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (34, 7, 25, 14, 14, 1, CAST(N'2022-03-29 19:35:49.463' AS DateTime), 14)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (37, 9, 5, 47, 74, 1, CAST(N'2022-03-29 19:36:25.707' AS DateTime), 63)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (41, 10, 4, 87, 87, 1, CAST(N'2022-03-29 19:37:11.070' AS DateTime), 87)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (42, 10, 24, 25, 24, 1, CAST(N'2022-03-29 19:37:17.647' AS DateTime), 24)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (47, 13, 25, 74, 74, 1, CAST(N'2022-03-29 19:38:08.120' AS DateTime), 74)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (50, 14, 10, 25, 28, 1, CAST(N'2022-03-29 19:38:29.800' AS DateTime), 26)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (53, 15, 5, 74, 17, 1, CAST(N'2022-03-29 19:39:03.367' AS DateTime), 39)
INSERT [dbo].[OgrenciOgretmenDers] ([Id], [Ogrenci_Id], [OgretmenDers_Id], [Vize], [Final], [Statu], [KayitTarihi], [Ortalama]) VALUES (58, 17, 10, 4, 44, 1, CAST(N'2022-03-29 19:39:39.883' AS DateTime), 28)
SET IDENTITY_INSERT [dbo].[OgrenciOgretmenDers] OFF
SET IDENTITY_INSERT [dbo].[Ogretmen] ON 

INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (1, N'Ahmet', N'Pınar', N'12454785547', N'Doç.', N'Mat', 1, CAST(N'2022-03-27 11:18:34.380' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (2, N'Aylin', N'Öz', N'2365998874 ', N'Yardımcı Doç.', N'Mat', 1, CAST(N'2022-03-27 11:19:17.820' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (3, N'Emel', N'Bayraktar', N'3665985544 ', N'Prof.', N'Yazılım', 1, CAST(N'2022-03-27 11:19:58.683' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (4, N'Eslem', N'Boz', N'7425474147 ', N'Dr.', N'Geo', 1, CAST(N'2022-03-27 11:20:26.490' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (5, N'Mehmet', N'Selman', N'3659852475 ', N'Öğretim Görevlisi', N'Yazılım', 1, CAST(N'2022-03-27 11:21:02.267' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (6, N'Ekim', N'Konmaz', N'6359855244 ', N'Prof.', N'Mat', 1, CAST(N'2022-03-27 11:21:36.233' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (7, N'Aylin', N'Yer', N'3659852458 ', N'Dr.', N'Gelişim', 1, CAST(N'2022-03-27 11:21:57.300' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (8, N'Medine', N'Nur', N'3659852445 ', N'Dr.', N'Psikoloji', 1, CAST(N'2022-03-27 11:22:21.023' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (9, N'Ahmet', N'Yeğin', N'78542874458', N'Dr.', N'İngilizce', 1, CAST(N'2022-03-27 11:22:44.157' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (10, N'Abdullah', N'Selim', N'3659885744 ', N'Prof.', N'Sosyoloji', 1, CAST(N'2022-03-27 11:23:16.103' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (11, N'Elif Medine', N'Petek', N'7854787555 ', N'Öğretim Görevlisi', N'Mat', 1, CAST(N'2022-03-27 11:23:56.410' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (12, N'Arif', N'Bozurt', N'3659854755 ', N'Araştırma Görevlisi', N'psikoloji', 1, CAST(N'2022-03-27 11:24:35.657' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (14, N'Aren', N'Selmanoğlu', N'89547854125', N'Dr.', N'Mat', 1, CAST(N'2022-03-27 11:25:22.737' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (15, N'Emel', N'Güler', N'23658947855', N'Dr.', N'Çocuk Gelişim', 1, CAST(N'2022-03-27 11:25:50.147' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (16, N'Aysel', N'Güre', N'36598547551', N'Dr.', N'Eğitim', 1, CAST(N'2022-03-27 11:26:21.057' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (17, N'Pınar', N'Selvioğlu', N'3659852547 ', N'Prof.', N'İngilizce', 1, CAST(N'2022-03-27 11:26:40.627' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (19, N'Bahar', N'Selviboy', N'36598565895', N'Öğretim Görevlisi', N'Mat', 1, CAST(N'2022-03-27 11:27:13.630' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (21, N'Hasan', N'Demir', N'23659877   ', N'Öğretim Görevlisi', N'psikoloji', 1, CAST(N'2022-03-27 11:27:39.053' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (22, N'Mehmet', N'Çekiç', N'3659854785 ', N'Dr.', N'Mat', 1, CAST(N'2022-03-27 11:28:01.727' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (23, N'Emirhan', N'Gün', N'36598544785', N'Araştırma Görevlisi', N'İngilizce', 1, CAST(N'2022-03-27 11:28:30.303' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (24, N'Elifsu', N'Sukuyusu', N'7458547854 ', N'Öğretim Görevlisi', N'Geo', 1, CAST(N'2022-03-27 11:28:58.217' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (25, N'Ekrem', N'Bora', N'659887445  ', N'Öğretim Görevlisi', N'Gelişim', 1, CAST(N'2022-03-27 11:29:21.127' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (26, N'Erdem', N'Ay', N'365985477  ', N'Öğretim Görevlisi', N'Çocuk Gelişimi', 1, CAST(N'2022-03-27 11:30:01.840' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (27, N'Cüneyt', N'Kar', N'365985555  ', N'Öğretim Görevlisi', N'Eğitim', 1, CAST(N'2022-03-27 11:30:33.670' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (28, N'Can', N'Vedat', N'3659856544 ', N'Öğretim Görevlisi', N'Bilişim', 1, CAST(N'2022-03-27 11:31:02.883' AS DateTime))
INSERT [dbo].[Ogretmen] ([Id], [Adi], [SoyAdi], [Tc], [Unvan], [Bransi], [Statu], [KayitTarihi]) VALUES (29, N'Hatice', N'Güler', N'63589554741', N'Dr.', N'İlahiyat', 1, CAST(N'2022-03-27 11:31:24.403' AS DateTime))
SET IDENTITY_INSERT [dbo].[Ogretmen] OFF
SET IDENTITY_INSERT [dbo].[OgretmenDers] ON 

INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (1, 1, 5, 1, N'Pazartesi', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 20, 1, CAST(N'2022-03-27 18:58:24.970' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (3, 2, 5, 1, N'Pazartesi', CAST(N'09:50:00' AS Time), CAST(N'10:40:00' AS Time), 15, 1, CAST(N'2022-03-27 19:00:54.997' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (4, 11, 6, 1, N'Salı', CAST(N'10:55:00' AS Time), CAST(N'11:15:00' AS Time), 15, 1, CAST(N'2022-03-27 19:02:06.450' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (5, 6, 8, 1, N'Salı', CAST(N'11:25:00' AS Time), CAST(N'12:00:00' AS Time), 20, 1, CAST(N'2022-03-27 19:02:33.600' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (6, 14, 5, 1, N'Salı', CAST(N'12:10:00' AS Time), CAST(N'12:40:00' AS Time), 17, 1, CAST(N'2022-03-27 19:02:58.173' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (7, 19, 5, 1, N'Pazartesi', CAST(N'11:00:00' AS Time), CAST(N'11:25:00' AS Time), 20, 1, CAST(N'2022-03-27 19:03:45.930' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (8, 22, 5, 1, N'Pazartsi', CAST(N'11:35:00' AS Time), CAST(N'12:10:00' AS Time), 18, 1, CAST(N'2022-03-27 19:04:20.063' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (10, 3, 8, 1, N'Pazartesi', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 20, 1, CAST(N'2022-03-27 19:05:38.040' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (11, 5, 8, 1, N'Pazartesi', CAST(N'09:50:00' AS Time), CAST(N'10:40:00' AS Time), 15, 1, CAST(N'2022-03-27 19:06:22.263' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (13, 4, 6, 1, N'Salı', CAST(N'10:55:00' AS Time), CAST(N'11:15:00' AS Time), 12, 1, CAST(N'2022-03-27 19:09:02.353' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (14, 24, 6, 1, N'Salı', CAST(N'12:10:00' AS Time), CAST(N'12:40:00' AS Time), 10, 1, CAST(N'2022-03-27 19:10:03.190' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (15, 7, 19, 1, N'Çarşamba', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 20, 1, CAST(N'2022-03-27 19:11:23.443' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (16, 25, 19, 1, N'Çarşamba', CAST(N'09:50:00' AS Time), CAST(N'10:40:00' AS Time), 15, 1, CAST(N'2022-03-27 19:12:18.423' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (17, 8, 14, 1, N'Çarşamba', CAST(N'10:55:00' AS Time), CAST(N'11:15:00' AS Time), 15, 1, CAST(N'2022-03-27 19:13:08.143' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (18, 12, 14, 1, N'Pazartesi', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 20, 1, CAST(N'2022-03-27 19:13:58.397' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (19, 21, 14, 1, N'Cuma', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 20, 1, CAST(N'2022-03-27 19:14:25.253' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (20, 9, 13, 1, N'Cuma', CAST(N'09:50:00' AS Time), CAST(N'10:40:00' AS Time), 10, 1, CAST(N'2022-03-27 19:15:13.217' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (21, 17, 13, 1, N'Perşembe', CAST(N'15:00:00' AS Time), CAST(N'15:40:00' AS Time), 45, 1, CAST(N'2022-03-27 19:15:47.833' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (22, 23, 13, 1, N'Perşembe', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 38, 1, CAST(N'2022-03-27 19:16:20.750' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (23, 10, 12, 1, N'Pazartesi', CAST(N'15:00:00' AS Time), CAST(N'15:40:00' AS Time), 56, 1, CAST(N'2022-03-27 19:17:10.733' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (24, 15, 16, 1, N'Pazrtesi', CAST(N'14:00:00' AS Time), CAST(N'14:40:00' AS Time), 75, 1, CAST(N'2022-03-27 19:18:07.077' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (25, 26, 16, 1, N'Cuma', CAST(N'13:00:00' AS Time), CAST(N'13:40:00' AS Time), 25, 1, CAST(N'2022-03-27 19:18:47.010' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (26, 16, 18, 1, N'Salı', CAST(N'12:10:00' AS Time), CAST(N'12:40:00' AS Time), 100, 1, CAST(N'2022-03-27 19:19:53.063' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (27, 27, 18, 1, N'Çarşamba', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 65, 1, CAST(N'2022-03-27 19:20:26.990' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (28, 28, 9, 1, N'Salı', CAST(N'15:00:00' AS Time), CAST(N'15:40:00' AS Time), 35, 1, CAST(N'2022-03-27 19:21:29.093' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (29, 29, 17, 1, N'Perşembe', CAST(N'11:00:00' AS Time), CAST(N'11:40:00' AS Time), 80, 1, CAST(N'2022-03-27 19:22:22.203' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (30, 1, 8, 1, N'Pazartesi', CAST(N'09:45:00' AS Time), CAST(N'10:10:00' AS Time), 20, 1, CAST(N'2022-03-29 19:43:27.427' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (31, 1, 6, 1, N'Salı', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 72, 1, CAST(N'2022-03-29 19:43:56.233' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (32, 2, 6, 1, N'Salı', CAST(N'09:15:00' AS Time), CAST(N'10:00:00' AS Time), 25, 1, CAST(N'2022-03-29 19:44:19.570' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (34, 11, 6, 1, N'Salı', CAST(N'09:00:00' AS Time), CAST(N'09:25:00' AS Time), 40, 1, CAST(N'2022-03-29 19:45:02.653' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (35, 6, 6, 1, N'Çarşamba', CAST(N'09:00:00' AS Time), CAST(N'09:45:00' AS Time), 52, 1, CAST(N'2022-03-29 19:45:25.083' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (36, 14, 8, 1, N'Perşembe', CAST(N'15:00:00' AS Time), CAST(N'16:00:00' AS Time), 20, 1, CAST(N'2022-03-29 19:45:42.473' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (37, 19, 14, 1, N'Perşembe', CAST(N'13:00:00' AS Time), CAST(N'13:40:00' AS Time), 13, 1, CAST(N'2022-03-29 19:46:09.047' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (38, 19, 8, 1, N'Perşembe', CAST(N'14:00:00' AS Time), CAST(N'14:40:00' AS Time), 10, 1, CAST(N'2022-03-29 19:46:31.880' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (39, 19, 19, 1, N'Cuma', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 20, 1, CAST(N'2022-03-29 19:47:24.730' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (40, 22, 18, 1, N'Perşembe', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 40, 1, CAST(N'2022-03-29 19:47:45.433' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (42, 3, 5, 1, N'Salı', CAST(N'18:00:00' AS Time), CAST(N'18:30:00' AS Time), 20, 1, CAST(N'2022-03-29 19:48:07.067' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (43, 5, 5, 1, N'Salı', CAST(N'15:00:00' AS Time), CAST(N'15:30:00' AS Time), 20, 1, CAST(N'2022-03-29 19:48:22.700' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (44, 4, 6, 1, N'Salı', CAST(N'10:00:00' AS Time), CAST(N'10:40:00' AS Time), 20, 1, CAST(N'2022-03-29 19:48:40.120' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (45, 24, 8, 1, N'Salı', CAST(N'15:00:00' AS Time), CAST(N'15:40:00' AS Time), 15, 1, CAST(N'2022-03-29 19:48:59.850' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (46, 7, 5, 1, N'Salı', CAST(N'12:00:00' AS Time), CAST(N'12:40:00' AS Time), 40, 1, CAST(N'2022-03-29 19:49:15.373' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (47, 7, 13, 1, N'Salı', CAST(N'12:50:00' AS Time), CAST(N'13:15:00' AS Time), 15, 1, CAST(N'2022-03-29 19:49:50.300' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (48, 25, 16, 1, N'Çarşamba', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 25, 1, CAST(N'2022-03-29 19:50:10.390' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (49, 8, 18, 1, N'Perşembe', CAST(N'17:00:00' AS Time), CAST(N'17:40:00' AS Time), 20, 1, CAST(N'2022-03-29 19:50:27.070' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (50, 12, 12, 1, N'Salı', CAST(N'18:00:00' AS Time), CAST(N'18:30:00' AS Time), 10, 1, CAST(N'2022-03-29 19:50:47.063' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (51, 9, 9, 1, N'Salı', CAST(N'15:00:00' AS Time), CAST(N'15:30:00' AS Time), 8, 1, CAST(N'2022-03-29 19:51:08.090' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (52, 17, 17, 1, N'Pazartesi', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 10, 1, CAST(N'2022-03-29 19:51:37.217' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (53, 23, 9, 1, N'Perşembe', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 40, 1, CAST(N'2022-03-29 19:52:00.667' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (54, 15, 5, 1, N'Salı', CAST(N'14:00:00' AS Time), CAST(N'14:40:00' AS Time), 70, 1, CAST(N'2022-03-29 19:52:22.467' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (55, 15, 8, 1, N'Salı', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 12, 1, CAST(N'2022-03-29 19:52:52.453' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (56, 26, 5, 1, N'Pazartesi', CAST(N'18:00:00' AS Time), CAST(N'18:30:00' AS Time), 10, 1, CAST(N'2022-03-29 19:53:16.747' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (57, 16, 9, 1, N'Salı', CAST(N'09:00:00' AS Time), CAST(N'09:40:00' AS Time), 15, 1, CAST(N'2022-03-29 19:53:34.980' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (58, 16, 5, 1, N'Pazrtesi', CAST(N'15:00:00' AS Time), CAST(N'15:40:00' AS Time), 10, 1, CAST(N'2022-03-29 19:53:53.177' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (59, 16, 17, 1, N'Salı', CAST(N'18:00:00' AS Time), CAST(N'18:30:00' AS Time), 15, 1, CAST(N'2022-03-29 19:54:15.547' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (60, 28, 14, 1, N'Pazartesi', CAST(N'15:00:00' AS Time), CAST(N'15:30:00' AS Time), 40, 1, CAST(N'2022-03-29 19:54:38.283' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (61, 28, 17, 1, N'Pazrtesi', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 40, 1, CAST(N'2022-03-29 19:54:57.277' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (62, 29, 5, 1, N'Salı', CAST(N'16:00:00' AS Time), CAST(N'16:40:00' AS Time), 40, 1, CAST(N'2022-03-29 19:55:18.333' AS DateTime))
INSERT [dbo].[OgretmenDers] ([Id], [Ogretmen_Id], [Ders_Id], [Donem_Id], [GunAdi], [BaslangicSaati], [BitisSaati], [Kontenjan], [Statu], [KayitTarihi]) VALUES (63, 1, 17, 1, N'Cuma', CAST(N'14:00:00' AS Time), CAST(N'14:40:00' AS Time), 40, 1, CAST(N'2022-03-29 19:55:43.460' AS DateTime))
SET IDENTITY_INSERT [dbo].[OgretmenDers] OFF
ALTER TABLE [dbo].[OgrenciOgretmenDers]  WITH CHECK ADD  CONSTRAINT [FK_OgrenciOgretmenDers_Ogrenci] FOREIGN KEY([Ogrenci_Id])
REFERENCES [dbo].[Ogrenci] ([Id])
GO
ALTER TABLE [dbo].[OgrenciOgretmenDers] CHECK CONSTRAINT [FK_OgrenciOgretmenDers_Ogrenci]
GO
ALTER TABLE [dbo].[OgrenciOgretmenDers]  WITH CHECK ADD  CONSTRAINT [FK_OgrenciOgretmenDers_OgretmenDers] FOREIGN KEY([OgretmenDers_Id])
REFERENCES [dbo].[OgretmenDers] ([Id])
GO
ALTER TABLE [dbo].[OgrenciOgretmenDers] CHECK CONSTRAINT [FK_OgrenciOgretmenDers_OgretmenDers]
GO
ALTER TABLE [dbo].[OgretmenDers]  WITH CHECK ADD  CONSTRAINT [FK_OgretmenDers_Ders] FOREIGN KEY([Ders_Id])
REFERENCES [dbo].[Ders] ([Id])
GO
ALTER TABLE [dbo].[OgretmenDers] CHECK CONSTRAINT [FK_OgretmenDers_Ders]
GO
ALTER TABLE [dbo].[OgretmenDers]  WITH CHECK ADD  CONSTRAINT [FK_OgretmenDers_Donem] FOREIGN KEY([Donem_Id])
REFERENCES [dbo].[Donem] ([Id])
GO
ALTER TABLE [dbo].[OgretmenDers] CHECK CONSTRAINT [FK_OgretmenDers_Donem]
GO
ALTER TABLE [dbo].[OgretmenDers]  WITH CHECK ADD  CONSTRAINT [FK_OgretmenDers_Ogretmen] FOREIGN KEY([Ogretmen_Id])
REFERENCES [dbo].[Ogretmen] ([Id])
GO
ALTER TABLE [dbo].[OgretmenDers] CHECK CONSTRAINT [FK_OgretmenDers_Ogretmen]
GO
USE [master]
GO
ALTER DATABASE [Okul] SET  READ_WRITE 
GO
