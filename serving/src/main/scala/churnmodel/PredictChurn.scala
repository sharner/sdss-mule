package churnmodel

import java.io.{File, InputStreamReader}

import org.apache.commons.io.FileUtils
import org.deeplearning4j.nn.modelimport.keras.KerasModelImport
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.nd4j.linalg.api.ndarray.INDArray
import org.nd4j.linalg.factory.Nd4j
import org.apache.commons.csv.{CSVFormat, CSVParser}
import java.util
import scala.collection.JavaConverters._

object PredictChurn {

  var keras_model: MultiLayerNetwork = null
  val cust_dat = new scala.collection.mutable.HashMap[String,Array[Double]]
  private val _tmp_model_file = "tmp_keras_model.h5"

  // positive label
  val PositiveClass = 0

  // Initialize Fusion Model
  def init_churn_model(): Unit = {
    val in = this.getClass.getClassLoader
      .getResourceAsStream("churn_model.h5")
    FileUtils.copyInputStreamToFile(in, new File(_tmp_model_file))
    keras_model = KerasModelImport.importKerasSequentialModelAndWeights(_tmp_model_file)
  }

  // Initialize Fusion Model
  def init_customer_dat(): Unit = {
    val in = new InputStreamReader(this.getClass.getClassLoader
      .getResourceAsStream("churn_data_raw_tbl.csv"))
    val csvParser = new CSVParser(in, CSVFormat.DEFAULT)
    for (row <- csvParser.getRecords.asScala) {
      val it = row.iterator
      // first element is customer id
      val cid = it.next
      try {
        val v = it.asScala.map(_.toDouble).toArray
        cust_dat.put(cid, v)
      } catch {
        // Skip this cid if there are NAs
        case e: Exception => e.getMessage
      }
    }
  }

  def predict(predictors: Array[Double]) : java.util.HashMap[String, String] = {
    // Load the model if needed
    if (keras_model == null) init_churn_model

    // Run the model
    val d: INDArray = Nd4j.create(predictors)
    val prob = keras_model.labelProbabilities(d).getDouble(0)

    // Return java-friendly output for Mule
    val jmap = new util.HashMap[String, String]
    jmap.put("churn", if (prob > 0.5) "yes" else "no")
    jmap.put("probability", prob.toString)
    jmap
  }

  def customer_not_found() : java.util.HashMap[String, String] = {
    val jmap = new util.HashMap[String, String]
    jmap.put("message", "Customer not found")
    jmap
  }

  def predict(cust_id: String) : java.util.HashMap[String, String] = {
    // Load customer data if needed
    if (cust_dat.size == 0) init_customer_dat

    // call the prediction step; error if cust_id doesn't exist
    cust_dat.get(cust_id) match {
      case Some(predictors) => predict(predictors)
      case None => customer_not_found
    }
  }



}
