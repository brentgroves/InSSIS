VItemPrice.sql
USE [Cribmaster]
GO

/****** Object:  View [dbo].[VItemPrice]    Script Date: 4/19/2018 11:56:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VItemPrice] AS
   SELECT INVENTRY.ItemNumber AS ItemNumber,
          PRICETYPE,
          ITEMTYPE,
          CASE INVENTRY.PRICETYPE
             WHEN NULL THEN ISNULL(ALTVENDOR.COST, 0)
             WHEN 0 THEN ISNULL(INVENTRY.Price, ISNULL(ALTVENDOR.COST, 0))
             WHEN 1 THEN ISNULL(INVENTRY.Price, 1) * ISNULL(ALTVENDOR.COST, 0)
             WHEN 2 THEN ISNULL(INVENTRY.Price, 0) + ISNULL(ALTVENDOR.COST, 0)
             WHEN 3 THEN ISNULL(INVENTRY.Price, ISNULL(ALTVENDOR.COST, 0))
             ELSE ISNULL(ALTVENDOR.COST, 0)
          END AS Price,
          AltVendorNo,
          COST
     FROM INVENTRY LEFT OUTER JOIN ALTVENDOR ON INVENTRY.AltVendorNo = ALTVENDOR.RecNumber
GO