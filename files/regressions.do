clear all

cd "C:\Users\Jacob-PC\Documents\GitHub\NES-Home-Assignments\Module 07\International Macroeconomics\Project"

use data_file.dta

*** Part A ***

* calculate e_ij: log bilateral exchange rate
g e_ij = log(PA_NUS_ATLS_importer / PA_NUS_ATLS_exporter)

* calculate X_i: change in the log producer price index 
* of the exporting country i measured in currency i
g price_i = log(FP_WPI_TOTL_exporter)
g X_i = price_i - L.price_i

* calculate delta_e_ij = e_ij_t - e_ij_{t-1}
g delta_e_ij = e_ij - L.e_ij

* calculate delta_e_Sj: difference in log prices of a US dollar 
* in currency j between t-1 and t
g delta_e_Sj = log(PA_NUS_ATLS_importer) - log(L.PA_NUS_ATLS_importer)

* calculate delta_p_ij for exporters and importers, where p_ij is
* log price of goods [exported from] / {imported to} country i [to]/{from} 
* country measured in currency j
g delta_p_ij_exporter = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj
g delta_p_ij_importer = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj

* calculate interactions: delta_e_ij * S_j and delta_e_Sj * S_j
g delta_e_ij_S_j = delta_e_ij * invoice_share_USA_importer
g delta_e_Sj_S_j = delta_e_Sj * invoice_share_USA_importer

* export regression (3) in Table 1
xtreg delta_p_ij_exporter delta_e_ij L.delta_e_ij L2.delta_e_ij delta_e_ij_S_j L.delta_e_ij_S_j L2.delta_e_ij_S_j delta_e_Sj L.delta_e_Sj L2.delta_e_Sj delta_e_Sj_S_j L.delta_e_Sj_S_j L2.delta_e_Sj_S_j X_i L.X_i L2.X_i i.year, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_overall_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_overall_exp.xlsx", replace
putexcel A1 = matrix(C), names

* import regression (6) in Table 1
xtreg delta_p_ij_importer delta_e_ij L.delta_e_ij L2.delta_e_ij delta_e_ij_S_j L.delta_e_ij_S_j L2.delta_e_ij_S_j delta_e_Sj L.delta_e_Sj L2.delta_e_Sj delta_e_Sj_S_j L.delta_e_Sj_S_j L2.delta_e_Sj_S_j X_i L.X_i L2.X_i i.year, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_overall_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_overall_imp.xlsx", replace
putexcel A1 = matrix(C), names

* we can see now that the coefficients are exactly the same as in Table 1

* and if we go along the diagonal of covariance matrix, there will be 
* squares of standard deviations (or simply variances)

*** Part B ***

* NOTE: in this part we will be using only two lags of delta_e instead of 8
* in regression (26) from the article. This is because in the article 
* quarterly data is used instead of annual (so, to account for two years, we
* use two lags).

* Here we can find the codes of countries:
* https://en.wikipedia.org/wiki/ISO_3166-1_numeric
g arg_code = 32
g swi_code = 756
g tur_code = 792

* Argentina!

* find delta_e_Sj for Argentina if it is importer or exporter
g delta_e_Sj_arg = delta_e_Sj if importer == arg_code
replace delta_e_Sj_arg = log(PA_NUS_ATLS_exporter) - log(L.PA_NUS_ATLS_exporter) if exporter == arg_code

* exporters report:
g delta_p_ij_exporter_arg_imp = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj_arg if importer == arg_code
g delta_p_ij_exporter_arg_exp = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj_arg if exporter == arg_code

* importer Argentina regression, exporters report
xtreg delta_p_ij_exporter_arg_imp delta_e_Sj_arg L.delta_e_Sj_arg L2.delta_e_Sj_arg, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_arg_exp_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_arg_exp_imp.xlsx", replace
putexcel A1 = matrix(C), names

* exporter Argentina regression, exporters report
xtreg delta_p_ij_exporter_arg_exp delta_e_Sj_arg L.delta_e_Sj_arg L2.delta_e_Sj_arg, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_arg_exp_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_arg_exp_exp.xlsx", replace
putexcel A1 = matrix(C), names

* importers report:
g delta_p_ij_importer_arg_imp = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj_arg if importer == arg_code
g delta_p_ij_importer_arg_exp = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj_arg if exporter == arg_code

* importer Argentina regression, importers report
xtreg delta_p_ij_importer_arg_imp delta_e_Sj_arg L.delta_e_Sj_arg L2.delta_e_Sj_arg, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_arg_imp_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_arg_imp_imp.xlsx", replace
putexcel A1 = matrix(C), names

