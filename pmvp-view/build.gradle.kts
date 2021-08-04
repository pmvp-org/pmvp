applyMultiplatform()

commonDependencies {
    implementation(project(":pmvp-library"))
}

jvmDependencies {
    implementation("androidx.fragment:fragment-ktx:1.2.5")
    implementation("androidx.recyclerview:recyclerview:1.1.0")
}

// version notes
// 0.0.1 - initial draft
