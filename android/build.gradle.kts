allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Add Google services classpath so we can apply the plugin in the app module.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google services classpath removed (Firebase/FCM disabled)
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
