package churnmodel

import java.util.concurrent.TimeUnit

import org.scalatest.{FlatSpec, Matchers}

class PredictChurnSpec extends FlatSpec with Matchers {

  // probability can't be larger than 1.0
  val MaxValue = 1.0

  "PredictChurn" should "predict from customer num" in {
    val rec = PredictChurn.predict("7590-VHVEG")
    assert(rec.get("churn") == "yes")
    assert(rec.get("probability").toDouble > 0.5)
  }


  "PredictChurn" should "error when customer not found" in {
    val rec = PredictChurn.predict("0000-FOOOO")
    assert(rec.get("message") == "Customer not found")
  }

  "ProductChurn" should "predict from array" in {

    /* Columns are:
       SeniorCitizen	MonthlyCharges	TotalCharges	gender_Male	Partner_Yes	Dependents_Yes	tenure_bin1	tenure_bin2	tenure_bin3
       tenure_bin4	tenure_bin5	tenure_bin6	PhoneService_Yes	MultipleLines_No.phone.service	MultipleLines_Yes	InternetService_Fiber.optic
       InternetService_No	OnlineSecurity_No.internet.service	OnlineSecurity_Yes	OnlineBackup_No.internet.service
       OnlineBackup_Yes	DeviceProtection_No.internet.service	DeviceProtection_Yes	TechSupport_No.internet.service	TechSupport_Yes
       StreamingTV_No.internet.service	StreamingTV_Yes	StreamingMovies_No.internet.service	StreamingMovies_Yes	Contract_One.year
       Contract_Two.year	PaperlessBilling_Yes	PaymentMethod_Credit.card..automatic.	PaymentMethod_Electronic.check	PaymentMethod_Mailed.check
    */

    val predictors = Array[Double](
      -0.442683366,
      -1.1595623497,
      -0.7867917484,
      -1.0106324208,
      -0.9591522132,
      -0.6413789116,
      -0.4592348464,
      2.2703402178,
      -0.4558262547,
      -0.4461242552,
      -0.4489848552,
      -0.4323038364,
      -3.0592962864,
      3.0592962864,
      -0.8515331755,
      -0.8900279275,
      -0.5283636971,
      -0.5283636971,
      1.5799170769,
      -0.5283636971,
      -0.721990463,
      -0.5283636971,
      -0.7228452225,
      -0.5283636971,
      -0.6353116243,
      -0.5283636971,
      -0.7846200587,
      -0.5283636971,
      -0.7967916676,
      -0.5126441347,
      -0.5580022915,
      -1.2033114414,
      -0.5242335797,
      -0.7182908124,
      1.828607965)
    val rec = PredictChurn.predict(predictors)
    assert(rec.get("churn") == "no")
    assert(rec.get("probability").toDouble <= 0.5)

  }

}
