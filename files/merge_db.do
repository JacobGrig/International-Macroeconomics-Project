# delimit ;

cd "C:\Users\Jacob-PC\Documents\GitHub\NES-Home-Assignments\Module 07\International Macroeconomics\Project\code_data\stata\analysis";


**************************************************;
* Merge COMTRADE, WDI, and currency invoicing data;
* MPM 2016-09-26;
**************************************************;


*** SETTINGS ***;

local reshape_vars = "n_uvicov uvicov valuecoverage n_valuecoverage *_pctgrowth"; // Comtrade series to keep;
local weight_start = "1992"; // Start averaging value weights in this year;
local weight_end = "2015"; // End averaging value weights in this year;

*** END SETTINGS ***;


*** MERGE DATA SETS ***;

* Obtain list of WDI variables;
use ../databases/wdi, clear;
ds country year, not;
local wdi_vars = r(varlist);

* Reshape COMTRADE data to panel format;
use ../databases/comtrade, clear;
decode reporter, gen(reporter_str);
replace reporter_str = "_" + reporter_str;
keep dyad year exporter importer reporter_str `reshape_vars';
reshape wide `reshape_vars', i(dyad year exporter importer) j(reporter_str) string; // Separate COMTRADE variables for exporter and importer reported data;

foreach party in importer exporter {; // For each trade party...
	rename `party' country;
	
	* Merge WDI series for party into Comtrade DB;
	merge m:1 country year using ../databases/wdi, nogen keep(master match);
	rename (`wdi_vars') =_`party'; // Attach party suffix to WDI series;
	
	rename country `party';
};

* Merge currency invoicing data for importer;
gen flow = 2; // Import;
rename importer country;
merge m:1 country flow using ../databases/invoice_majcur, nogen keep(master match); // Invoicing data;
drop flow;
rename country importer;
rename invoice_share_* =_importer;


compress;
tsset dyad year; // Define panel structure;
save data_file, replace;
