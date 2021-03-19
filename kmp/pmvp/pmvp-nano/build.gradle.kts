applyMultiplatform()
applyMavenPublish(group = "org.pmvp.nano", name = name, version = "0.0.1")

commonDependencies {
    implementation(project(":kmp:pmvp:pmvp-library"))
}

// version notes
// 0.0.1 - initial draft
