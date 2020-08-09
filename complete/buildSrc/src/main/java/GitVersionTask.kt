import org.gradle.api.DefaultTask
import org.gradle.api.file.RegularFileProperty
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction

/*
 * Copyright (c) 2020.
 * Designed and developed by @quabynah_codelabs (Dennis Bilson)
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 09/08/2020 @ 03:01
 */
abstract class GitVersionTask : DefaultTask() {

    @get:OutputFile
    abstract val gitVersionOutputFile: RegularFileProperty

    @TaskAction
    fun taskAction() {
        val process = ProcessBuilder("git", "rev-parse --short HEAD")
            .start()
        val error = process.errorStream.readBytes().contentToString()
        if (error.isNotBlank()) {
            throw RuntimeException("Git error : ${'$'}error")
        }
        val gitVersion = process.inputStream.readBytes().contentToString()
        gitVersionOutputFile.get().asFile.writeText(gitVersion)
    }
}