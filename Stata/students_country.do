
*********************************
** This script takes in ACS data from raw data folder
** and filters and collapses it by a geographic tollerance
** - Schuyler Louie
*********************************


capture program drop students_country
program define students_country
args bpld geo_type



*special case 3 is for visegrad
**Special case dummy for certain countries
  local special_case=inlist(`bpld',1,2,3,45200,45300,46500,50200)
  local i=1

  *******************************************
  **Creates local for years
    **Changed to 1990 for visegrad group
       forvalues j=1990(10)2000 {
         local years "`years' `j'"
       }
       forvalues j=2005(1)2019 {
         local years "`years' `j'"
       }
       dis "`years'"
  *******************************************


  *******************************************
  **Loop over years to load in data
  **We only load in students with a HSD or more
  *******************************************
    foreach year of local years {

      **Codes up met variables to collapse on
        if "`geo_type'"=="state" {
          local geo_var "statefip"
          local geo_dir "Student_Counts"
        }
        if "`geo_type'"=="met" {
          local geo_dir "Student_Mets"
          if `year'<2012  local geo_var "metaread"
          if `year'>=2012 local geo_var "met2013"
        }
        if "`geo_type'"=="region" {
          local geo_dir "Student_Regions"
          local geo_var "region"
        }
        if "`geo_type'"=="division" {
          local geo_dir "Student_Divisions"
          local geo_var "division"
        }

      dis "We are now starting year `year' for country `bpld' and collapsing on `geo_var'"




      if `special_case'==1 {
        if `bpld'==1 {
          use $acs_vars using $data/`year'.dta if bpld>=100 & bpld<15000 & educd>64 & age>=18, clear
        }
        if `bpld'==3 {
          use $acs_vars using $data/`year'.dta if (bpld==45200 | bpld==45213 | bpld==45212 | bpld==45400 | bpld==45500) & educd>64 & age>=18, clear
	      }
        if `bpld'==2 {
          use $acs_vars using $data/`year'.dta if bpld>=15000 & bpld!=50000 & educd>64 & age>=18, clear
        }
        if `bpld'==45200 {
          use $acs_vars using $data/`year'.dta if bpld>=45200 & bpld<=45213 & educd>64 & age>=18, clear
        }
        if `bpld'==45300 {
          use $acs_vars using $data/`year'.dta if bpld>=45300 & bpld<45400 & educd>64 & age>=18, clear
        }
        if `bpld'==46500 {
          use $acs_vars using $data/`year'.dta if bpld>=46500 & bpld<46530 & educd>64 & age>=18, clear
        }
        if `bpld'==50200 {
          use $acs_vars using $data/`year'.dta if (bpld==50200 | bpld==52200) & educd>64 & age>=18, clear
        }
      }
      else {
         use $acs_vars using $data/`year'.dta if bpld==`bpld' & educd>64 & age>=18, clear
      }

     **We only keep foreign born who migrated at age 17 or older
       if `bpld' != 1 gen age_migrate=(age+1)-(year-yrimmig)  //if US we need to recode this
       if `bpld' != 1 keep if age_migrate>16 & age_migrate<22
       **tab age [fw=perwt]

     **Conditions on geo that can't be run until data is in RAM
        if "`geo_type'"=="division" rename region division
        if "`geo_type'"=="region" {
          replace region=floor(region/10)
          tab region
        }

     **Keeps college-aged in school or people with BA or higher
       keep if (age<25 & school==2) | (educd>100)
       keep if `geo_var'>0


     **Collapses, total students and graduates
       collapse (mean) year school (sum) students=perwt [fw=perwt], by(`geo_var' age)

       if `i'>1 {
         append using $thisdata/`geo_dir'/students_`bpld'.dta
       }
       save $thisdata/`geo_dir'/students_`bpld'.dta, replace

       local i=`i'+1
     }

    **Information to characterize someone as a international college student
    **1. school: "are you in school"
    **2. bpld:   "birth place, detailed": measure for foreign born
    **3. age: adults
    **4. yrimmig: limit to people who moved since they were 16

end

**have a nice day!
