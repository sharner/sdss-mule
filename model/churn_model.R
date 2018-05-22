# https://tensorflow.rstudio.com/blog/keras-customer-churn.html

library(tidyverse)
library(readr)
library(keras)
library(rsample)
library(recipes)
library(yardstick)
library(corrr)
library(plotROC)

# Load and prune data
churn_data_raw <- read_csv("WA_Fn-UseC_-Telco-Customer-Churn.csv")
churn_data_tbl <- churn_data_raw %>%
  select(-customerID) %>%
  drop_na() %>%
  select(Churn, everything())
glimpse(churn_data_tbl)

# Break into training and test
# Split test/training sets
set.seed(100)
train_test_split <- initial_split(churn_data_tbl, prop = 0.8)
train_tbl <- training(train_test_split)
test_tbl  <- testing(train_test_split)

# Determine if log transformation improves correlation
# between TotalCharges and Churn
train_tbl %>%
  select(Churn, TotalCharges) %>%
  mutate(
    Churn = Churn %>% as.factor() %>% as.numeric(),
    LogTotalCharges = log(TotalCharges)
  ) %>%
  correlate() %>%
  focus(Churn) %>%
  fashion()


# Create recipes
rec_obj <- recipe(Churn ~ ., data = train_tbl) %>%
  step_discretize(tenure, options = list(cuts = 6)) %>%
  step_log(TotalCharges) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_center(all_predictors(), -all_outcomes()) %>%
  step_scale(all_predictors(), -all_outcomes()) %>%
  prep(data = train_tbl)

# Predictors
x_train_tbl <- bake(rec_obj, newdata = train_tbl) %>% select(-Churn)
x_test_tbl  <- bake(rec_obj, newdata = test_tbl) %>% select(-Churn)

# Response variables for training and testing sets
y_train_vec <- ifelse(pull(train_tbl, Churn) == "Yes", 1, 0)
y_test_vec  <- ifelse(pull(test_tbl, Churn) == "Yes", 1, 0)

# Defining the model

# Building our Artificial Neural Network

model_keras <- keras_model_sequential() %>%
  # First hidden layer
  layer_dense(
    units              = 16,
    kernel_initializer = "uniform",
    activation         = "relu",
    input_shape        = ncol(x_train_tbl)) %>%
  # Dropout to prevent overfitting
  layer_dropout(rate = 0.1) %>%
  # Second hidden layer
  layer_dense(
    units              = 16,
    kernel_initializer = "uniform",
    activation         = "relu") %>%
  # Dropout to prevent overfitting
  layer_dropout(rate = 0.1) %>%
  # Output layer
  layer_dense(
    units              = 1,
    kernel_initializer = "uniform",
    activation         = "sigmoid") %>%
  # Compile ANN
  compile(
    optimizer = 'adam',
    loss      = 'binary_crossentropy',
    metrics   = c('accuracy')
  )

# Fit the model to traing data

history <- fit(
  object           = model_keras,
  x                = as.matrix(x_train_tbl),
  y                = y_train_vec,
  batch_size       = 50,
  epochs           = 10,
  validation_split = 0.30
)

# Class predictions
yhat_keras_class_vec <- predict_classes(object = model_keras,
                                        x = as.matrix(x_test_tbl)) %>%
  as.vector()

# Predicted class probabilities
yhat_keras_prob_vec  <- predict_proba(object = model_keras,
                                      x = as.matrix(x_test_tbl)) %>%
  as.vector()

# Format test data and predictions for yardstick metrics

estimates_keras_tbl <- tibble(
  truth      = as.factor(y_test_vec) %>% fct_recode(yes = "1", no = "0"),
  estimate   = as.factor(yhat_keras_class_vec) %>% fct_recode(yes = "1", no = "0"),
  class_prob = yhat_keras_prob_vec
)
estimates_keras_tbl
options(yardstick.event_first = FALSE)

# Accuracy
estimates_keras_tbl %>% metrics(truth, estimate)

# Confusion Table
estimates_keras_tbl %>% conf_mat(truth, estimate)

# AUC
estimates_keras_tbl %>% roc_auc(truth, class_prob)

# Plot the ROC
roc_plot <- ggplot(estimates_keras_tbl, aes(d = truth, m = class_prob)) + geom_roc()
roc_plot

# Precision
tibble(
  precision = estimates_keras_tbl %>% precision(truth, estimate),
  recall    = estimates_keras_tbl %>% recall(truth, estimate)
)

# F1-Statistic
estimates_keras_tbl %>% f_meas(truth, estimate, beta = 1)

# Save the test set and the model

save_model_hdf5(model_keras, filepath="/tmp/mule-pipeline/churn_model.h5",
                overwrite = TRUE, include_optimizer = TRUE)


churn_data_raw_tbl <- bake(rec_obj, newdata = churn_data_raw %>% select (-customerID)) %>% select(-Churn)
churn_data_raw_tbl <- bind_cols(churn_data_raw %>% select(customerID), churn_data_raw_tbl)

write_csv(churn_data_raw_tbl, path="/tmp/mule-pipeline/churn_data_raw_tbl.csv", col_names=FALSE)
