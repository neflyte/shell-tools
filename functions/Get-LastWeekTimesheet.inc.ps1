function Get-LastWeekTimesheet {
    $calendar = (Get-Culture).Calendar
    $today = Get-Date
    $lastWeek = $calendar.AddWeeks($today, -1)
    $dayOfLastWeek = [int]$lastWeek.DayOfWeek
    $startOfLastWeek = $lastWeek
    if ($dayOfLastWeek -gt 0) {
        $startOfLastWeek = $calendar.AddDays($lastWeek, -1 * $dayOfLastWeek)
    }
    $endOfLastWeek = $lastWeek
    if ($dayOfLastWeek -lt 6) {
        $endOfLastWeek = $calendar.AddDays($lastWeek, 6 - $dayOfLastWeek)
    }
    $tempOutput = New-TemporaryFile
    $startDate = $startOfLastWeek.ToString("yyyy-MM-dd")
    $endDate = $endOfLastWeek.ToString("yyyy-MM-dd")
    Write-Debug "timetracker timesheet report --logLevel warning --startDate ${startDate} --endDate ${endDate} --exportCSV $($tempOutput.FullName)"
    timetracker timesheet report --logLevel warning --startDate $startDate --endDate $endDate --exportCSV $($tempOutput.FullName)
    $report = Get-Content $tempOutput | ConvertFrom-Csv
    $tempOutput.Delete()
    return $report
}
