package com.kaoruk

import scala.io.Source

import org.scalatest.FlatSpec

class PersonSpec extends FlatSpec {
  private val testFileContent = "Hello world from resources test!"
  private val relativePath = "person/src/test/resources/hello_world_test.txt"

  // This is an example of where the data files reside in relation to the test runs. Alternative to resources.
  "PersonSpec" should "be able to read data file via TEST_SRCDIR" in {
    val testDir = System.getenv().get("TEST_SRCDIR")
    val file = Source.fromFile(s"$testDir/learning_bazel/$relativePath")
    val content = file.getLines().mkString("\n")
    assert(content.equals(testFileContent))
    file.close()
  }

  it should "be able to read data file via relative path" in {
    val file = Source.fromFile(relativePath)
    val content = file.getLines().mkString("\n")
    assert(content.equals(testFileContent))
    file.close()
  }

  it should "whatever" ignore {
    "foobar"
  }
}