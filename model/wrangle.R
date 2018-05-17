library(tidyverse)
library(readr)

billing <- read_csv("/tmp/mule-pipeline/billing.csv") %>%
  rename(customerID=customerid)
salesforce <- read_csv("/tmp/mule-pipeline/salesforce.csv")
transactions <- read_csv("/tmp/mule-pipeline/transactions.csv")

churn_data <- salesforce %>%
  inner_join(billing, by='customerID') %>%
  inner_join(transactions, by='customerID')

write_csv(churn_data, path="/tmp/mule-pipeline/churn_data.csv")
