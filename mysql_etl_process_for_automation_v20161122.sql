# ENTIRE REFRESH PROCESS FOR [merged_rpt] DATA.

/**********************************************************************
 * DELETED TYPE
*/
INSERT INTO merged_rpt.dim_deletedtype (deletedindicator, isdeleted, deleteddescription)
SELECT DISTINCT s.deleted, 'TBD', 'TBD'
FROM
  merged.sale s
  LEFT JOIN merged_rpt.dim_deletedtype dt ON s.deleted = dt.deletedindicator
WHERE 1=1 AND NOT s.deleted IS NULL AND dt.deletedindicator IS NULL;


/**********************************************************************
 * MEDICAL TYPE
*/
INSERT INTO merged_rpt.dim_medicaltype (medicalindicator, ismedical, medicaldescription)
SELECT DISTINCT s.is_medical, 'TBD', 'TBD'
FROM
  merged.sale s
  LEFT JOIN merged_rpt.dim_medicaltype mt ON s.is_medical = mt.medicalindicator
WHERE 1=1 AND NOT s.is_medical IS NULL AND mt.medicalindicator IS NULL;


/**********************************************************************
 * REFUND TYPE
*/
INSERT INTO merged_rpt.dim_refundtype (refundindicator, isrefund, refunddescription)
SELECT DISTINCT s.refunded, 'TBD', 'TBD'
FROM
  merged.sale s
  LEFT JOIN merged_rpt.dim_refundtype rt ON s.refunded = rt.refundindicator
WHERE 1=1 AND NOT s.refunded IS NULL AND rt.refundindicator IS NULL;


/**********************************************************************
 * SAMPLE TYPE
*/
INSERT INTO merged_rpt.dim_sampletype (sampleindicator, issample, sampledescription)
SELECT DISTINCT i.is_sample, 'TBD', 'TBD'
FROM
  merged.inventory i
  LEFT JOIN merged_rpt.dim_sampletype st ON i.is_sample = st.sampleindicator
WHERE 1=1 AND NOT i.is_sample IS NULL AND st.sampleindicator IS NULL;


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
  ,i.inventorytype
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
  ,IFNULL(i.strain,'Unknown Strain Name') AS strain
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
    #,productname
    ,TRIM(REPLACE(IFNULL(productname,'Unknown Product Name'), '"', '')) AS productname
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

CREATE INDEX ix_i_inventoryid ON merged_rpt.inventory (inventoryid);
CREATE INDEX ix_i_inventorytype ON merged_rpt.inventory (inventorytype);
CREATE INDEX ix_i_inventorystatustime_pst ON merged_rpt.inventory (inventorystatustime_pst);


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
 * MANIFEST STOP DATA
*/
DROP TABLE IF EXISTS merged_rpt.manifest_stop_data;
CREATE TABLE merged_rpt.manifest_stop_data AS
SELECT
  msd.arrive_time
  ,IFNULL(CONVERT_TZ(msd.arrive_time,'UTC','US/Pacific'),NULL) AS arrivetime_pst
  ,msd.city
  ,msd.deleted
  ,msd.depart_time
  ,IFNULL(CONVERT_TZ(msd.depart_time,'UTC','US/Pacific'),NULL) AS departtime_pst
  ,msd.item_count
  ,msd.license_number
  ,msd.location
  ,msd.manifestid
  ,msd.name
  ,msd.phone
  ,msd.sessiontime
  ,IFNULL(CONVERT_TZ(msd.sessiontime,'UTC','US/Pacific'),NULL) AS sessiontime_pst
  ,msd.state
  ,msd.stopnumber
  ,msd.street
  ,msd.transactionid
  ,msd.transactionid_original
  ,msd.travel_route
  ,msd.zip
FROM
  (
    SELECT DISTINCT
      arrive_time
      ,city
      ,deleted
      ,depart_time
      ,item_count
      ,license_number
      ,location
      ,manifestid
      ,name
      ,phone
      ,sessiontime
      ,state
      ,stopnumber
      ,street
      ,transactionid
      ,transactionid_original
      ,travel_route
      ,zip
    FROM
      merged.manifest_stop_data
  ) msd;

