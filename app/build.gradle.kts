import org.jetbrains.kotlin.gradle.plugin.mpp.NativeBuildType.DEBUG
import org.jetbrains.kotlin.gradle.plugin.mpp.NativeBuildType.RELEASE

plugins {
    kotlin("multiplatform")
}

kotlin {
    jvm()
    linuxX64("linux") {
        binaries {
            executable("native-template", setOf(DEBUG, RELEASE)) {
                entryPoint = "main"
            }
        }
    }
    macosX64("macos") {
        binaries {
            executable("native-template", setOf(DEBUG, RELEASE)) {
                entryPoint = "sample.objc.main"
            }
        }
    }
    mingwX64("mingw") {
        binaries {
            executable("native-template", setOf(DEBUG, RELEASE)) {
                entryPoint = "sample.win32.main"
                linkerOpts("-Wl,--subsystem,windows")
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
