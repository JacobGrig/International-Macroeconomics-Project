# delimit ;
clear all;
cap log close;
cap file close _all;
cap program drop _all;
set scrollbufsize 1000000;
set more off;
log using create_invoice.log, replace;

cd "C:\Users\Jacob-PC\Documents\GitHub\NES-Home-Assignments\Module 07\International Macroeconomics\Project\code_data\stata\databases";

***************************************************;
* Generates database with currency invoicing shares;
* MPM 2016-10-07;
***************************************************;


*** SETTINGS ***;

* Decide what to do;
local create_db = 1; // Create database from Gita Gopinath's spreadsheet;
local major_cur = 1; // Create database with major currency invoice shares;

* File name;
local data_file = "../../data/data_invoice_currencies_20161007.xlsx"; // Data file;

* Major currencies (apart from local currency);
local cur = "EUR USA";

*** END SETTINGS ***;


*** CREATE DATABASE ***;

if `create_db' == 1 {;

cap erase "invoice.dta"; // Delete database if it exists;

foreach f in export import {; // For export and import shares...;

	import excel using `data_file', sheet("`f's") clear; // Import from Excel;
	
	* Create variable names by substituting spaces with underlines;
	foreach v of varlist * {;
		replace `v' = subinstr(`v', " ", "_", .) if _n == 1; // Variable names in first obs.;
		rename `v' invoice_share`=`v'[1]';
	};
	drop if _n == 1; // Drop first obs.;
	
	rename invoice_share country_str; // Country names;
	
	egen nonmiss = rownonmiss(*), strok; // Count non-missing in each row;
	drop if nonmiss < 2; // Drop if less than two non-missing (not an actual data row);
	drop nonmiss;
	
	reshape long invoice_share, i(country_str) j(currency_str) string; // Reshape to long data set;
	
	destring invoice_share, replace;
	drop if missing(invoice_share);
	
	replace currency_str = subinstr(currency_str, "_", " ", .); // Replace underlines with spaces in currency names;
	
	* Translate to ISO country codes;
	foreach v in country_str currency_str {;
		kountry `v', from(other) stuck;
		rename _ISO3N_ iso;
		kountry iso, from(iso3n) to(iso3c);
		replace _ISO3C_ = "EUR" if `v' == "Euro"; // Handle Euro;
		drop `v' iso;
		rename _ISO3C_ `v';
	};
	
	gen flow_str = "`f'"; // Flow (export/import);
	
	cap append using invoice; // Add to existing data;
	save invoice, replace;
	
};

* Encode categorical variables;
encode flow_str, gen(flow); // Categorical flow variable;

country_iso3 country_str, gen(country);
country_iso3 currency_str, gen(currency) extralab("EUR") extranum(0);

drop *_str;

order country flow currency;
sort country flow currency;
compress;

label data "Currency of invoicing, Gita Gopinath";
save invoice, replace;

};


*** CALCULATE MAJOR CURRENCY SHARES ***;

if `major_cur' ==  1 {;

use invoice, clear;

gen invoice_share_LCU = invoice_share if country == currency; // Local currency share;
foreach c in `cur' {;
	gen invoice_share_`c' = invoice_share if currency == "`c'":currency; // Major currency share;
};
drop currency invoice_share;
collapse (firstnm) invoice_share_*, by(country flow); // Collapse to country-flow level;

compress;
label data "Currency of invoicing, major currencies, Gita Gopinath";
save invoice_majcur, replace;

};


log close;