* exporter Argentina regression, exporters report
xtreg delta_p_ij_importer_arg_exp delta_e_Sj_arg L.delta_e_Sj_arg L2.delta_e_Sj_arg, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_arg_imp_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_arg_imp_exp.xlsx", replace
putexcel A1 = matrix(C), names

* Switzerland!

* find delta_e_Sj for Switzerland if it is importer or exporter
g delta_e_Sj_swi = delta_e_Sj if importer == swi_code
replace delta_e_Sj_swi = log(PA_NUS_ATLS_exporter) - log(L.PA_NUS_ATLS_exporter) if exporter == swi_code

* exporters report:
g delta_p_ij_exporter_swi_imp = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj_swi if importer == swi_code
g delta_p_ij_exporter_swi_exp = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj_swi if exporter == swi_code

* importer Switzerland regression, exporters report
xtreg delta_p_ij_exporter_swi_imp delta_e_Sj_swi L.delta_e_Sj_swi L2.delta_e_Sj_swi, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_swi_exp_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_swi_exp_imp.xlsx", replace
putexcel A1 = matrix(C), names

* exporter Switzerland regression, exporters report
xtreg delta_p_ij_exporter_swi_exp delta_e_Sj_swi L.delta_e_Sj_swi L2.delta_e_Sj_swi, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_swi_exp_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_swi_exp_exp.xlsx", replace
putexcel A1 = matrix(C), names

* importers report:
g delta_p_ij_importer_swi_imp = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj_swi if importer == swi_code
g delta_p_ij_importer_swi_exp = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj_swi if exporter == swi_code

* importer Switzerland regression, importers report
xtreg delta_p_ij_importer_swi_imp delta_e_Sj_swi L.delta_e_Sj_swi L2.delta_e_Sj_swi, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_swi_imp_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_swi_imp_imp.xlsx", replace
putexcel A1 = matrix(C), names

* exporter Switzerland regression, exporters report
xtreg delta_p_ij_importer_swi_exp delta_e_Sj_swi L.delta_e_Sj_swi L2.delta_e_Sj_swi, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_swi_imp_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_swi_imp_exp.xlsx", replace
putexcel A1 = matrix(C), names

* Turkey!

* find delta_e_Sj for Turkey if it is importer or exporter
g delta_e_Sj_tur = delta_e_Sj if importer == tur_code
replace delta_e_Sj_tur = log(PA_NUS_ATLS_exporter) - log(L.PA_NUS_ATLS_exporter) if exporter == tur_code

* exporters report:
g delta_p_ij_exporter_tur_imp = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj_tur if importer == tur_code
g delta_p_ij_exporter_tur_exp = log(1 + uvi_pctgrowth_export / 100) + delta_e_Sj_tur if exporter == tur_code

* importer Turkey regression, exporters report
xtreg delta_p_ij_exporter_tur_imp delta_e_Sj_tur L.delta_e_Sj_tur L2.delta_e_Sj_tur, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_tur_exp_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_tur_exp_imp.xlsx", replace
putexcel A1 = matrix(C), names

* exporter Turkey regression, exporters report
xtreg delta_p_ij_exporter_tur_exp delta_e_Sj_tur L.delta_e_Sj_tur L2.delta_e_Sj_tur, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_tur_exp_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_tur_exp_exp.xlsx", replace
putexcel A1 = matrix(C), names

* importers report:
g delta_p_ij_importer_tur_imp = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj_tur if importer == tur_code
g delta_p_ij_importer_tur_exp = log(1 + uvi_pctgrowth_import / 100) + delta_e_Sj_tur if exporter == tur_code

* importer Turkey regression, importers report
xtreg delta_p_ij_importer_tur_imp delta_e_Sj_tur L.delta_e_Sj_tur L2.delta_e_Sj_tur, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_tur_imp_imp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_tur_imp_imp.xlsx", replace
putexcel A1 = matrix(C), names

* exporter Turkey regression, exporters report
xtreg delta_p_ij_importer_tur_exp delta_e_Sj_tur L.delta_e_Sj_tur L2.delta_e_Sj_tur, fe cl(dyad)

* saving covariances
matrix V = get(VCE)
matrix list V
putexcel set "final estimates/cov_tur_imp_exp.xlsx", replace
putexcel A1 = matrix(V), names

* saving coefficients
matrix C = e(b)
matrix list C
putexcel set "final estimates/coef_tur_imp_exp.xlsx", replace
putexcel A1 = matrix(C), names