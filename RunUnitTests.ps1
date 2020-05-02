param
(
    [String] $TestAssembliesDirectory = "",
    [Boolean] $SearchRecurse = $true,
    [String] $NUnitConsoleRunnerExe = "",
    [String] $SearchTestsRegEx = "*tests.dll"
)

function GetTestAssemblies($SourceDirectory, $SearchRecursive, $SearchTestsRegEx) {
    
    if ($SearchRecursive) {
        return Get-ChildItem -Path $SourceDirectory -Recurse -Include $SearchTestsRegEx | Foreach-Object { $_.FullName }
    }
    else {
        if (-Not $SourceDirectory.EndsWith("*")) {
            
            if (-Not $SourceDirectory.EndsWith("\\")) {
                $SourceDirectory += "\\"
            }

            $SourceDirectory += "*"
        }

        return Get-ChildItem -Path $SourceDirectory -Include $SearchTestsRegEx | Foreach-Object { $_.FullName }
    }
}

[String[]] $TestAssemblies = GetTestAssemblies $TestAssembliesDirectory $SearchRecurse $SearchTestsRegEx

$NumberOfFailedTests = 0
$NumberOfPassedTests = 0

$NumberOfTestAssemblies = $TestAssemblies.Length
if ($NumberOfTestAssemblies -eq 0) {
    Write-Host "No unit tests found"
    exit(0)
}

Write-Host
Write-Host $("{0,-50} {1,-10} {2,-10}" -f "Test assembly", "Failed", "Passed")
Write-Host "-----------------------------------------------------------------------------------"

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

$Current = 1
Foreach ($i in $TestAssemblies) {
 
    $PercentageComplete = ($Current - 1) / $NumberOfTestAssemblies * 100

    Write-Progress -Activity "Running tests" -Status "$PercentageComplete% Complete:" -PercentComplete $PercentageComplete -CurrentOperation $("Running: " + $i + " (" + $Current + " of " + $NumberOfTestAssemblies + ")")

    $DebugOutput = New-TemporaryFile
    
    $args = $($i + " /out:" + $DebugOutput.FullName)
    Start-Process -FilePath $NunitConsoleRunnerExe -Wait -NoNewWindow -ArgumentList $args -RedirectStandardOutput "Nul"

    $TestResultsFile = $($PSScriptRoot + "\TestResult.xml")
    if (Test-Path $TestResultsFile -PathType Leaf) {
        $TestSuite = Select-Xml -Path $TestResultsFile -XPath "/test-run/test-suite" | Select-Object -ExpandProperty Node
        $NumberOfFailedTests += $TestSuite.failed
        $NumberOfPassedTests += $TestSuite.passed

        $output = "{0,-50} {1,-10} {2,-10}" -f $TestSuite.name, $TestSuite.failed, $TestSuite.passed

        if ($TestSuite.failed -gt 0) {
            Write-Host $output -ForegroundColor "red"
        }
        else {
            Write-Host $output -ForegroundColor "green"
        }
    }

    $Current++
}

$stopwatch.Stop()

Write-Host "-----------------------------------------------------------------------------------"

Write-Host $("Unit test execution finished (Duration: {0:f2} seconds)" -f $stopwatch.Elapsed.TotalSeconds)
Write-Host "The number of failed tests: " $NumberOfFailedTests
Write-Host "The number of passed tests: " $NumberOfPassedTests

