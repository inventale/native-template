buildscript {
    repositories {
        google()
        jcenter()
    }
}

plugins {
    kotlin("multiplatform") version Versions.kotlinVersion
}

kotlin {
    jvm()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions.jvmTarget = Config.kotlinJvmTargetVersion
}

allprojects {
    repositories {
        google()
        jcenter()
    }
}

kotlin {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions.freeCompilerArgs += "-Xjvm-default=compatibility"
    }
}
