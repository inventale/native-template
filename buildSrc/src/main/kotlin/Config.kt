import org.gradle.api.JavaVersion

object Config {
    val compileSourceVersion = JavaVersion.VERSION_1_8
    val compileTargetVersion = JavaVersion.VERSION_1_8
    const val kotlinJvmTargetVersion = "1.8"
}

object Versions {
    const val kotlinVersion = "1.4.0"

    // Libs
    const val ktorVersion = "1.4.0"
    const val coroutineVersion = "1.3.9-native-mt"
    const val serializationVersion = "1.0.0-RC"
    const val javaxAnnotation = "1.3.2"
}

object Plugins {
}

object Libs {
    const val coroutinesCore = "org.jetbrains.kotlinx:kotlinx-coroutines-core:${Versions.coroutineVersion}"
    const val ktorClientCore = "io.ktor:ktor-client-core:${Versions.ktorVersion}"
    const val serializationRuntime = "org.jetbrains.kotlinx:kotlinx-serialization-core:${Versions.serializationVersion}"

    const val curlHttpClient = "io.ktor:ktor-client-curl:${Versions.ktorVersion}"
    const val ktorClientJvm = "io.ktor:ktor-client-okhttp:${Versions.ktorVersion}"
}

