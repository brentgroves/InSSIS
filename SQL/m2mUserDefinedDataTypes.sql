USE [m2mdata01]
GO
/****** Object:  UserDefinedDataType [dbo].[M2MAddressCity]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MAddressCity] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MAddressCountry]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MAddressCountry] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MAddressKey]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MAddressKey] FROM [char](4) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MAddressPostalCode]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MAddressPostalCode] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MAddressState]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MAddressState] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MAddressStreet]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MAddressStreet] FROM [text] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MBillOfLading]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MBillOfLading] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MBin]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MBin] FROM [varchar](14) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MCommissionRate]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MCommissionRate] FROM [decimal](7, 3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MContactFirst]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MContactFirst] FROM [varchar](15) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MContactLast]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MContactLast] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MCoordinator]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MCoordinator] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MCurrencyConversionE2F]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MCurrencyConversionE2F] FROM [decimal](17, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MCurrencyConversionFactor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MCurrencyConversionFactor] FROM [decimal](17, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MCurrencyType]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MCurrencyType] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MCustomerPurchaseOrderNumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MCustomerPurchaseOrderNumber] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDiscountRate]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDiscountRate] FROM [decimal](7, 3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberCustomer]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberCustomer] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberDistributor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberDistributor] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberGeneric]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberGeneric] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberIDO]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberIDO] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberISO]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberISO] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberJobOrder]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberJobOrder] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberPurchaseOrder]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberPurchaseOrder] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberPurchaseOrderRevision]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberPurchaseOrderRevision] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberQuote]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberQuote] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberQuoteRevision]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberQuoteRevision] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberReceiver]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberReceiver] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberSalesOrder]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberSalesOrder] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberSalesOrderRevision]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberSalesOrderRevision] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberShipper]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberShipper] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocNumberVendor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocNumberVendor] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDocumentStatus]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDocumentStatus] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MDrawingNumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MDrawingNumber] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MECONumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MECONumber] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MEMailAddress]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MEMailAddress] FROM [varchar](128) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MEstimator]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MEstimator] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MFacility]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MFacility] FROM [char](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MFreightCarrier]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MFreightCarrier] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MFreightClass]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MFreightClass] FROM [varchar](12) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MFreightOnBoard]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MFreightOnBoard] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericCheckBoxBit]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericCheckBoxBit] FROM [bit] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericCheckBoxText]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericCheckBoxText] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericCostPrice]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericCostPrice] FROM [decimal](17, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericDate]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericDate] FROM [datetime] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericFreeFormText]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericFreeFormText] FROM [text] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericImage]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericImage] FROM [image] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericInteger]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericInteger] FROM [int] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericOptionGroup]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericOptionGroup] FROM [tinyint] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericQuantity]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericQuantity] FROM [decimal](15, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGenericRowGUID]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGenericRowGUID] FROM [uniqueidentifier] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGLAccount]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGLAccount] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGLAccountDescription]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGLAccountDescription] FROM [varchar](40) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MGroupCode]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MGroupCode] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MItemNumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MItemNumber] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MItemNumberBOM]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MItemNumberBOM] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MItemSource]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MItemSource] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MLeadTime]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MLeadTime] FROM [numeric](7, 1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MLocation]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MLocation] FROM [varchar](14) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MLotControlExtent]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MLotControlExtent] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MMoney]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MMoney] FROM [numeric](17, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MOperationNumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MOperationNumber] FROM [tinyint] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MOrganizationName]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MOrganizationName] FROM [varchar](35) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPackingList]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPackingList] FROM [varchar](15) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartDescription]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartDescription] FROM [varchar](1024) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartDescriptionCustomer]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartDescriptionCustomer] FROM [varchar](35) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartDescriptionVendor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartDescriptionVendor] FROM [varchar](35) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartNumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartNumber] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartNumberCustomer]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartNumberCustomer] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartNumberVendor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartNumberVendor] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartRevision]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartRevision] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPartRevisionCustomer]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPartRevisionCustomer] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPath]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPath] FROM [varchar](128) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPaymentTerms]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPaymentTerms] FROM [char](4) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPaymentType]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPaymentType] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPhone]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPhone] FROM [char](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPlanner]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPlanner] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPriceSchedule]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPriceSchedule] FROM [char](6) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPriceScheduleType]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPriceScheduleType] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MProductClass]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MProductClass] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MPurchaseCategory]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MPurchaseCategory] FROM [char](8) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MQuantityTolerance]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MQuantityTolerance] FROM [decimal](7, 3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MReleaseNumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MReleaseNumber] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MRMANumber]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MRMANumber] FROM [varchar](25) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MSalesCode]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MSalesCode] FROM [char](7) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MSalesPerson]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MSalesPerson] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MShipVia]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MShipVia] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MTaxJurisdiction]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MTaxJurisdiction] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MTaxRate]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MTaxRate] FROM [decimal](8, 3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MTerritory]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MTerritory] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFChr1]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFChr1] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFChr2]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFChr2] FROM [varchar](40) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFChr3]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFChr3] FROM [varchar](40) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFCurrency1]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFCurrency1] FROM [decimal](17, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFDate1]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFDate1] FROM [datetime] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFFreeFormText1]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFFreeFormText1] FROM [text] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUDFQty1]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUDFQty1] FROM [decimal](15, 5) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUnitOfMeasure]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUnitOfMeasure] FROM [char](3) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MUOMConversionFactor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MUOMConversionFactor] FROM [decimal](12, 9) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MWorkCenter]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MWorkCenter] FROM [char](7) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MWorkCenterDescription]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MWorkCenterDescription] FROM [varchar](16) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MYieldFactor]    Script Date: 4/24/2018 7:57:06 AM ******/
CREATE TYPE [dbo].[M2MYieldFactor] FROM [decimal](8, 3) NOT NULL
GO
