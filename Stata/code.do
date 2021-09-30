
*********************************
** This is a code sample of the master script
** that runs all the analysis for our China HHI project
** - Schuyler Louie
*********************************


*********************************
** Setup
*********************************

**Paths
  global data    "/Volumes/Data/IPUMS"
  global thisdir "/Volumes/Bulk/LSS/Analysis"
  global thisdata "/Volumes/Bulk/LSS/Data"
  //changed for euro
  global thislatex "/Volumes/Bulk/LSS/Latex/figs"

**Loads programs
  do $thisdir/Dos/students_country.do
  do $thisdir/Dos/HHI.do
**Other globals
  global acs_vars "sex school bpld age year yrimmig perwt educd region statefip met*"
  //global acs_vars_more "sex school bpld age year yrimmig perwt educd statefip met2013"
*********************************
**Creates local for years
*********************************
  forvalues j=1980(10)2000 {
    local years "`years' `j'"
  }
  forvalues j=2005(1)2019 {
    local years "`years' `j'"
  }
  dis `years'
  //local years "2018" //this is the sample local for debugging
  //local years "2000 2018" //this is the sample local for debugging
*********************************



*********************************
** Runs programs
*********************************

students_country 1
students_country 50000

HHI 1
HHI 50000
