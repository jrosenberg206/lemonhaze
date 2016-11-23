
#CREATE SCHEMA merged_rpt;

/**********************************************************************
 * ETL CONTROL
*/
DROP TABLE IF EXISTS merged_rpt.dim_etl_control;
CREATE TABLE merged_rpt.dim_etl_control
(
  etlkey INT NOT NULL AUTO_INCREMENT,
  etlname VARCHAR(100) NOT NULL,
  etlbypassindicator INT NOT NULL,
  useoverridedatesindicator INT NOT NULL,
  overridestartdate DATETIME NOT NULL,
  overrideenddate DATETIME NOT NULL,
  etldescription VARCHAR(100) NULL,
  PRIMARY KEY (etlkey)
) AUTO_INCREMENT = 0;

INSERT INTO merged_rpt.dim_etl_control (etlname, etlbypassindicator, useoverridedatesindicator, overridestartdate, overrideenddate, etldescription)
VALUES ('refresh retail data',0,0,'2016-07-01 00:00:00','2016-07-02 00:00:00','refresh retail dashboard data');

SELECT * FROM merged_rpt.dim_etl_control;


/**********************************************************************
 * DELETED TYPE
*/
DROP TABLE IF EXISTS merged_rpt.dim_deletedtype;
CREATE TABLE merged_rpt.dim_deletedtype
(
  deletedtypeid INT NOT NULL AUTO_INCREMENT,
  deletedindicator INT NULL,
  isdeleted VARCHAR(7) NOT NULL,
  deleteddescription VARCHAR(25),
  PRIMARY KEY (deletedtypeid)
) AUTO_INCREMENT = 0;

INSERT INTO merged_rpt.dim_deletedtype (deletedindicator, isdeleted, deleteddescription)
VALUES
  (NULL,'Unknown','Unknown'),
  (0,'No','Not Deleted'),
  (1,'Yes','Deleted');


