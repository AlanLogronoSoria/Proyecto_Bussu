allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix namespace for plugins without namespace (flutter_beacon with AGP 8.x)
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            val android = project.extensions.findByName("android") ?: return@afterEvaluate
            try {
                val nsGetter = android.javaClass.getMethod("getNamespace")
                val nsSetter = android.javaClass.getMethod("setNamespace", String::class.java)
                val ns = nsGetter.invoke(android) as? String?
    if (ns.isNullOrEmpty()) {
        val fallbackNs = project.group?.toString()
            ?.takeIf { it.isNotEmpty() }
            ?.replace('-', '_')
            ?: "com.example.${project.name.replace('-', '_').replace('.', '_')}"
        nsSetter.invoke(android, fallbackNs)
    }
            } catch (_: Exception) {
                // plugin does not support namespace
            }
        }
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
