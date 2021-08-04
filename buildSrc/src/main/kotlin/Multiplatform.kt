import com.android.build.gradle.LibraryExtension
import org.gradle.api.Project
import org.gradle.kotlin.dsl.*
import org.jetbrains.kotlin.gradle.dsl.KotlinMultiplatformExtension
import org.jetbrains.kotlin.gradle.plugin.KotlinDependencyHandler
import org.jetbrains.kotlin.gradle.plugin.KotlinTarget

@Suppress("UnstableApiUsage")
fun Project.applyMultiplatform() {

    apply(plugin = "com.android.library")
    apply(plugin = "org.jetbrains.kotlin.multiplatform")

    configure<LibraryExtension> {
        compileSdkVersion(Versions.Android.sdk)
        buildFeatures {
            viewBinding = true
        }
    }

    configure<KotlinMultiplatformExtension> {
        targets.apply {
            add(android("jvm"))
        }

        sourceSets.apply {
            named("commonMain") {
                dependencies {
                    implementation(Dependencies.Kotlin.core)
                    implementation(Dependencies.Ktor.core)
                }
            }

            named("jvmMain") {
                dependencies {
                    implementation(Dependencies.Kotlin.coroutinesJvm)
                    implementation(Dependencies.Ktor.core)
                }
            }

            named("jvmTest") {
                dependencies {
                    implementation(Dependencies.Kotlin.junit)
                    implementation(Dependencies.Kotlin.coroutinesTest)
                }
            }
        }

    }

    tasks.register("checkAll") {
        dependsOn("testDebugUnitTest")
    }

}

fun Project.kmpDependencies(sourceSet: String, block: KotlinDependencyHandler.() -> Unit) {
    configure<KotlinMultiplatformExtension> {
        sourceSets.apply {
            named(sourceSet) {
                dependencies {
                    block(this)
                }
            }
        }
    }
}

fun Project.commonDependencies(block: KotlinDependencyHandler.() -> Unit) = kmpDependencies("commonMain", block)
fun Project.jvmDependencies(block: KotlinDependencyHandler.() -> Unit) = kmpDependencies("jvmMain", block)
fun Project.jvmTestDependencies(block: KotlinDependencyHandler.() -> Unit) = kmpDependencies("jvmTest", block)
fun Project.nativeDependencies(block: KotlinDependencyHandler.() -> Unit) = kmpDependencies("nativeMain", block)