CREATE INDEX ix_msd_manifestid ON merged_rpt.manifest_stop_data (manifestid);
CREATE INDEX ix_msd_location ON merged_rpt.manifest_stop_data (location);
CREATE INDEX ix_msd_licensenumber ON merged_rpt.manifest_stop_data (license_number);
CREATE INDEX ix_msd_sessiontime_pst ON merged_rpt.manifest_stop_data (sessiontime_pst);


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
 * PRODUCT - TEMP (DIMENSION)
*/
DROP TABLE IF EXISTS merged_rpt.dim_product_temp;
CREATE TABLE merged_rpt.dim_product_temp AS
SELECT DISTINCT
  i.inventoryid
  #,TRIM(REPLACE(IFNULL(i.productname,'Unknown Product Name'), '"', '')) AS productname
  ,i.productname
  ,CASE
		WHEN i.inventorytype = 31 THEN
			CASE WHEN (INSTR(LOWER(i.productname),'cone')) > 0 THEN 'Pre-Roll' ELSE 'Product Type TBD' END
		WHEN i.inventorytype = 32 THEN
			CASE WHEN (INSTR(LOWER(i.productname),'cone')) > 0 THEN 'Pre-Roll' ELSE 'Product Type TBD' END
    WHEN i.inventorytype = 24 THEN
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
  WHEN i.inventorytype = 28 THEN
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
  ,0 AS noninventoryflagid
FROM
  merged_rpt.inventory                    i
  LEFT JOIN merged_rpt.dim_strain         ds    ON IFNULL(i.strain,'Unknown') = ds.strainname
  LEFT JOIN merged_rpt.dim_inventorytype  dit   ON i.inventorytype = dit.inventorytype
  #LEFT JOIN merged_rpt.dim_usableweight   duw   ON CAST(IFNULL(i.usableweight,0) AS DECIMAL(10,4)) BETWEEN duw.valuestart AND duw.valueend
  LEFT JOIN merged_rpt.dim_usableweight   duw   ON IFNULL(i.usableweight,0) BETWEEN duw.valuestart AND duw.valueend
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
  noninventoryflagid INT NOT NULL,
  PRIMARY KEY (inventoryid)
) AUTO_INCREMENT = 0;

CREATE INDEX ix_dp_inventoryid ON merged_rpt.dim_product (inventoryid);
CREATE INDEX ix_dp_productname ON merged_rpt.dim_product (productname);

# Insert 'Unknown' record first.
INSERT INTO merged_rpt.dim_product (inventoryid, productname, producttypeid, productflagid, usableweight, strainid,
  inventorytypeid, usableweightid, deletedtypeid, medicaltypeid, sampletypeid,noninventoryflagid)
VALUES (0,'Unknown',1,1,0,1,1,0,0,1,1,0);

# Populate the [merged_rpt].[dim_product] table.
INSERT INTO merged_rpt.dim_product (inventoryid, productname, producttypeid, productflagid, usableweight,
  strainid, inventorytypeid, usableweightid, deletedtypeid, medicaltypeid, sampletypeid,noninventoryflagid)
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
  ,0 AS noninventoryflagid
FROM
  merged_rpt.dim_product_temp                 dpt
  LEFT JOIN merged_rpt.dim_producttype        pt    ON dpt.producttype = pt.producttype
  LEFT JOIN merged_rpt.dim_productflag_temp   pft   ON dpt.productflag = pft.productflag
WHERE 1=1;


