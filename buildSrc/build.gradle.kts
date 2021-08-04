
plugins {
    `kotlin-dsl`
}

repositories {
    google()
    jcenter()
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:1.4.31")
    implementation("org.jetbrains.kotlin:kotlin-serialization:1.4.31")
    implementation("com.android.tools.build:gradle:4.1.1")
}
