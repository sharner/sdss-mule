# Deploying the Serving Model

First, assembly a jar file with all dependencies needed.

```
sbt assembly
```

Packaging in local maven repo.  Set the SCALA_LIB directory correctly.

```
SCALA_LIB=/home/soeren/sdss-mule/serving
mvn install:install-file \
  -Dfile=$SCALA_LIB/target/scala-2.12/ChurnModelServing-assembly-0.1.0-SNAPSHOT.jar \
  -DgroupId=churnmodelserving \
  -DartifactId=churnmodelserving -Dversion=0.1.0-SNAPSHOT -Dpackaging=jar
```

And in the Mule pom.xml
```
<dependency>
  <groupId>churnmodelserving</groupId>
  <artifactId>churnmodelserving</artifactId>
  <version>0.1.0-SNAPSHOT</version>
</dependency>
```
