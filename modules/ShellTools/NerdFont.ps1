function Build-NerdFonts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][String]$InputDirectory,
        [Parameter(Mandatory)][String]$OutputDirectory,
        [int]$ParallelProcesses = 4,
        [switch]$Dry
    )

    # Check if fontforge is available
    $fontforgeCmd = Get-Command fontforge -ErrorAction SilentlyContinue
    if (-not $fontforgeCmd) {
        throw "fontforge command not found. Please ensure FontForge is installed and available in PATH."
    }

    # Validate input directory exists
    if (-not (Test-Path $InputDirectory)) {
        throw "Input directory '${InputDirectory}' does not exist."
    }

    # Search for font files (non-recursive)
    $fontFiles = (Get-ChildItem -Path $InputDirectory -File -Filter '*.?t?').Where{
        $_.Extension -in @('.ttf', '.ttc', '.otf')
    }

    if ($fontFiles.Count -eq 0) {
        throw "No font files (.ttf, .ttc, or .otf) found in '${InputDirectory}'."
    }

    Write-Output "Found $($fontFiles.Count) font file(s) to process."

    # Create output directory if it doesn't exist
    if (-not (Test-Path $OutputDirectory)) {
        Write-Output "Creating output directory: ${OutputDirectory}"
        $null = New-Item -ItemType Directory -Path $OutputDirectory -Force
    }

    Write-Output "Processing $($fontFiles.Count) file(s) using ${ParallelProcesses} parallel process(es)."

    # Start parallel processing
    $job = $fontFiles | ForEach-Object -ThrottleLimit $ParallelProcesses -AsJob -Parallel {
        $file = $_
        $outputDir = $using:OutputDirectory
        $isDry = $using:Dry
        $fullName = $file.FullName
        $name = $file.Name
        $errorLog = Join-Path $outputDir "${name}.error.log"

        if (-not (Test-Path $errorLog))
        {
            $null = New-Item -ItemType File -Path $errorLog -Force
        }

        Write-Output "Processing: ${name}"

        # Construct fontforge arguments
        $fontforgeArgs = @(
            '-script',
            'font-patcher',
            '--complete',
            '--makegroups',
            '5',
            '--outputdir',
            $outputDir,
            '--quiet',
            '--no-progressbars',
            '--name',
            "$($file.BaseName -replace '-','_')-NF"
        )
        if ($isDry) {
            $fontforgeArgs += '--dry'
        }

        $fontforgeArgs += $fullName

        # Execute fontforge command
        Write-Output "PS> fontforge ${fontforgeArgs} 2>${errorLog}"
        try {
            fontforge $fontforgeArgs 2>$errorLog
            Write-Output "Completed: ${name}"
        } catch {
            Write-Error "Error processing ${name}: $_"
        }
    }

    # Monitor job output
    while ($job.State -eq 'Running') {
        Receive-Job $job
        Start-Sleep -Seconds 1
    }

    # Receive any remaining output
    Receive-Job $job

    # Wait for all jobs to complete and clean up
    $null = $job | Wait-Job | Remove-Job -Force

    # Display completion message
    Write-Output "All font files have been processed. Output directory: ${OutputDirectory}"
}

Export-ModuleMember -Function Build-NerdFonts