/**********************************************************************
 * INVENTORY GROUP
*/
CREATE TABLE merged_rpt.dim_inventorygroup
(
  inventorygroupid INT NOT NULL AUTO_INCREMENT,
  inventorygroup VARCHAR(100) NOT NULL,
  PRIMARY KEY (inventorygroupid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_inventorygroup (inventorygroup)
VALUES ('Unknown');

INSERT INTO merged_rpt.dim_inventorygroup (inventorygroup)
VALUES
  ('Edible'),
  ('Extract'),
  ('Flower'),
  ('Kief'),
  ('Marijuana Mix'),
  ('Marijuana Mix Infused'),
  ('Marijuana Mix Packaged'),
  ('Plant'),
  ('Sample'),
  ('Seed'),
  ('Topical'),
  ('Trim'),
  ('Waste');


/**********************************************************************
 * INVENTORY TYPE
*/
DROP TABLE IF EXISTS merged_rpt.dim_inventorytype;
CREATE TABLE merged_rpt.dim_inventorytype
(
  inventorytypeid INT NOT NULL AUTO_INCREMENT,
  inventorytype INT NULL,
  inventorytypedesc VARCHAR(100) NULL,
  inventorygroupid INT NOT NULL,
  PRIMARY KEY (inventorytypeid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_inventorytype (inventorytype, inventorytypedesc, inventorygroupid)
VALUES (NULL,'Unknown',1);

INSERT INTO merged_rpt.dim_inventorytype (inventorytype, inventorytypedesc, inventorygroupid)
VALUES
  (5, 'Kief', 5),
  (6, 'Flower', 4),
  (7, 'Clone', 9),
  (9, 'Other Plant Material (stems, leaves, etc to be processed),', 13),
  (10, 'Seed', 11),
  (11, 'Plant Tissue', 9),
  (12, 'Mature Plant', 9),
  (13, 'Flower Lot', 4),
  (14, 'Other Plant Material Lot', 13),
  (15, 'Bubble Hash', 3),
  (16, 'Hash', 3),
  (17, 'Hydrocarbon Wax', 3),
  (18, 'CO2 Hash Oil', 3),
  (19, 'Food Grade Solvent Extract', 2),
  (20, 'Infused Dairy Butter or Fat in Solid Form', 2),
  (21, 'Infused Cooking Oil', 2),
  (22, 'Solid Marijuana Infused Edible', 2),
  (23, 'Liquid Marijuana Infused Edible', 2),
  (24, 'Marijuana Extract for Inhalation', 3),
  (25, 'Marijuana Infused Topicals', 12),
  (26, 'Sample Jar', 10),
  (27, 'Waste', 14),
  (28, 'Usable Marijuana', 4),
  (29, 'Wet Flower', 4),
  (30, 'Marijuana Mix', 6),
  (31, 'Marijuana Mix Packaged', 7),
  (32, 'Marijuana Mix Infused', 8);


/**********************************************************************
 * MEDICAL TYPE
*/
DROP TABLE IF EXISTS merged_rpt.dim_medicaltype;
CREATE TABLE merged_rpt.dim_medicaltype
(
  medicaltypeid INT NOT NULL AUTO_INCREMENT,
  medicalindicator TINYTEXT NULL,
  ismedical VARCHAR(7) NOT NULL,
  medicaldescription VARCHAR(25),
  PRIMARY KEY (medicaltypeid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_medicaltype (medicalindicator, ismedical, medicaldescription)
VALUES
  (NULL,'Unknown','Unknown'),
  ('0','No','Not Medical'),
  ('1','Yes','Is Medical');


/**********************************************************************
 * REFUND TYPE
*/
DROP TABLE IF EXISTS merged_rpt.dim_refundtype;
CREATE TABLE merged_rpt.dim_refundtype
(
  refundtypeid INT NOT NULL AUTO_INCREMENT,
  refundindicator TINYTEXT NULL,
  isrefund VARCHAR(7) NOT NULL,
  refunddescription VARCHAR(25),
  PRIMARY KEY (refundtypeid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_refundtype (refundindicator, isrefund, refunddescription)
VALUES
  (NULL,'Unknown','Unknown'),
  (0,'No','No Refund'),
  (1,'Yes','Refunded');


/**********************************************************************
 * SAMPLE TYPE
*/
DROP TABLE IF EXISTS merged_rpt.dim_sampletype;
CREATE TABLE merged_rpt.dim_sampletype
(
  sampletypeid INT NOT NULL AUTO_INCREMENT,
  sampleindicator TINYTEXT NULL,
  issample VARCHAR(7) NOT NULL,
  sampledescription VARCHAR(25),
  PRIMARY KEY (sampletypeid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_sampletype (sampleindicator, issample, sampledescription)
VALUES
  (NULL,'Unknown','Unknown'),
  (0,'No','Not Sample'),
  (1,'Yes','Is Sample');


/**********************************************************************
 * STRAIN (source is [merged].[inventory] table)
*/
DROP TABLE IF EXISTS merged_rpt.dim_strain;
CREATE TABLE merged_rpt.dim_strain
(
  strainid INT NOT NULL AUTO_INCREMENT,
  strainname VARCHAR(100) NULL,
  PRIMARY KEY (strainid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_strain (strainname)
VALUES('Unknown');

INSERT INTO merged_rpt.dim_strain (strainname)
SELECT DISTINCT TRIM(REPLACE(REPLACE(REPLACE(REPLACE(i.strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) AS strainname
FROM merged.inventory i
WHERE 1=1
  AND NOT TRIM(REPLACE(REPLACE(REPLACE(REPLACE(i.strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) IS NULL
ORDER BY
  TRIM(REPLACE(REPLACE(REPLACE(REPLACE(i.strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) ASC;


/**********************************************************************
 * USABLE WEIGHT (built in Excel and imported as CSV file)
*/
DROP TABLE IF EXISTS merged_rpt.dim_usableweight;
CREATE TABLE merged_rpt.dim_usableweight
(
  usableweightid INT NOT NULL AUTO_INCREMENT,
  valuestart FLOAT NOT NULL,
  valueend FLOAT NOT NULL,
  usableweightgroup FLOAT NOT NULL,
  packagesize VARCHAR(25),
  PRIMARY KEY (usableweightid)
) AUTO_INCREMENT = 0;

# Good recordset exists in [merged_stg].[dim_usableweight], if not import CSV file.
INSERT INTO merged_rpt.dim_usableweight (valuestart, valueend, usableweightgroup, packagesize)
SELECT
  u.valuestart
  ,u.valueend
  ,u.usableweightgroup
  ,u.packagesize
FROM merged_stg.dim_usableweight u ORDER BY usableweightid;


/**********************************************************************
 * PRODUCT FLAG (TEMP)
*/
DROP TABLE IF EXISTS merged_rpt.dim_productflag_temp;
CREATE TABLE merged_rpt.dim_productflag_temp
(
  productflagid INT NOT NULL AUTO_INCREMENT,
  productflag VARCHAR(25),
  PRIMARY KEY(productflagid)
) AUTO_INCREMENT = 0;

# Insert 'Unknown' record
INSERT INTO merged_rpt.dim_productflag_temp (productflag)
VALUES ('Unknown');

INSERT INTO merged_rpt.dim_productflag_temp (productflag)
VALUES
  ('BHO'),
  ('CO2'),
  ('EZ Vape'),
  ('Interra'),
  ('JuJu'),
  ('Liberty'),
  ('Other');

CREATE INDEX ix_dpft_productflag ON merged_rpt.dim_productflag_temp (productflag);


/**********************************************************************
 * PRODUCT TYPE
*/
DROP TABLE IF EXISTS merged_rpt.dim_producttype;
CREATE TABLE merged_rpt.dim_producttype
(
  producttypeid INT NOT NULL AUTO_INCREMENT,
  producttype VARCHAR(25),
  PRIMARY KEY(producttypeid)
) AUTO_INCREMENT = 0;

# Insert 'Uknown' record
INSERT INTO merged_rpt.dim_producttype (producttype)
VALUES ('Unknown');

INSERT INTO merged_rpt.dim_producttype (producttype)
VALUES
  ('Applicator'),
  ('Cartridge'),
  ('Caviar'),
  ('Dab'),
  ('E-Cig'),
  ('Hash'),
  ('Kief'),
  ('Pre-Pack'),
  ('Pre-Roll'),
  ('Rosin'),
  ('Shatter'),
  ('Wax');

CREATE INDEX ix_dpt_producttypeid ON merged_rpt.dim_producttype (producttypeid);


/**********************************************************************
 * PRODUCT ATTRIBUTE
*/
DROP TABLE IF EXISTS merged_rpt.dim_productattribute;
CREATE TABLE merged_rpt.dim_productattribute
(
  productflagid INT NOT NULL AUTO_INCREMENT,
  bho_ind INT NOT NULL,
  co2_ind INT NOT NULL,
  juju_ind INT NOT NULL,
  liberty_ind INT NOT NULL,
  ezvape_ind INT NOT NULL,
  interra_ind INT NOT NULL,
  PRIMARY KEY(productflagid)
) AUTO_INCREMENT = 0;

CREATE INDEX ix_dpa_productflagid ON merged_rpt.dim_productattribute (productflagid);


/**********************************************************************
 * ZIP BY TAX (Excel file imported as CSV file)
*/
DROP TABLE IF EXISTS merged_rpt.dim_taxbyzip;
CREATE TABLE merged_rpt.dim_taxbyzip
(
  zip INT NOT NULL,
  county VARCHAR(100) NULL,
  estimatedcombinedcost FLOAT NOT NULL,
  excisetax FLOAT NOT NULL,
  PRIMARY KEY(zip)
);
INSERT INTO merged_rpt.dim_taxbyzip (zip, county, estimatedcombinedcost, excisetax)
SELECT
  tbz.zip
  ,tbz.county
  ,tbz.estimated_combined_cost
  ,tbz.excise_tax
FROM merged_stg.tax_by_zip tbz;

CREATE INDEX ix_tbz_zip ON merged_rpt.dim_taxbyzip (zip);


/**********************************************************************
 * LOCATION (DIMENSION)
*/
DROP TABLE IF EXISTS merged_rpt.dim_location;
CREATE TABLE merged_rpt.dim_location
(
  organizationid INT NOT NULL,
  locationindex INT NOT NULL,
  locationname VARCHAR(100) NOT NULL,
  address1 VARCHAR(100) NULL,
  address2 VARCHAR(100) NULL,
  city VARCHAR(50) NULL,
  state VARCHAR(2) NULL,
  zip INT NULL,
  zipplus4 INT NULL,
  deleted INT NULL,
  locationtype INT NULL,
  licensenumber INT NOT NULL,
  locationid INT NOT NULL,
  locationexp_pst DATETIME NULL,
  locationissue_pst DATETIME NULL,
  locationstatus VARCHAR(100) NULL,
  districtcode VARCHAR(10) NULL,
  latitude DECIMAL(15,7) NULL,
  longitude DECIMAL(15,7) NULL,
  mailaddress1 VARCHAR(100) NULL,
  mailaddress2 VARCHAR(100) NULL,
  mailcity VARCHAR(50) NULL,
  mailstate VARCHAR(2) NULL,
  mailzip INT NULL,
  mailzipplus4 INT NULL,
  locationubi INT NOT NULL,
  producer INT NULL,
  processor INT NULL,
  retail INT NULL,
  transactionid INT NULL,
  transactionid_original INT NULL,
  fifteenday_end_pst DATETIME,
  delete_time_pst DATETIME
);
INSERT INTO merged_rpt.dim_location (organizationid,locationindex,locationname,address1,address2,city,state,zip,zipplus4
  ,deleted,locationtype,licensenumber,locationid,locationexp_pst,locationissue_pst,locationstatus
  ,districtcode,latitude,longitude,mailaddress1,mailaddress2,mailcity,mailstate,mailzip,mailzipplus4,locationubi
  ,producer,processor,retail,transactionid,transactionid_original,fifteenday_end_pst,delete_time_pst)
SELECT
  orgid
  ,locationid
  ,name
  ,address1
  ,address2
  ,city
  ,state
  ,CASE WHEN CHAR_LENGTH(zip) > 5 THEN LEFT(zip,5) ELSE zip END
  ,zip
  ,deleted
  ,locationtype
  ,licensenum
  ,id AS locationid
  ,IFNULL(CONVERT_TZ(FROM_UNIXTIME(locationexp),'UTC','US/Pacific'),NULL)
  ,IFNULL(CONVERT_TZ(FROM_UNIXTIME(locationissue),'UTC','US/Pacific'),NULL)
  ,status
  ,districtcode
  ,loclatitude
  ,loclongitude
  ,mailaddress1
  ,mailaddress2
  ,mailcity
  ,mailstate
  ,CASE WHEN CHAR_LENGTH(mailzip) > 5 THEN LEFT(mailzip,5) ELSE mailzip END
  ,mailzip
  ,locubi
  ,producer
  ,processor
  ,retail
  ,transactionid
  ,transactionid_original
  ,IFNULL(CONVERT_TZ(fifteenday_end,'UTC','US/Pacific'),NULL)
  ,IFNULL(CONVERT_TZ(delete_time,'UTC','US/Pacific'),NULL)
FROM state201608.biotrackthc_locations;

CREATE INDEX ix_l_organizationid ON merged_rpt.dim_location (organizationid);
CREATE INDEX ix_l_licensenumber ON merged_rpt.dim_location (licensenumber);
CREATE INDEX ix_l_zip ON merged_rpt.dim_location (zip);


/**********************************************************************
 * ORGANIZATION (DIMENSION)
*/
DROP TABLE IF EXISTS merged_rpt.dim_organization;
CREATE TABLE merged_rpt.dim_organization
(
  organizationname VARCHAR(100) NOT NULL,
  organizationid INT NOT NULL,
  activeindicator INT NOT NULL,
  organizationubi INT NOT NULL,
  fifteendaystart DATETIME NOT NULL,
  statusindicator INT NOT NULL
);
INSERT INTO merged_rpt.dim_organization
  (organizationname,organizationid,activeindicator,organizationubi,fifteendaystart,statusindicator)
SELECT
  orgname
  ,orgid
  ,orgactive
  ,orglicense
  ,IFNULL(CONVERT_TZ(fifteendaystart,'UTC','US/Pacific'),NULL)
  ,orgstatus
FROM state201608.biotrackthc_organizations;


/**********************************************************************
 * LOCATION (VIEW)
*/
DROP VIEW IF EXISTS merged_rpt.v_location;
CREATE VIEW merged_rpt.v_location AS
SELECT
  #IFNULL(o.organizationname,l.locationname) AS organizationname
  #,IFNULL(o.organizationubi,l.locationubi) AS organizationubi
  #,IFNULL(o.organizationid,l.organizationid) AS organizationid
  #,CASE WHEN o.organizationid IS NULL THEN 'Yes' ELSE 'No' END AS missingorganizationinfo
  #l.locationid
  #l.locationindex AS location_index
  l.locationname AS organizationname
  ,l.licensenumber AS license_number
  ,l.locationubi AS location_ubi
  ,l.address1
  #,l.address2
  ,l.city
  ,l.state
  ,l.zip AS zip_code
  #,CONCAT_WS(', ',l.address1, l.city, l.state, l.zip) AS fulladdress
  #,l.deleted
  #,l.locationtype
  #,l.locationstatus
  ,l.districtcode AS district_code
  ,l.latitude
  ,l.longitude
  ,CASE
    WHEN l.producer = 1 AND l.processor = 1 THEN 'Producer/Processor'
    WHEN l.producer = 1 THEN 'Producer'
    WHEN l.processor = 1 THEN 'Processor'
    WHEN l.retail = 1 THEN 'Retailer'
    ELSE 'Unknown Business Type'
  END AS businesstype
FROM
  merged_rpt.dim_location l;
  #LEFT JOIN merged_rpt.dim_organization o ON l.organizationid = o.organizationid
#ORDER BY
  #o.organizationname
  #,l.locationindex;


/**********************************************************************
 * RETAILER (VIEW)
*/
DROP VIEW IF EXISTS merged_rpt.v_retailer;
CREATE VIEW merged_rpt.v_retailer AS
SELECT
  #IFNULL(o.organizationname,l.locationname) AS organizationname
  #,IFNULL(o.organizationubi,l.locationubi) AS organizationubi
  #,IFNULL(o.organizationid,l.organizationid) AS organizationid
  #,CASE WHEN o.organizationid IS NULL THEN 'Yes' ELSE 'No' END AS missingorganizationinfo
  #,l.locationid
  #,l.locationindex
  l.locationname AS organizationname
  ,l.licensenumber AS license_number
  ,l.locationubi AS location_ubi
  ,l.address1
  #,l.address2
  ,l.city
  ,l.state
  ,l.zip
  #,CONCAT_WS(', ',l.address1, l.city, l.state, l.zip) AS fulladdress
  #,l.deleted
  #,l.locationtype
  #,l.locationstatus
  ,l.districtcode AS district_code
  ,l.latitude
  ,l.longitude
  ,CASE
    WHEN l.producer = 1 AND l.processor = 1 THEN 'Producer/Processor'
    WHEN l.producer = 1 THEN 'Producer'
    WHEN l.processor = 1 THEN 'Processor'
    WHEN l.retail = 1 THEN 'Retailer'
    ELSE 'Unknown Business Type'
  END AS businesstype
FROM
  merged_rpt.dim_location l
  #LEFT JOIN merged_rpt.dim_organization o ON l.organizationid = o.organizationid
WHERE 1=1
  AND l.retail = 1;
#ORDER BY
  #o.organizationname
  #,l.locationindex;


/**********************************************************************
 * PRODUCER/PROCESSOR (VIEW)
*/
DROP VIEW IF EXISTS merged_rpt.v_producerprocessor;
CREATE VIEW merged_rpt.v_producerprocessor AS
SELECT
  #IFNULL(o.organizationname,l.locationname) AS organizationname
  #,IFNULL(o.organizationubi,l.locationubi) AS organizationubi
  #,IFNULL(o.organizationid,l.organizationid) AS organizationid
  #,CASE WHEN o.organizationid IS NULL THEN 'Yes' ELSE 'No' END AS missingorganizationinfo
  #,l.locationid
  #,l.locationindex
  l.locationname AS organizationname
  ,l.licensenumber AS license_number
  ,l.locationubi AS location_ubi
  ,l.address1
  #,l.address2
  ,l.city
  ,l.state
  ,l.zip
  #,CONCAT_WS(', ',l.address1, l.city, l.state, l.zip) AS fulladdress
  #,l.deleted
  #,l.locationtype
  #,l.locationstatus
  ,l.districtcode AS district_code
  ,l.latitude
  ,l.longitude
  ,CASE
    WHEN l.producer = 1 AND l.processor = 1 THEN 'Producer/Processor'
    WHEN l.producer = 1 THEN 'Producer'
    WHEN l.processor = 1 THEN 'Processor'
    WHEN l.retail = 1 THEN 'Retailer'
    ELSE 'Unknown Business Type'
  END AS businesstype
FROM
  merged_rpt.dim_location l
  #LEFT JOIN merged_rpt.dim_organization o ON l.organizationid = o.organizationid
WHERE 1=1
  AND (l.producer = 1 OR l.processor = 1);
#ORDER BY
  #o.organizationname
  #,l.locationindex;


/**********************************************************************
 * INVENTORY
*/
DROP TABLE IF EXISTS merged_rpt.inventory;
CREATE TABLE merged_rpt.inventory AS
SELECT
  i.currentroom
  ,i.deleted AS deletedindicator
  ,i.id AS inventoryid
  ,i.inventoryparentid
  ,i.inventorystatustime
  ,IFNULL(CONVERT_TZ(i.inventorystatustime,'UTC','US/Pacific'),NULL) AS inventorystatustime_pst
  ,i.inventorytype AS inventorytypeid
  ,i.is_medical AS ismedical
  ,i.is_sample AS issample
  ,i.location
  ,i.net_package AS netpackage
  ,i.parentid
  ,i.plantid
  ,i.productname
  ,i.remaining_quantity
  ,i.seized
  ,i.sessiontime
  ,IFNULL(CONVERT_TZ(i.sessiontime,'UTC','US/Pacific'),NULL) AS sessiontime_pst
  ,i.source_id AS sourceid
  ,i.strain
  ,i.transactionid
  ,i.transactionid_original
  ,i.usable_weight AS usableweight
  ,i.wet
FROM
(
  SELECT DISTINCT
    currentroom
    ,deleted
    ,id
    ,inventoryparentid
    ,inventorystatus
    ,inventorystatustime
    ,inventorytype
    ,is_medical
    ,is_sample
    ,location
    ,net_package
    ,parentid
    ,plantid
    ,productname
    ,remaining_quantity
    ,seized
    ,sessiontime
    ,source_id
    ,TRIM(REPLACE(REPLACE(REPLACE(REPLACE(strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) AS strain
    ,transactionid
    ,transactionid_original
    ,usable_weight
    ,wet
  FROM
    merged.inventory
) i;

# Check for dups
SELECT
  i.inventoryid
  ,COUNT(*) AS rec_cnt
FROM
  merged_rpt.inventory i
GROUP BY
  i.inventoryid
HAVING
  COUNT(*)>1;

CREATE INDEX ix_i_inventoryid ON merged_rpt.inventory (inventoryid);
CREATE INDEX ix_i_inventorystatustime_pst ON merged_rpt.inventory (inventorystatustime_pst);


/**********************************************************************
 * INVENTORY TRANSFER INBOUND
*/
DROP TABLE IF EXISTS merged_rpt.inventory_transfer_inbound;
CREATE TABLE merged_rpt.inventory_transfer_inbound AS
SELECT
  iti.deleted
  ,iti.inventoryid
  ,iti.inventorytype
  ,iti.is_refund AS refundindicator
  ,iti.location
  ,iti.manifest_stop AS manifeststop
  ,iti.manifestid
  ,iti.outbound_license AS outboundlicense
  ,iti.price
  ,iti.quantity
  ,iti.refund_amount AS refundamount
  ,iti.sessiontime
  ,IFNULL(CONVERT_TZ(iti.sessiontime,'UTC','US/Pacific'),NULL) AS sessiontime_pst
  ,iti.strain
  ,iti.transactionid
  ,iti.transactionid_original
FROM
  (
    SELECT DISTINCT
      deleted
      ,inventoryid
      ,inventorytype
      ,is_refund
      ,location
      ,manifest_stop
      ,manifestid
      ,outbound_license
      ,price
      ,quantity
      ,refund_amount
      ,sessiontime
      ,TRIM(REPLACE(REPLACE(REPLACE(REPLACE(strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) AS strain
      ,transactionid
      ,transactionid_original
    FROM
      merged.inventory_transfer_inbound
  ) iti;

CREATE INDEX ix_iti_inventoryid ON merged_rpt.inventory_transfer_inbound (inventoryid);
CREATE INDEX ix_iti_sessiontime_pst ON merged_rpt.inventory_transfer_inbound (sessiontime_pst);


/**********************************************************************
 * INVENTORY TRANSFER
*/
DROP TABLE IF EXISTS merged_rpt.inventory_transfer;
CREATE TABLE merged_rpt.inventory_transfer AS
SELECT
  it.deleted
  ,it.inventoryid
  ,it.inventorytype
  ,it.is_refund AS refundindicator
  ,it.location
  ,it.manifest_stop AS manifeststop
  ,it.manifestid
  ,it.outbound_license AS outboundlicense
  ,it.price
  ,it.quantity
  ,it.sessiontime
  ,IFNULL(CONVERT_TZ(it.sessiontime,'UTC','US/Pacific'),NULL) AS sessiontime_pst
  ,it.strain
  ,it.transactionid
  ,it.transactionid_original
FROM
  (
    SELECT DISTINCT
      deleted
      ,inventoryid
      ,inventorytype
      ,is_refund
      ,location
      ,manifest_stop
      ,manifestid
      ,outbound_license
      ,price
      ,quantity
      ,sessiontime
      ,TRIM(REPLACE(REPLACE(REPLACE(REPLACE(strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) AS strain
      ,transactionid
      ,transactionid_original
    FROM
      merged.inventory_transfer
  ) it;

CREATE INDEX ix_it_inventoryid ON merged_rpt.inventory_transfer (inventoryid);
CREATE INDEX ix_it_sessiontime_pst ON merged_rpt.inventory_transfer (sessiontime_pst);


/**********************************************************************
 * MANIFEST STOP ITEMS
*/
DROP TABLE IF EXISTS merged_rpt.manifest_stop_items;
CREATE TABLE merged_rpt.manifest_stop_items AS
SELECT
  msi.deleted
  ,msi.description
  ,msi.inventoryid
  ,msi.location
  ,msi.manifestid
  ,msi.quantity
  ,msi.requiresweighing
  ,msi.sessiontime
  ,IFNULL(CONVERT_TZ(msi.sessiontime,'UTC','US/Pacific'),NULL) AS sessiontime_pst
  ,msi.stopnumber
  ,msi.transactionid
  ,msi.transactionid_original
FROM
  (
    SELECT DISTINCT
      deleted
      ,description
      ,inventoryid
      ,location
      ,manifestid
      ,quantity
      ,requiresweighing
      ,sessiontime
      ,stopnumber
      ,transactionid
      ,transactionid_original
    FROM
      merged.manifest_stop_items
  ) msi;

CREATE INDEX ix_msi_manifestid ON merged_rpt.manifest_stop_items (manifestid);
CREATE INDEX ix_msi_inventoryid ON merged_rpt.manifest_stop_items (inventoryid);
CREATE INDEX ix_msi_sessiontime_pst ON merged_rpt.manifest_stop_items (sessiontime_pst);


/**********************************************************************
 * PRODUCT - TEMP (DIMENSION)
*/
DROP TABLE IF EXISTS merged_rpt.dim_product_temp;
CREATE TABLE merged_rpt.dim_product_temp AS
SELECT DISTINCT
  i.inventoryid
  ,TRIM(REPLACE(i.productname, '"', '')) AS productname
  ,CASE
		WHEN dit.inventorytype = 31 THEN
			CASE WHEN (INSTR(LOWER(i.productname),'cone')) > 0 THEN 'Pre-Roll' ELSE 'Product Type TBD' END
		WHEN dit.inventorytype = 32 THEN
			CASE WHEN (INSTR(LOWER(i.productname),'cone')) > 0 THEN 'Pre-Roll' ELSE 'Product Type TBD' END
    WHEN dit.inventorytype = 24 THEN
      CASE
      # PRE-ROLL (CONE)
      WHEN (INSTR(LOWER(i.productname),'cone')) > 0 THEN 'Pre-Roll'
      # E-CIG
      WHEN (INSTR(LOWER(i.productname),'ezvape') + INSTR(LOWER(i.productname),'ez vape') +
        INSTR(LOWER(i.productname),'rosta stiix') + INSTR(LOWER(i.productname),'rosta stix') +
        INSTR(LOWER(i.productname),'rasta stiix') + INSTR(LOWER(i.productname),'rasta stix') +
        INSTR(LOWER(i.productname),'ez-vape') + INSTR(LOWER(i.productname),'juju')) > 0 THEN 'E-Cig'
      # KIEF
      WHEN (INSTR(LOWER(i.productname),'kief') + INSTR(LOWER(i.productname),'keif')) > 0 THEN 'Kief'
      # CAVIAR
      WHEN (INSTR(LOWER(i.productname),'caviar')) > 0 THEN 'Caviar'
      # WAX
      WHEN (INSTR(LOWER(i.productname),'wax')) > 0 THEN 'Wax'
      # ROSIN
      WHEN (INSTR(LOWER(i.productname),'rosin') + INSTR(LOWER(i.productname),'roslin') +
        INSTR(LOWER(i.productname),'resin') + INSTR(LOWER(i.productname),'rosen')) > 0 THEN 'Rosin'
      # APPLICATOR
      WHEN (INSTR(LOWER(i.productname),'appli') + INSTR(LOWER(i.productname),'syringe') +
        INSTR(LOWER(i.productname),'refill') + INSTR(LOWER(i.productname),'tanker')) > 0 THEN 'Applicator'
      # CARTRIDGE
      WHEN (INSTR(LOWER(i.productname),'cart') + INSTR(LOWER(i.productname),'oil') +
        INSTR(LOWER(i.productname),'vape') + INSTR(LOWER(i.productname),'co2') +
        INSTR(LOWER(i.productname),'dabulator') + INSTR(LOWER(i.productname),'atomizer') +
        INSTR(LOWER(i.productname),'disposable') + INSTR(LOWER(i.productname),'vapo')) > 0 THEN 'Cartridge'
      # HASH
      WHEN (INSTR(LOWER(i.productname),'hash')) > 0 THEN 'Hash'
      # SHATTER
      WHEN (INSTR(LOWER(i.productname),'shat')) > 0 THEN 'Shatter'
      # DAB
      WHEN (INSTR(LOWER(i.productname),'dab')) > 0 THEN 'Dab'
      # OTHER (default to i.productname)
    ELSE 'Product Type TBD' #IFNULL(i.productname, 'Unknown Product Name')
    END
  WHEN dit.inventorytype = 28 THEN
    CASE
      # PRE-ROLL
      WHEN (INSTR(LOWER(i.productname),'pre-roll') + INSTR(LOWER(i.productname),'pre roll') +
        INSTR(LOWER(i.productname),'rollies') + INSTR(LOWER(i.productname),'cone') +
        INSTR(LOWER(i.productname),'preroll') + INSTR(LOWER(i.productname),'joint')) > 0 THEN 'Pre-Roll'
      # PRE-PACK
      WHEN (INSTR(LOWER(i.productname),'pre-pack') + INSTR(LOWER(i.productname),'pre pack') +
        INSTR(LOWER(i.productname),'prepack')) > 0 THEN 'Pre-Pack'
      # OTHER (default to i.productname)
      ELSE 'Product Type TBD' #IFNULL(i.productname, 'Unknown Product Name')
    END
  ELSE 'Product Type TBD'
  END AS producttype
  ,CASE
    #WHEN (INSTR(LOWER(i.productname),'interra')) > 0 THEN 'Interra'
    WHEN (INSTR(LOWER(i.productname),'bho')) > 0 THEN 'BHO'
    WHEN (INSTR(LOWER(i.productname),'co2')) > 0 THEN 'CO2'
    WHEN (INSTR(LOWER(i.productname),'juju')) > 0 THEN 'JuJu'
    WHEN (INSTR(LOWER(i.productname),'liberty r') + INSTR(LOWER(i.productname),'lr')) > 0 THEN 'Liberty'
    WHEN (INSTR(LOWER(i.productname),'ezvape') + INSTR(LOWER(i.productname),'ez-vape') +
      INSTR(LOWER(i.productname),'ez vape')) > 0 THEN 'EZ Vape'
    ELSE 'Other'
  END AS productflag
  ,i.usableweight
  ,IFNULL(ds.strainid,1) AS strainid
  ,IFNULL(dit.inventorytypeid,1) AS inventorytypeid
  ,duw.usableweightid
  ,IFNULL(ddt.deletedtypeid,1) AS deletedtypeid
  ,IFNULL(dmt.medicaltypeid,1) AS medicaltypeid
  ,IFNULL(dst.sampletypeid,1) AS sampletypeid
FROM
  merged_rpt.inventory                    i
  LEFT JOIN merged_rpt.dim_strain         ds    ON i.strain = ds.strainname
  LEFT JOIN merged_rpt.dim_inventorytype  dit   ON i.inventorytypeid = dit.inventorytype
  LEFT JOIN merged_rpt.dim_usableweight   duw   ON CAST(i.usableweight AS DECIMAL(10,4)) BETWEEN duw.valuestart AND duw.valueend
  LEFT JOIN merged_rpt.dim_deletedtype    ddt   ON i.deletedindicator = ddt.deletedindicator
  LEFT JOIN merged_rpt.dim_medicaltype    dmt   ON i.ismedical = dmt.medicalindicator
  LEFT JOIN merged_rpt.dim_sampletype     dst   ON i.issample = dst.sampleindicator
WHERE 1=1;

# Remove duplicate records
DELETE dpt.*
FROM merged_rpt.dim_product_temp dpt
INNER JOIN
  (
    SELECT inventoryid,COUNT(*) AS rec_cnt
    FROM merged_rpt.dim_product_temp
    GROUP BY inventoryid
    HAVING COUNT(*)>1
  ) dups ON dpt.inventoryid = dups.inventoryid AND dpt.strainid = 1;


/**********************************************************************
 * PRODUCT (DIMENSION)
*/
DROP TABLE IF EXISTS merged_rpt.dim_product;
CREATE TABLE merged_rpt.dim_product
(
  inventoryid BIGINT NOT NULL,
  productname VARCHAR(150),
  producttypeid INT NOT NULL,
  productflagid INT NOT NULL,
  usableweight TINYTEXT,
  strainid INT NOT NULL,
  inventorytypeid INT NOT NULL,
  usableweightid INT NOT NULL,
  deletedtypeid INT NOT NULL,
  medicaltypeid INT NOT NULL,
  sampletypeid INT NOT NULL,
  PRIMARY KEY (inventoryid)
) AUTO_INCREMENT = 0;

CREATE INDEX ix_dp_inventoryid ON merged_rpt.dim_product (inventoryid);
CREATE INDEX ix_dp_productname ON merged_rpt.dim_product (productname);

SELECT * FROM merged_rpt.dim_location
# Insert 'Unknown' record first.
INSERT INTO merged_rpt.dim_product (inventoryid, productname, producttypeid, productflagid, usableweight, strainid,
  inventorytypeid, usableweightid, deletedtypeid, medicaltypeid, sampletypeid)
VALUES (0,'Unknown',1,1,0,1,1,0,0,1,1);

SELECT * FROM merged_rpt.dim_product;

# Populate the [merged_rpt].[dim_product] table.
INSERT INTO merged_rpt.dim_product (inventoryid, productname, producttypeid, productflagid, usableweight,
  strainid, inventorytypeid, usableweightid, deletedtypeid, medicaltypeid, sampletypeid)
SELECT
  dpt.inventoryid
  ,dpt.productname
  ,IFNULL(pt.producttypeid,1) AS producttypeid
  ,pft.productflagid
  ,dpt.usableweight
  ,dpt.strainid
  ,dpt.inventorytypeid
  ,IFNULL(dpt.usableweightid,0) AS usableweightid
  ,dpt.deletedtypeid
  ,dpt.medicaltypeid
  ,dpt.sampletypeid
FROM
  merged_rpt.dim_product_temp                 dpt
  LEFT JOIN merged_rpt.dim_producttype        pt    ON dpt.producttype = pt.producttype
  LEFT JOIN merged_rpt.dim_productflag_temp   pft   ON dpt.productflag = pft.productflag
WHERE 1=1;


/**********************************************************************
 * PRODUCT (VIEW)
*/
DROP VIEW IF EXISTS merged_rpt.v_product;
CREATE VIEW merged_rpt.v_product AS
SELECT
  dp.inventoryid
  ,dp.productname
  ,dpt.producttype
  ,dpf.productflag
  ,dp.usableweight
  ,duw.usableweightgroup
  ,duw.packagesize
  ,ds.strainname
  ,dit.inventorytype
  ,dig.inventorygroup
  ,dit.inventorytypedesc
FROM
  merged_rpt.dim_product                    dp
  LEFT JOIN merged_rpt.dim_producttype      dpt   ON dp.producttypeid = dpt.producttypeid
  LEFT JOIN merged_rpt.dim_productflag_temp dpf   ON dp.productflagid = dpf.productflagid
  LEFT JOIN merged_rpt.dim_strain           ds    ON dp.strainid = ds.strainid
  LEFT JOIN merged_rpt.dim_inventorytype    dit   ON dp.inventorytypeid = dit.inventorytypeid
  LEFT JOIN merged_rpt.dim_inventorygroup   dig   ON dit.inventorygroupid = dig.inventorygroupid
  LEFT JOIN merged_rpt.dim_usableweight     duw   ON dp.usableweightid = duw.usableweightid
WHERE 1=1;


/**********************************************************************
 * SALE
*/
DROP TABLE IF EXISTS merged_rpt.sale;
CREATE TABLE merged_rpt.sale AS
SELECT
  s.card_number AS cardnumber
  ,s.deleted
  ,s.inventoryid
  ,s.inventorytype
  ,s.is_medical AS medicalindicator
  ,s.itemnumber
  ,s.location
  ,s.locationubi
  ,s.price
  ,s.quantity
  ,s.refunded
  ,s.sessiontime
  ,s.sessiontime_pst
  ,s.terminal_id AS terminalid
  ,s.transactionid
  ,s.transactionid_original
FROM
  (
    SELECT DISTINCT
      card_number
      ,sale.deleted
      ,inventoryid
      ,inventorytype
      ,is_medical
      ,itemnumber
      ,location
      ,l.locationubi
      ,price
      ,quantity
      ,refunded
      ,sessiontime
      ,IFNULL(CONVERT_TZ(sessiontime,'UTC','US/Pacific'),NULL) AS sessiontime_pst
      ,terminal_id
      ,sale.transactionid
      ,sale.transactionid_original
    FROM
      merged.sale sale
      LEFT JOIN merged_rpt.dim_location l ON location = l.licensenumber
    WHERE 1=1
      AND CONVERT_TZ(sessiontime,'UTC','US/Pacific') >= '2016-07-01 00:00:00'
  ) s;

CREATE INDEX ix_s_inventoryid ON merged_rpt.sale (inventoryid);
CREATE INDEX ix_s_sessiontime_pst ON merged_rpt.sale (sessiontime_pst);


/**********************************************************************
 * INVENTORY TRANSFER INBOUND (for missing [inventoryid] in SALE table
*/

/*
  STEP#01
  Get distinct list of [location] + [inventoryid] based on [merged_stg].[sale] table
  where the [inventoryid] is not found in the [merged_stg].[inventory] table.

  STEP#02
  Get matching records from [merged_stg].[inventory_transfer_inbound] table, based on
  [inventoryid] records known to be missing from the [merged_stg].[inventory] table
  (found in STEP#01 above from the [merged_stg].[sale] table).
 */
DROP TABLE IF EXISTS merged_rpt.z_lookup;
SET @row_number:= 0;
SET @inventoryid:=0;
CREATE TABLE IF NOT EXISTS merged_rpt.z_lookup AS
SELECT
  @row_number:=
    CASE
      WHEN @inventoryid = iti.inventoryid THEN @row_number + 1
      ELSE 1
    END AS row_number
  ,@inventoryid:= iti.inventoryid AS inventory_id
  ,iti.*
FROM
  merged_rpt.inventory_transfer_inbound           iti
  INNER JOIN
  (
    SELECT DISTINCT s.location, s.inventoryid
    FROM merged_rpt.sale s LEFT JOIN merged_rpt.inventory i ON s.inventoryid = i.inventoryid
    WHERE 1=1 AND i.inventoryid IS NULL
  ) msi ON iti.inventoryid = msi.inventoryid AND iti.location = msi.location
ORDER BY iti.inventoryid ASC, iti.sessiontime_pst DESC;

/*
  Create INVENTORY_TRANSFER_INBOUND_LOOKUP
    Only include row_number = 1, which will prevent duplicate records.
 */
DROP TABLE IF EXISTS merged_rpt.inventory_transfer_inbound_lookup;
CREATE TABLE merged_rpt.inventory_transfer_inbound_lookup AS
SELECT * FROM merged_rpt.z_lookup WHERE row_number = 1;

CREATE INDEX ix_itil_inventoryid ON merged_rpt.inventory_transfer_inbound_lookup (inventoryid);
CREATE INDEX ix_itil_location ON merged_rpt.inventory_transfer_inbound_lookup (location);

DROP TABLE IF EXISTS merged_rpt.z_lookup;


/**********************************************************************
 * SALE BY DAY
*/
DROP TABLE IF EXISTS merged_rpt.sale_by_day;
CREATE TABLE merged_rpt.sale_by_day AS
SELECT
  s.location
  ,s.locationubi
  ,s.inventoryid
  ,CAST(s.sessiontime_pst AS DATE) AS date_pst
  ,dt.deletedtypeid
  ,mt.medicaltypeid
  ,rt.refundtypeid
  ,CASE
    WHEN NOT i.inventoryid IS NULL THEN iti.outboundlicense
    ELSE fii.outboundlicense
   END AS outbound_license
  ,CASE
    WHEN NOT i.inventoryid IS NULL THEN CAST((iti.price/iti.quantity) AS DECIMAL(15,4))
    ELSE CAST((fii.price/fii.quantity) AS DECIMAL(15,4))
  END AS costperunit
  ,CASE
    WHEN NOT i.inventoryid IS NULL THEN CAST((SUM(iti.price)/SUM(iti.quantity)*SUM(s.quantity)) AS DECIMAL(15,4))
    ELSE CAST((SUM(fii.price)/SUM(fii.quantity)*SUM(s.quantity)) AS DECIMAL(15,4))
  END AS cogs
  ,SUM(s.price) AS price
  ,SUM(s.quantity) AS quantity
FROM
  merged_rpt.sale                                         s
  LEFT JOIN merged_rpt.dim_deletedtype                    dt    ON s.deleted = dt.deletedindicator
  LEFT JOIN merged_rpt.dim_medicaltype                    mt    ON s.medicalindicator = mt.medicalindicator
  LEFT JOIN merged_rpt.dim_refundtype                     rt    ON IFNULL(s.refunded,0) = rt.refundindicator
  LEFT JOIN merged_rpt.inventory                          i     ON s.inventoryid = i.inventoryid
  LEFT JOIN merged_rpt.inventory_transfer_inbound         iti   ON i.inventoryid = iti.inventoryid
                                                                AND i.inventorystatustime_pst = iti.sessiontime_pst
  LEFT JOIN merged_rpt.inventory_transfer_inbound_lookup  fii   ON  s.location = fii.location
                                                                AND s.inventoryid = fii.inventoryid
WHERE 1=1
  AND s.sessiontime_pst >= '2016-07-01 00:00:00'
  #AND s.sessiontime_pst < '2016-09-03 00:00:00'
  #AND s.location = 415343
GROUP BY 1,2,3,4,5,6,7,8,9;

CREATE INDEX ix_sbd_inventoryid ON merged_rpt.sale_by_day (inventoryid);
CREATE INDEX ix_sbd_date_pst ON merged_rpt.sale_by_day (date_pst);
CREATE INDEX ix_sbd_location ON merged_rpt.sale_by_day (location);
CREATE INDEX ix_sbd_locationubi ON merged_rpt.sale_by_day (locationubi);
CREATE INDEX ix_sbd_outboundlicense ON merged_rpt.sale_by_day (outbound_license);

DROP VIEW merged_rpt.v_tableauusers;
CREATE VIEW merged_rpt.v_tableauusers AS
SELECT * FROM merged_rpt.dim_tableauusers;
CREATE INDEX ix_dtu_locationubi ON merged_rpt.dim_tableauusers (locationubi);

INSERT INTO merged_rpt.dim_tableauusers (username, license_number, locationubi)
VALUES
  ('jimmyrosenberg@live.com',412882,603307463),
  ('contact@tetratrak.com',412882,603307463),
  ('martyfeltson@gmail.com',412882,603307463);



DROP VIEW IF EXISTS merged_rpt.v_data_as_of;
CREATE VIEW merged_rpt.v_data_as_of AS
SELECT
  CASE
    WHEN r.organizationname IS NULL
    THEN pp.organizationname
    ELSE r.organizationname
  END AS organization_name
  ,MAX(s.sessiontime_pst) AS data_as_of
FROM
  merged_rpt.sale s
  LEFT JOIN merged_rpt.v_retailer r ON s.location = r.license_number
  LEFT JOIN merged_rpt.v_producerprocessor pp ON s.location = pp.license_number
WHERE 1=1

GROUP BY
  CASE
    WHEN r.organizationname IS NULL
    THEN pp.organizationname
    ELSE r.organizationname
  END

  SELECT * FROM merged_rpt.v_data_as_of;