/**********************************************************************
 * PRODUCT TRANSFER TEMP (DIMENSION)
*/
DROP TABLE IF EXISTS merged_rpt.dim_product_transfer_temp;
CREATE TABLE merged_rpt.dim_product_transfer_temp AS
SELECT DISTINCT
  it.inventoryid
  ,TRIM(REPLACE(IFNULL(msi.description,'Unknown Product Name'), '"', '')) AS productname
  ,CASE
		WHEN it.inventorytype = 31 THEN
			CASE WHEN (INSTR(LOWER(msi.description),'cone')) > 0 THEN 'Pre-Roll' ELSE 'Product Type TBD' END
		WHEN it.inventorytype = 32 THEN
			CASE WHEN (INSTR(LOWER(msi.description),'cone')) > 0 THEN 'Pre-Roll' ELSE 'Product Type TBD' END
    WHEN it.inventorytype = 24 THEN
      CASE
      # PRE-ROLL (CONE)
      WHEN (INSTR(LOWER(msi.description),'cone')) > 0 THEN 'Pre-Roll'
      # E-CIG
      WHEN (INSTR(LOWER(msi.description),'ezvape') + INSTR(LOWER(msi.description),'ez vape') +
        INSTR(LOWER(msi.description),'rosta stiix') + INSTR(LOWER(msi.description),'rosta stix') +
        INSTR(LOWER(msi.description),'rasta stiix') + INSTR(LOWER(msi.description),'rasta stix') +
        INSTR(LOWER(msi.description),'ez-vape') + INSTR(LOWER(msi.description),'juju')) > 0 THEN 'E-Cig'
      # KIEF
      WHEN (INSTR(LOWER(msi.description),'kief') + INSTR(LOWER(msi.description),'keif')) > 0 THEN 'Kief'
      # CAVIAR
      WHEN (INSTR(LOWER(msi.description),'caviar')) > 0 THEN 'Caviar'
      # WAX
      WHEN (INSTR(LOWER(msi.description),'wax')) > 0 THEN 'Wax'
      # ROSIN
      WHEN (INSTR(LOWER(msi.description),'rosin') + INSTR(LOWER(msi.description),'roslin') +
        INSTR(LOWER(msi.description),'resin') + INSTR(LOWER(msi.description),'rosen')) > 0 THEN 'Rosin'
      # APPLICATOR
      WHEN (INSTR(LOWER(msi.description),'appli') + INSTR(LOWER(msi.description),'syringe') +
        INSTR(LOWER(msi.description),'refill') + INSTR(LOWER(msi.description),'tanker')) > 0 THEN 'Applicator'
      # CARTRIDGE
      WHEN (INSTR(LOWER(msi.description),'cart') + INSTR(LOWER(msi.description),'oil') +
        INSTR(LOWER(msi.description),'vape') + INSTR(LOWER(msi.description),'co2') +
        INSTR(LOWER(msi.description),'dabulator') + INSTR(LOWER(msi.description),'atomizer') +
        INSTR(LOWER(msi.description),'disposable') + INSTR(LOWER(msi.description),'vapo')) > 0 THEN 'Cartridge'
      # HASH
      WHEN (INSTR(LOWER(msi.description),'hash')) > 0 THEN 'Hash'
      # SHATTER
      WHEN (INSTR(LOWER(msi.description),'shat')) > 0 THEN 'Shatter'
      # DAB
      WHEN (INSTR(LOWER(msi.description),'dab')) > 0 THEN 'Dab'
      # OTHER (default to i.productname)
    ELSE 'Product Type TBD' #IFNULL(i.productname, 'Unknown Product Name')
    END
  WHEN it.inventorytype = 28 THEN
    CASE
      # PRE-ROLL
      WHEN (INSTR(LOWER(msi.description),'pre-roll') + INSTR(LOWER(msi.description),'pre roll') +
        INSTR(LOWER(msi.description),'rollies') + INSTR(LOWER(msi.description),'cone') +
        INSTR(LOWER(msi.description),'preroll') + INSTR(LOWER(msi.description),'joint')) > 0 THEN 'Pre-Roll'
      # PRE-PACK
      WHEN (INSTR(LOWER(msi.description),'pre-pack') + INSTR(LOWER(msi.description),'pre pack') +
        INSTR(LOWER(msi.description),'prepack')) > 0 THEN 'Pre-Pack'
      # OTHER (default to i.productname)
      ELSE 'Product Type TBD' #IFNULL(i.productname, 'Unknown Product Name')
    END
  ELSE 'Product Type TBD'
  END AS producttype
  ,CASE
    #WHEN (INSTR(LOWER(i.productname),'interra')) > 0 THEN 'Interra'
    WHEN (INSTR(LOWER(msi.description),'bho')) > 0 THEN 'BHO'
    WHEN (INSTR(LOWER(msi.description),'co2')) > 0 THEN 'CO2'
    WHEN (INSTR(LOWER(msi.description),'juju')) > 0 THEN 'JuJu'
    WHEN (INSTR(LOWER(msi.description),'liberty r') + INSTR(LOWER(msi.description),'lr')) > 0 THEN 'Liberty'
    WHEN (INSTR(LOWER(msi.description),'ezvape') + INSTR(LOWER(msi.description),'ez-vape') +
      INSTR(LOWER(msi.description),'ez vape')) > 0 THEN 'EZ Vape'
    ELSE 'Other'
  END AS productflag
  ,NULL AS usableweight
  ,IFNULL(ds.strainid,1) AS strainid
  ,dit.inventorytypeid
  ,1 AS usableweightid
  ,1 AS deletedtypeid
  ,1 AS medicaltypeid
  ,1 AS sampletypeid
  ,1 AS noninventoryflagid
