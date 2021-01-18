# delimit ;
clear all;
cap log close;
cap file close _all;
cap program drop _all;
set scrollbufsize 1000000;
set more off;
log using create_comtrade.log, replace;
ssc install kountry;
ssc install labutil;

cd "C:\Users\Jacob-PC\Documents\GitHub\NES-Home-Assignments\Module 07\International Macroeconomics\Project\code_data\stata\databases";


**************************************************************;
* Generates database with bilateral price+volume from COMTRADE;
* MPM 2016-09-21;
**************************************************************;


*** SETTINGS ***;

* Filenames;
local db_import = "../../1_all_data.dta"; // Import DB;
local db_export = "../../2_all_data.dta"; // Export DB;
local db_weo = "../../data/GroupsWEO.dta"; // WEO country classification DB;

* Merge data choices;
local trunc = "p2.5p97.5_p80"; // Truncation: "nonimputed" (raw data), "unfiltered" (imputed but not truncated), or "p2.5p97.5_p80" (baseline truncation and imputation);
local breakdown = "2group"; // Breakdown: "0total" (total), "1group" (commodity), or "2group" (non-commodity);
local price_ind = "fis_chained"; // Index definition: "fis_chained" (chained Fisher), "las_chained" (chained Laspeyres), or "pas_chained" (chained Paasche);

*** END SETTINGS ***;


*** MERGE IMPORT/EXPORT DATA ***;

cap erase "comtrade.dta";

foreach flow in import export {;

	use `db_`flow'', clear;
	keep if truncation == "`trunc'" & breakdown == "`breakdown'" & label == "`price_ind'"; // Keep desired obs.;
	gen importer_str = cond("`flow'" == "import", reporteriso, partneriso); // Importing country;
	gen exporter_str = cond("`flow'" == "export", reporteriso, partneriso); // Exporting country;
	gen reporter_str = "`flow'";
	
	drop truncation breakdown label tradeflow ifs_code_* uv_index *iso; // Drop irrelevant variables;
	
	cap append using comtrade; // Append to import data, if that DB has already been processed;
	
	save comtrade, replace;

};

* Percentage growth series;
rename (volume_index Value_index) (volume_pctgrowth value_pctgrowth);
gen uvi_pctgrowth = 100*((1+value_pctgrowth/100)/(1+volume_pctgrowth/100)-1); // UVI growth rate in percent;

* Handle Romania;
replace importer_str = "ROU" if importer_str == "ROM";
replace exporter_str = "ROU" if exporter_str == "ROM";

* Create categorical country variables;
country_iso3 importer_str, gen(importer);
country_iso3 exporter_str, gen(exporter);
label copy importer country;
label drop importer exporter;
label values importer exporter country;

save comtrade, replace;


*** CREATE COUNTRY DB ***;

use comtrade, clear;

rename (importer importer_str) (country country_iso);
collapse (first) country_iso, by(country); // Collapse to just countries;

save countries, replace;

* Country categories;
use `db_weo', clear;
drop if missing(iso3code);
rename iso3code country_iso;
rename grp_110 weo_advanced;
keep country_iso weo_advanced;
merge 1:1 country_iso using countries, nogen keep(match using);

order country country_iso;
sort country_iso;
compress;

label data "COMTRADE countries";
save countries, replace;


*** CLEAN UP MERGED COMTRADE DB ***;

use comtrade, clear;

encode reporter_str, gen(reporter);
sort exporter importer reporter year;

gen dyad_str = exporter_str + "_" + importer_str; // Exporter-importer dyad;
encode dyad_str, gen(dyad); // Categorical dyad variable;

rename classification classification_str;
encode classification_str, gen(classification);

drop *_str; // Drop string variables;

format year %ty;
order dyad year reporter classification exporter importer;
compress;

label data "COMTRADE merge. Truncation: `trunc'. Breakdown: `breakdown'. Index: `price_ind'.";
save comtrade, replace;

log close;
