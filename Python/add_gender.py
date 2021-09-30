"""
#This program adds gender (and other datapoints from gender package to dataset)

Schuyler Louie

#"""
#########################
#########################
#Import packages
#########################
#########################
import os
import pandas as pd
import requests
import simplejson as json
import csv
import numpy as np
import time

pd.set_option("display.max_rows", None, "display.max_columns", None)



#########################
#########################
#functions
#########################
#########################

def genderize(nameList):

    """ Attempting to fix function from gender.py package"""

    gender = []
    probability = []
    count = []

    req = ''
    while req == '':
        try:
            for name in nameList:
                req = requests.get("https://api.genderize.io/?name=" + name + "&apikey=3575aafd080770ff43d3953a9662b7bd")
                print("https://api.genderize.io/?name=" + name + "&apikey=3575aafd080770ff43d3953a9662b7bd")
                result = json.loads(req.text)
                gender.append(result['gender'])
                probability.append(result['probability'])
                count.append(result['count'])

            df = pd.DataFrame({ "Gender" : gender, "Probability" : probability, "Count" : count},
                columns = ['Gender', 'Probability', 'Count'])
            return df
            break

        except:
            print("Connection refused by the server..")
            print("Let me sleep for 5 seconds")
            print("ZZzzzz...")
            time.sleep(5)
            print("Was a nice sleep, now let me continue...")
            continue




def listToString(s):
    """turns list into a string"""
    # initialize an empty string
    str1 = " "

    # return string
    return (str1.join(s))



########################
#########################
#Main Code
#########################
#########################

#Takes in archived csvs and then puts them into the updated folder
path  = '/Users/sjlouie/Documents/RESEARCH/ND/LA/Data/la_csvs/'

#To archived csvs
archive = '/Users/sjlouie/Documents/RESEARCH/ND/LA/Old/la_csvs061121/'



for file in os.listdir(archive):
    filename = os.fsdecode(file)

        print('\n \n appending to ' + filename + '\n \n')

        df = pd.read_csv(archive + filename)

        names_col = pd.Series(df['Name'])
        df_tmp = names_col.str.split(',', expand = True)

        #taking off leading and trailing spaces
        df_tmp[0] = df_tmp[0].str.strip()
        df_tmp[1] = df_tmp[1].str.strip()

        #appending to dataset
        df = pd.concat([df,df_tmp], axis = 1)
        df.rename(columns={0: 'Last', 1: 'First'}, inplace=True)

        #extracting names in a list
        nameList = df['First'].tolist()


        #cleaning up names for api call
        for i in range(len(nameList)):

            #replace dots with nothing for API
            nameList[i] = nameList[i].replace('.', '')
            nameList[i] = nameList[i].replace(' ', '')

            #will use in next loop to count capital letters
            cap_count = 0
            cap_list = []
            all_caps = False

            #if number of capitals doesnt equal len of name, get rid of every
            #thing past the second capital inclusive
            #Example JohnP becomes John

            nameList[i] = list(nameList[i])

            for j in range(len(nameList[i])):
                if ord(nameList[i][j]) >= 65 and ord(nameList[i][j]) <= 90:
                    cap_count += 1

            if cap_count == len(nameList[i]):
                all_caps = True

            cap_count = 0

            for j in range(len(nameList[i])):
                if not (ord(nameList[i][j]) >= 97 and ord(nameList[i][j]) <= 122):
                    cap_count += 1
                if cap_count > 1 and all_caps == False:
                    nameList[i][j] = ' '


            nameList[i] = listToString(nameList[i]).replace(' ', '')

        #now moving to genderize function and adding gender attributes

        df = pd.concat([df,genderize(nameList)], axis = 1)

        #assigning gender to prefixes we know gender to
        df.loc[df['Name'].str.contains("Mr. "),'Gender'] = 'male'
        df.loc[df['Name'].str.contains("Mr. "),'Probability'] = 1
        df.loc[df['Name'].str.contains("Ms. "),'Gender'] = 'female'
        df.loc[df['Name'].str.contains("Ms. "),'Probability'] = 1
        df.loc[df['Name'].str.contains("Mrs. "),'Gender'] = 'female'
        df.loc[df['Name'].str.contains("Mrs. "),'Probability'] = 1

        df.to_csv(path + filename, mode = 'w+')

print(total_names)

print('\n \n JOBS DONE \n \n')
