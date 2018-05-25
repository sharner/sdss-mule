CREATE TABLE Billing (
  CreatedAt TIMESTAMP DEFAULT NOW(),
  customerID CHAR(10) NOT NULL,
  PhoneService VARCHAR(30) NOT NULL,
  MultipleLines VARCHAR(30) NOT NULL,
  InternetService VARCHAR(30) NOT NULL,
  OnlineSecurity VARCHAR(30) NOT NULL,
  OnlineBackup VARCHAR(30) NOT NULL,
  DeviceProtection VARCHAR(30) NOT NULL,
  TechSupport VARCHAR(30) NOT NULL,
  StreamingTV VARCHAR(30) NOT NULL,
  StreamingMovies	 VARCHAR(30) NOT NULL,
  Contract VARCHAR(30) NOT NULL,
  PaperlessBilling VARCHAR(30) NOT NULL,
  PaymentMethod VARCHAR(30) NOT NULL
);

COPY Billing (customerID, PhoneService, MultipleLines, InternetService, OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies, Contract, PaperlessBilling, PaymentMethod
)
FROM '/Users/sorenharner/sdss-mule/billing_fields.csv' DELIMITER ',' CSV HEADER;
