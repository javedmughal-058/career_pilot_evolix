allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val localNdkVersion = "27.0.12077973"

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
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        androidExtension.javaClass.methods
            .firstOrNull { method ->
                method.name == "setNdkVersion" && method.parameterTypes.size == 1
            }
            ?.invoke(androidExtension, localNdkVersion)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
