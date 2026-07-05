// Inject jcenter() fallback for Gradle 9 compatibility with legacy Groovy plugins
try {
    val clazz = org.gradle.api.artifacts.dsl.RepositoryHandler::class.java
    val emc = groovy.lang.ExpandoMetaClass(clazz, false, true)
    emc.registerInstanceMethod("jcenter", object : groovy.lang.Closure<Any>(null) {
        fun doCall(): Any? {
            val handler = delegate as? org.gradle.api.artifacts.dsl.RepositoryHandler
            return handler?.mavenCentral()
        }
    })
    emc.initialize()
    groovy.lang.GroovySystem.getMetaClassRegistry().setMetaClass(clazz, emc)
} catch (e: Exception) {
    println("Failed to inject jcenter() fallback: $e")
}

allprojects {
    repositories {
        google()
        mavenCentral()
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

    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            android?.let {
                it.compileSdkVersion(36)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
