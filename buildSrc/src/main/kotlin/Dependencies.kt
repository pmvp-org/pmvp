object Dependencies {
    object Kotlin {
        const val core = "org.jetbrains.kotlinx:kotlinx-coroutines-core:${Versions.coroutines}"
        const val coroutinesJvm = "org.jetbrains.kotlinx:kotlinx-coroutines-android:${Versions.coroutines}"
        const val junit = "org.jetbrains.kotlin:kotlin-test-junit:${Versions.kotlin}"
        const val coroutinesTest = "org.jetbrains.kotlinx:kotlinx-coroutines-test:${Versions.coroutines}"
        const val serializationJson = "org.jetbrains.kotlinx:kotlinx-serialization-json:${Versions.serialization}"
    }
    object Ktor {
        const val core = "io.ktor:ktor-client-core:${Versions.ktor}"
    }
    object SqlDelight {
        const val core = "com.squareup.sqldelight:coroutines-extensions:${Versions.sqldelight}"
    }
    object Test {
        const val mockk = "io.mockk:mockk:${Versions.mockk}"
        const val mockkCommon = "io.mockk:mockk-common:${Versions.mockk}"
    }
}
