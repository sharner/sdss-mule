import Dependencies._
import sbt.Keys.libraryDependencies

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.permaling",
      scalaVersion := "2.12.4",
      version      := "0.1.0-SNAPSHOT"
    )),
    name := "ChurnModelServing",
    libraryDependencies += scalaTest % Test,
    libraryDependencies += "org.scala-lang.modules" %% "scala-parser-combinators" % "1.1.0",
    libraryDependencies += "org.apache.commons" % "commons-text" % "1.2",
    libraryDependencies += "org.apache.commons" % "commons-lang3" % "3.7",
    libraryDependencies += "org.apache.commons" % "commons-csv" % "1.5",
    libraryDependencies += "org.deeplearning4j" % "deeplearning4j-core" % "1.0.0-alpha",
    libraryDependencies += "org.deeplearning4j" % "deeplearning4j-nlp" % "1.0.0-alpha",
    libraryDependencies += "org.nd4j" % "nd4j-native-platform" % "1.0.0-alpha"
  )

assemblyMergeStrategy in assembly := {
 case PathList("META-INF", xs @ _*) => MergeStrategy.discard
 case x => MergeStrategy.first
}

  // Exclude all but macosx-x86_64 and linux-x86
assemblyExcludedJars in assembly := {
  val cp = (fullClasspath in assembly).value
  cp filter {
    j => (j.data.getName.contains("windows-x86") ||
      j.data.getName.contains("linux-ppc64le") ||
      j.data.getName.contains("linux-armhfq") ||
      j.data.getName.contains("linux-armhfq") ||
      j.data.getName.contains("linux-armhf") ||
      j.data.getName.contains("linux-x86.") || // 32-bit Linux
      j.data.getName.contains("android") ||
      j.data.getName.contains("ios-arm64") ||
      j.data.getName.contains("ios-x86_64") )
  }
}
