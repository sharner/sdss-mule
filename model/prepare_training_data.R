install.packages(c('tidyverse', 'randomNames', 'keras',
  'rsample', 'recipes', 'yardstick', 'corrr', 'plotROC'),
  repos='http://cran.us.r-project.org')
require(tidyverse)
require(randomNames)

watson_data = "https://community.watsonanalytics.com/wp-content/uploads/2015/03/WA_Fn-UseC_-Telco-Customer-Churn.csv"

# Load, prune data, and split data
split_training_data <- function() {

  download.file(watson_data, destfile = "telco_data.csv", method="curl")
  churn_data_raw <- read_csv("telco_data.csv")

  churn_data_tbl <- churn_data_raw %>%
    drop_na() %>%
    select(Churn, everything())

  # customerID, gender, SeniorCitizen, Partner, Dependents, tenure, Name
  customer_fields <- churn_data_tbl %>%
    select('customerID', 'gender', 'SeniorCitizen', 'Partner', 'Dependents', 'tenure')

  # Names are required, so we generate random names
  gender <- ifelse(customer_fields$gender == 'Male', 0, 1)
  customer_fields$Names <- randomNames(gender=gender)

  # Billing fields will be stored in postgres
  billing_fields <- churn_data_tbl %>%
    select('customerID', 'PhoneService', 'MultipleLines', 'InternetService',
           'OnlineSecurity', 'OnlineBackup', 'DeviceProtection', 'TechSupport',
           'StreamingTV', 'StreamingMovies', 'Contract', 'PaperlessBilling',
           'PaymentMethod')

  # Transaction fields: customerID,MonthlyCharges,TotalCharges,Churn
  transactions_fields <- churn_data_tbl %>%
    select('customerID', 'MonthlyCharges', 'TotalCharges', 'Churn')

  # Write out files so we can import them where needed
  write_csv(customer_fields, path='customer_fields.csv')
  write_csv(billing_fields, path='billing_fields.csv')
  write_csv(transactions_fields, path='transactions_fields.csv')

  # Data used in training
  churn_data_tbl %>% select(-customerID)
}

# Call as follows:
split_training_data()
