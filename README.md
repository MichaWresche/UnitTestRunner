# UnitTestRunner
Powershell script to run unit test without an IDE

# Motivation
During my work as .NET software developer, I was annoyed of slow IDE's like Visual Studio or Jetbrains Rider. Visual Studio often hangs and crashes with a huge code base and rider seems to have issues when detecting current test runner state. During my job, I often work with a huge code base and like to run unit tests locally, before pushing my changes to the central repository.
Of course, unit tests will mostly executed within the CI pipeline but I want a test feedback as fast as possible. For big teams, the CI resources like build agents often are limited so the CI feedback to the developer takes a while.

With this repository, I want to share a PowerShell script that helps me to run existing unit tests to ensure that I've not breaking any existing tests.
