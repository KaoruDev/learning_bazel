package com.kaoruk.pets

case class Cat (override val name: String) extends Animal {
  override def speak: String = {
    "meow!!"
  }
}
