import org.jetbrains.kotlin.gradle.plugin.mpp.NativeBuildType.DEBUG

plugins {
    kotlin("multiplatform")
}

kotlin {
    jvm()
    linuxX64("linux") {
        binaries {
            executable("test", setOf(DEBUG)) {
                entryPoint = "main"
            }
        }
    }
    macosX64("macos") {
        binaries {
            executable("test", setOf(DEBUG)) {
                entryPoint = "sample.objc.main"
            }
        }
    }
    mingwX64("mingw") {
        binaries {
            executable("test", setOf(DEBUG)) {
                entryPoint = "main"
            }
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation(Libs.serializationRuntime)
            }
        }
        val linuxMain by getting {
            dependencies {
                implementation(Libs.curlHttpClient)
            }
        }
        val macosMain by getting {
            dependencies {
                implementation(Libs.curlHttpClient)
            }
        }
        val mingwMain by getting {
            dependencies {
                implementation(Libs.curlHttpClient)
            }
        }
    }
}
