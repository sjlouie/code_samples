"""
This program scrapes historical data on board membership for the city of LA.

website url:

https://cityclerk.lacity.org/chronola/index.cfm?fuseaction=app.Organization

Data points and type

1. Name: Official's full name
2. Year: Year of the election
3. Elected: Boolean for if the official was elected or appointed
4. Term: String containing the length of the term
5. Board: which board/council the offical was in

-Schuyler Louie

"""


#########################
#########################
#Import packages
#########################
#########################
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from selenium.webdriver.common.keys import Keys
import csv



########################
#Functions
########################

def to_csv (year, names, offices, terms, elected_list):
    """this function takes the scraped lists and writes them to a csv file """
    #extracts just the year from the date of the election
    year_path = year.split()[-1]
    with open('/Users/sjlouie/Documents/RESEARCH/ND/LA/Data/la_csvs/election_' + year_path + '.csv', mode='w+') as f:
        fieldnames = ['Name', 'Year', 'Elected', 'Term', 'Board']
        rows = []
        for name, office, term, elected in zip(names, offices, terms, elected_list):
            tmp_list = []
            tmp_list.append(name)
            tmp_list.append(year)
            tmp_list.append(elected)
            tmp_list.append(term)
            tmp_list.append(office)
            rows.append(tmp_list)

        write = csv.writer(f)
        write.writerow(fieldnames)
        write.writerows(rows)

    print('\n wrote to /Users/sjlouie/Documents/RESEARCH/ND/LA/Data/la_csvs/election_'+ str(year_path) + '.csv \n ')

def scrape(i):
    """ This is the main scraping function. Does this for every election in the main code"""
    """ i is the xpath index of whichever election to scrape, 1 is the most recent, 2 is second most
        recent, ... """

    #Declare driver, if running this on your own, you must download the chomre driver and use the path its in
    driver = webdriver.Chrome('/Users/sjlouie/Applications/chromedriver')  # Optional argument, if not specified will search path.
    #Go to website
    driver.get('https://cityclerk.lacity.org/chronola/index.cfm?fuseaction=app.Organization')

    #clicking on the election year
    year_button = driver.find_element_by_xpath('/html/body/table/tbody/tr[3]/td[1]/div/form/select/option[' + str(i) + ']')
    year = driver.find_element_by_xpath('/html/body/table/tbody/tr[3]/td[1]/div/form/select/option[' + str(i) + ']').get_attribute('textContent')
    year_button.click()


    print("\n \n \n For the " + year + ' election \n \n \n')


    #Declaring lists to store data points in

    #This is for offices
    offices = []
    names = []
    terms = []
    elected_list = []

    #######################
    #######################
    #This is for elected
    #######################
    #######################

    #Expands are the offices
    expands = driver.find_elements_by_class_name('expand')

    #removing empty expands
    for expand in expands[:]:
        if expand.text == '' : expands.remove(expand)

    #Parallel iterating collapse and expand since collapse is not a sub element of expand
    for expand,collapse in zip(expands, range(len(expands) + 1)):
        #finds corresponding collapse
        collapse = driver.find_element_by_xpath('//*[@id="demo1"]/div[' + str(collapse + 1) + ']')

        #finds office holders within the collapse
        office_holders = collapse.find_elements_by_class_name('OfficeHolder')
        print(len(office_holders))

        #adds attributes of every office holder to respective list
        for office_holder in office_holders:
            terms.append((office_holder.find_element_by_class_name('alignright').get_attribute('textContent')))
            names.append((office_holder.find_element_by_class_name('alignleft').get_attribute('textContent')))
            offices.append(expand.get_attribute('textContent'))
            elected_list.append(1)


    if len(terms) == len(names) == len(offices) == len(elected_list):
        print('\n \n lengths are the same \n \n')


    #######################
    #######################
    #Navigating to appointed
    #######################
    #######################


    appointed_button = driver.find_element_by_link_text('Appointed Officials')
    appointed_button.click()
    driver.implicitly_wait(1)


    #######################
    #######################
    #Scraping appointed
    #######################
    #######################

    ##############################################
    #Same process as before except elected = 0 Now
    #And its demo2 instead of demo1 for the collapse
    ##############################################

    #Expands are the offices
    expands = driver.find_elements_by_class_name('expand')

    #removing empty expands
    for expand in expands[:]:
        if expand.text == '' : expands.remove(expand)

    for expand,collapse in zip(expands, range(len(expands) + 1)):
        #finds corresponding collapse
        collapse = driver.find_element_by_xpath('//*[@id="demo2"]/div[' + str(collapse + 1) + ']')
        #finds office holders
        office_holders = collapse.find_elements_by_class_name('OfficeHolder')
        print(len(office_holders))

        for office_holder in office_holders:
            #appends name
            terms.append((office_holder.find_element_by_class_name('alignright').get_attribute('textContent')))
            names.append((office_holder.find_element_by_class_name('alignleft').get_attribute('textContent')))
            offices.append(expand.get_attribute('textContent'))
            elected_list.append(0)

    driver.close()
    #######################
    #######################
    #write lists to csv file for each year
    #######################
    #######################

    to_csv (year, names, offices, terms, elected_list)


#########################
#########################
#Main Code
#########################
#########################

#######################
# making lists for loop later
#######################

#List of xpath indexes for each elections we want
xpath_i = []
#all elections
for i in range(1,107):
    #87 causing problems so skip it
    if not i == 87:
        xpath_i.append(i)

for i in xpath_i:
    scrape (i)


#################
#All done
#################
