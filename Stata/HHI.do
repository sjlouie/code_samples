
*********************************
** This script takes in data from students country
** and makes the variables HHI and FRAC
** then runs the regressions for our analysis, seen on my resume
** - Schuyler Louie
*********************************

capture program drop HHI
program define HHI
args bpld


use $thisdata/Student_Counts/students_`bpld'.dta, clear
gen year_born=year-(age+1)

keep if year_born>=1982 & year_born<=2001


collapse (sum) students, by(age year year_born statefip)



gen age_centered=age-18
sort year_born age statefip
egen cohort_share = sum(students),by(year_born age statefip) /*sums students accross year born age and statefip*/
egen cohort_total = sum(students),by(year_born age) /*sums students accross just year and age born*/
gen student_share = cohort_share / cohort_total
gen hhi_i = (student_share *100)^2
collapse (sum) HHI=hhi_i, by(year_born age_centered)
gen FRAC=10000-HHI
gen year_born_centered=year_born-1982
gen yb_centeredsq =  year_born_centered^2


estpost tabstat FRAC, stat(mean sd min max)
esttab using $thislatex/frac_stats_`bpld'.tex, cells("mean sd min max") label replace

//running regressions

//storing as tex file
eststo: reg FRAC year_born_centered age_centered
eststo: reg FRAC year_born_centered yb_centeredsq age_centered

esttab using $thislatex/frac_table_`bpld'.tex, replace //
  eststo clear

//outputting to user
reg FRAC year_born_centered age_centered
reg FRAC year_born_centered yb_centeredsq age_centered

dis "this is frac for `bpld'"

//making scatter plots to viusalize data
twoway scatter FRAC year_born, ytitle("Fractionalization") xtitle("Year Born") //ylabel(1000 2000 3000 4000 5000 6000 7000 8000 9000)
graph export $thislatex/HHI_yb_`bpld'.eps, replace
! epstopdf $thislatex/HHI_yb_`bpld'.eps

twoway scatter FRAC age_centered, ytitle("Fractionalization") xtitle("Age Centered") //ylabel(4000 5000 6000 7000 8000 9000)
graph export $thislatex/HHI_age_`bpld'.eps, replace
! epstopdf $thislatex/HHI_age_`bpld'.eps
dis "This is HHI for `bpld'!!"


end
