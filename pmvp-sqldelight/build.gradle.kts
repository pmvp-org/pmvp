applyMultiplatform()

commonDependencies {
    implementation(project(":pmvp-library"))
    implementation(Dependencies.SqlDelight.core)
}

jvmTestDependencies {
    implementation(Dependencies.Test.mockk)
    implementation(Dependencies.Test.mockkCommon)
}

// version notes
// 0.0.2 - updates after pmvp-library refactor
// 0.0.1 - initial draft