FROM
  merged_rpt.inventory_transfer             it
  LEFT JOIN merged_rpt.manifest_stop_items  msi   ON it.manifestid = msi.manifestid AND it.inventoryid = msi.inventoryid
  LEFT JOIN merged_rpt.dim_strain           ds    ON TRIM(REPLACE(REPLACE(REPLACE(REPLACE(it.strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) = ds.strainname
  LEFT JOIN merged_rpt.dim_product          p     ON it.inventoryid = p.inventoryid
  LEFT JOIN merged_rpt.dim_inventorytype    dit   ON it.inventorytype = dit.inventorytype
WHERE 1=1
  AND p.inventoryid IS NULL;

SELECT * FROM merged_rpt.dim_product_transfer_temp dtt
LEFT JOIN (
  SELECT inventoryid,COUNT(*) FROM merged_rpt.dim_product_transfer_temp
  GROUP BY inventoryid HAVING COUNT(*) > 1) dups ON dtt.inventoryid = dups.inventoryid
WHERE dups.inventoryid IS NULL
;

/**********************************************************************
 * PRODUCT - SOURCE FROM INVENTORY TRANSFER (DIMENSION)
*/
# Insert INVENTORY TRANSFER records into [merged_rpt].[dim_product] table.
INSERT INTO merged_rpt.dim_product (inventoryid, productname, producttypeid, productflagid, usableweight,
  strainid, inventorytypeid, usableweightid, deletedtypeid, medicaltypeid, sampletypeid,noninventoryflagid)
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
  ,1 AS noninventoryflagid
FROM
  merged_rpt.dim_product_transfer_temp        dpt
  LEFT JOIN merged_rpt.dim_producttype        pt    ON dpt.producttype = pt.producttype
  LEFT JOIN merged_rpt.dim_productflag_temp   pft   ON dpt.productflag = pft.productflag
  LEFT JOIN (
    SELECT inventoryid,COUNT(*) FROM merged_rpt.dim_product_transfer_temp
    GROUP BY inventoryid HAVING COUNT(*) > 1) dups ON dpt.inventoryid = dups.inventoryid
WHERE 1=1 AND dups.inventoryid IS NULL;


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


/**********************************************************************
 * SALE BY TRANSFER (TEMP)
*/
DROP TABLE IF EXISTS merged_rpt.sale_by_transfer_temp;
CREATE TABLE merged_rpt.sale_by_transfer_temp AS
SELECT
  ddt.deletedtypeid
  ,it.inventoryid
  ,it.inventorytype
  ,drt.refundtypeid
  ,it.outboundlicense
  ,it.manifeststop
  ,it.manifestid
  ,it.price
  ,it.quantity
  ,it.sessiontime
  ,it.sessiontime_pst
  ,it.transactionid
  ,it.transactionid_original
  ,msd.license_number AS inboundlicense
  #,TRIM(REPLACE(IFNULL(msi.description,'Unknown Product Name'), '"', '')) AS productname
  #,TRIM(REPLACE(REPLACE(REPLACE(REPLACE(it.strain, CHAR(9), ''), CHAR(13), ''), CHAR(10), ''),'"','')) AS strainname
  #,p.*
FROM
  merged_rpt.inventory_transfer             it
  LEFT JOIN merged_rpt.dim_location         l_loc   ON it.location = l_loc.licensenumber
  LEFT JOIN merged_rpt.dim_location         l_out   ON it.outboundlicense = l_out.licensenumber
  LEFT JOIN merged_rpt.manifest_stop_data   msd     ON it.manifestid = msd.manifestid AND it.manifeststop = msd.stopnumber
  LEFT JOIN merged_rpt.dim_deletedtype      ddt     ON it.deleted = ddt.deletedindicator
  LEFT JOIN merged_rpt.dim_refundtype       drt     ON it.refundindicator = drt.refundindicator
  #LEFT JOIN merged_rpt.manifest_stop_items  msi     ON it.manifestid = msi.manifestid AND it.inventoryid = msi.inventoryid
  #LEFT JOIN merged_rpt.dim_product          p       ON it.inventoryid = p.inventoryid
WHERE 1=1;

CREATE INDEX ix_sbtt_inventoryid ON merged_rpt.sale_by_transfer_temp (inventoryid);
CREATE INDEX ix_sbtt_sessiontime_pst ON merged_rpt.sale_by_transfer_temp (sessiontime_pst);

SELECT * FROM merged_rpt.inventory_transfer WHERE deleted = 1 AND price > 0 LIMIT 100

/**********************************************************************
 * SALE BY TRANSFER
*/
DROP TABLE IF EXISTS merged_rpt.sale_by_transfer;
CREATE TABLE merged_rpt.sale_by_transfer AS
SELECT
  CAST(s.sessiontime_pst AS DATE) AS date_pst
  ,s.outboundlicense
  ,s.inboundlicense
  ,s.inventoryid
  ,s.deletedtypeid
  ,s.refundtypeid
  ,CAST((s.price/s.quantity) AS DECIMAL(15,4)) AS costperunit
  ,CAST((SUM(s.price)/SUM(s.quantity)*SUM(s.quantity)) AS DECIMAL(15,4)) AS cogs
  ,SUM(s.price) AS price
  ,SUM(s.quantity) AS quantity
FROM
  merged_rpt.sale_by_transfer_temp s
WHERE 1=1
GROUP BY 1,2,3,4,5,6,7;

CREATE INDEX ix_sbt_inventoryid ON merged_rpt.sale_by_transfer (inventoryid);
CREATE INDEX ix_sbt_date_pst ON merged_rpt.sale_by_transfer (date_pst);
CREATE INDEX ix_sbt_outboundlicense ON merged_rpt.sale_by_transfer (outboundlicense);
CREATE INDEX ix_sbt_inboundlicense ON merged_rpt.sale_by_transfer (inboundlicense);


/********************************************************************
 * REPLACE THE [merged_stg] TABLES WITH [merged_rpt]
*/

# DELETED TYPE
DROP TABLE merged_stg.dim_deletedtype;
CREATE TABLE merged_stg.dim_deletedtype AS SELECT * FROM merged_rpt.dim_deletedtype;

# INVENTORY GROUP
DROP TABLE merged_stg.dim_inventorygroup;
CREATE TABLE merged_stg.dim_inventorygroup AS SELECT * FROM merged_rpt.dim_inventorygroup;
CREATE INDEX ix_dig_inventorygroupid ON merged_stg.dim_inventorygroup (inventorygroupid);

# INVENTORY TYPE
DROP TABLE merged_stg.dim_inventorytype;
CREATE TABLE merged_stg.dim_inventorytype AS SELECT * FROM merged_rpt.dim_inventorytype;
CREATE INDEX ix_dit_inventorytypeid ON merged_stg.dim_inventorytype (inventorytypeid);

# MEDICAL TYPE
DROP TABLE merged_stg.dim_medicaltype;
CREATE TABLE merged_stg.dim_medicaltype AS SELECT * FROM merged_rpt.dim_medicaltype;

# PRODUCT
DROP TABLE merged_stg.dim_product;
CREATE TABLE merged_stg.dim_product AS SELECT * FROM merged_rpt.dim_product;
CREATE INDEX ix_dp_inventoryid ON merged_stg.dim_product (inventoryid);
CREATE INDEX ix_dp_productname ON merged_stg.dim_product (productname);

# PRODUCT FLAG (TEMP)
DROP TABLE merged_stg.dim_productflag_temp;
CREATE TABLE merged_stg.dim_productflag_temp AS SELECT * FROM merged_rpt.dim_productflag_temp;
CREATE INDEX ix_dpf_productflagid ON merged_stg.dim_productflag_temp (productflagid);

# PRODUCT TYPE
DROP TABLE merged_stg.dim_producttype;
CREATE TABLE merged_stg.dim_producttype AS SELECT * FROM merged_rpt.dim_producttype;
CREATE INDEX ix_dpt_producttypeid ON merged_stg.dim_producttype (producttypeid);

# REFUND TYPE
DROP TABLE merged_stg.dim_refundtype;
CREATE TABLE merged_stg.dim_refundtype AS SELECT * FROM merged_rpt.dim_refundtype;

# SAMPLE TYPE
DROP TABLE merged_stg.dim_sampletype;
CREATE TABLE merged_stg.dim_sampletype AS SELECT * FROM merged_rpt.dim_sampletype;

# STRAIN
DROP TABLE merged_stg.dim_strain;
CREATE TABLE merged_stg.dim_strain AS SELECT * FROM merged_rpt.dim_strain;
CREATE INDEX ix_ds_strainid ON merged_stg.dim_strain (strainid);

# USABLE WEIGHT
DROP TABLE merged_stg.dim_usableweight;
CREATE TABLE merged_stg.dim_usableweight AS SELECT * FROM merged_rpt.dim_usableweight;
CREATE INDEX ix_duw_usableweightid ON merged_stg.dim_usableweight (usableweightid);

# SALE BY DAY
DROP TABLE merged_stg.sale_by_day;
CREATE TABLE merged_stg.sale_by_day AS SELECT * FROM merged_rpt.sale_by_day;
CREATE INDEX ix_sbd_inventoryid ON merged_stg.sale_by_day (inventoryid);
CREATE INDEX ix_sbd_date_pst ON merged_stg.sale_by_day (date_pst);
CREATE INDEX ix_sbd_location ON merged_stg.sale_by_day (location);
CREATE INDEX ix_sbd_locationubi ON merged_stg.sale_by_day (locationubi);
CREATE INDEX ix_sbd_outboundlicense ON merged_stg.sale_by_day (outbound_license);


/********************************************************************
 * UPDATE THE [dim_etl_date] TABLE
*/
UPDATE merged_rpt.dim_etl_date
SET etl_refreshdate = (SELECT MAX(sessiontime) FROM merged_rpt.sale),
  etl_maxdate = (SELECT MAX(sessiontime) FROM merged.sale)
WHERE etldatekey = 1;

SELECT * FROM merged_rpt.dim_etl_date;


/********************************************************************
 * UPDATE DATES FOR [data_as_of] TABLE
*/
DROP TABLE merged_rpt.data_as_of;
CREATE TABLE merged_rpt.data_as_of AS
SELECT
  CASE
    WHEN r.organizationname IS NULL
    THEN pp.organizationname
    ELSE r.organizationname
  END AS organization_name
  ,s.location
  ,s.locationubi
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
  ,s.location
  ,s.locationubi;

DROP VIEW IF EXISTS merged_rpt.v_data_as_of;
CREATE VIEW merged_rpt.v_data_as_of AS
SELECT * FROM merged_rpt.data_as_of
WHERE NOT organization_name IS NULL
ORDER BY
organization_name, location;

SELECT * FROM merged_rpt.v_data_as_of;

