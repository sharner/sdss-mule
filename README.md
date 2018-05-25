# Churn Prediction API and Model

This repo is an end-to-end example that shows how to combine MuleSoft and Tensorflow to create an ML Pipeline and prediction API.  It is based on a presentation I did at the 2018 [Symposium on Data Science and Statistics](https://ww2.amstat.org/meetings/sdss/2018/).  See the [Presentation](https://www.slideshare.net/sorenharner/intelligent-application-networks-with-mule-and-tensorflow-98589429), which also contains a complete video and demo.

# Data and Complete Example in R

 The churn prediction model is an adaptation of the example on the RStudio blog post [Deep Learning With Keras To Predict Customer Churn](https://tensorflow.rstudio.com/blog/keras-customer-churn.html).  The data used for churn in this example comes from IBM Watson, described on the Watson blog [Using Customer Behavior Data to Improve Customer Retention](https://www.ibm.com/communities/analytics/watson-analytics-blog/predictive-insights-in-the-telco-customer-churn-data-set/).

# Install the prerequisites

To run the Mule Applications, you need first need to install some prerequisites.  Given the nature of this demo, there are a lot of moving parts.

1. Clone the [sdss-mule](https://github.com/sharner/sdss-mule) repo.
2. Download and install [Anypoint Studio 7.1](https://www.mulesoft.com/platform/studio).
3. Download and install [Java 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) or newer and [Scala SBT](https://www.scala-lang.org/download/)
4. Download and install [R](https://cloud.r-project.org/) and optionally [RStudio](https://www.rstudio.com/).
5. Download and install [Postgres](https://www.postgresql.org/download/).
6. Set up a [Salesforce Development Account](https://developer.salesforce.com/signup).
7. Create a new Bucket on AWS, and install the [AWS CLI](https://aws.amazon.com/cli/).

# Loading the data

The main idea of this demonstration is that Mule can accelerate the data science by making it easy to pull data from different systems.  To demonstrate this, we will first split the data into three groups for `customer data`, `billing data`, and `transaction data`, which will be imported into `Salesforce`, `Postgres`, and `S3`, respectively.  The demonstration will then show how to fetch data from these systems using Mule as part of an ML pipeline.

First, run the R function to prepare the data and install R packages.  Set `INSTALL_DIR` to be the base directory of this repo.

```
BASE_DIR="$HOME/sdss-mule"
Rscript -e "source('$BASE_DIR/model/prepare_training_data.R')"
```

Second, upload the `customer_fields.csv` to Salesforce.  Add the new fields to the Account object, which you can find under `Setup > Object Manager`.

| Name  | Type |
| ------------- | ------------- |
| customerID  | Text(10) (External ID)  |
| Dependents  | Checkbox  |
| gender  | Picklist with Male, Female  |
| SeniorCitizen  | Checkbox  |
| Partner  | Checkbox  |
| tenure | Number(4, 0) |

Then, using the Import Data Wizard, which you can find under `Setup > Data`.  If you run into trouble, you can use `Setup > Data > Mass Delete Records` to remove accounts and try again.
