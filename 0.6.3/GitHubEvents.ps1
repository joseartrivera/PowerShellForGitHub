# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

function Get-GitHubEvent
{
<#
    .DESCRIPTION
        Lists events for an issue, repository, or a single event

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER OwnerName
        Owner of the repository.
        If not supplied here, the DefaultOwnerName configuration property value will be used.

    .PARAMETER RepositoryName
        Name of the repository.
        If not supplied here, the DefaultRepositoryName configuration property value will be used.

    .PARAMETER Uri
        Uri for the repository.
        The OwnerName and RepositoryName will be extracted from here instead of needing to provide
        them individually.

    .PARAMETER EventID
        The ID of a specific event to get. If not supplied, will return back all events for this repository.

    .PARAMETER Issue
        Issue number to get events for. If not supplied, will return back all events for this repository.

    .PARAMETER AccessToken
        If provided, this will be used as the AccessToken for authentication with the
        REST Api.  Otherwise, will attempt to use the configured value or will run unauthenticated.

    .PARAMETER NoStatus
        If this switch is specified, long-running commands will run on the main thread
        with no commandline status update.  When not specified, those commands run in
        the background, enabling the command prompt to provide status information.
        If not supplied here, the DefaultNoStatus configuration property value will be used.

    .EXAMPLE
        Get-GitHubEvent -OwnerName Powershell -RepositoryName PowerShellForGitHub

        Get the events for the PowerShell\PowerShellForGitHub project.
#>
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParametersetName='RepositoryElements')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    param(
        [Parameter(Mandatory, ParameterSetName='RepositoryElements')]
        [Parameter(Mandatory, ParameterSetName='IssueElements')]
        [Parameter(Mandatory, ParameterSetName='EventElements')]
        [string] $OwnerName,

        [Parameter(Mandatory, ParameterSetName='RepositoryElements')]
        [Parameter(Mandatory, ParameterSetName='IssueElements')]
        [Parameter(Mandatory, ParameterSetName='EventElements')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName='RepositoryUri')]
        [Parameter(Mandatory, ParameterSetName='IssueUri')]
        [Parameter(Mandatory, ParameterSetName='EventUri')]
        [string] $Uri,

        [Parameter(Mandatory, ParameterSetName='EventUri')]
        [Parameter(Mandatory, ParameterSetName='EventElements')]
        [int] $EventID,

        [Parameter(Mandatory, ParameterSetName='IssueUri')]
        [Parameter(Mandatory, ParameterSetName='IssueElements')]
        [int] $Issue,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    $elements = Resolve-RepositoryElements
    $OwnerName = $elements.ownerName
    $RepositoryName = $elements.repositoryName

    $telemetryProperties = @{
        'OwnerName' = (Get-PiiSafeString -PlainText $OwnerName)
        'RepositoryName' = (Get-PiiSafeString -PlainText $RepositoryName)
        'ProvidedIssue' = $PSBoundParameters.ContainsKey('Issue')
        'ProvidedEvent' = $PSBoundParameters.ContainsKey('EventID')
    }

    $uriFragment = "repos/$OwnerName/$RepositoryName/issues/events"
    $description = "Getting events for $RepositoryName"

    if ($PSBoundParameters.ContainsKey('EventID'))
    {
        $uriFragment = "repos/$OwnerName/$RepositoryName/issues/events/$EventID"
        $description = "Getting event $EventID for $RepositoryName"
    }
    elseif ($PSBoundParameters.ContainsKey('Issue'))
    {
        $uriFragment = "repos/$OwnerName/$RepositoryName/issues/$Issue/events"
        $description = "Getting events for issue $Issue in $RepositoryName"
    }

    $acceptHeaders = @(
        'application/vnd.github.starfox-preview+json',
        'application/vnd.github.sailer-v-preview+json',
        'application/vnd.github.symmetra-preview+json',
        'application/vnd.github.machine-man-preview')

    $params = @{
        'UriFragment' = $uriFragment
        'Description' = $description
        'AccessToken' = $AccessToken
        'AcceptHeader' = $acceptHeaders -join ','
        'TelemetryEventName' = $MyInvocation.MyCommand.Name
        'TelemetryProperties' = $telemetryProperties
        'NoStatus' = (Resolve-ParameterWithDefaultConfigurationValue -Name NoStatus -ConfigValueName DefaultNoStatus)
    }

    return Invoke-GHRestMethodMultipleResult @params
}

# SIG # Begin signature block
# MIIdkgYJKoZIhvcNAQcCoIIdgzCCHX8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDoViJ4aemI3xueMyxRoCn9Ak
# TgagghhuMIIE2jCCA8KgAwIBAgITMwAAAQniGdb5uKS+vwAAAAABCTANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTgwODIzMjAyMDI4
# WhcNMTkxMTIzMjAyMDI4WjCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAldBMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# LTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046ODZERi00QkJDLTkzMzUxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIHNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDDBEYNasjuHhHcnMfqXCPKVVJmNLy0NR3tKvzJ5DJ14mS/
# JzIDYdy4PcjuDVpfSbyus/oJb+x/yfbxNFY7QE7l1btQxjcFVflHYwIdzCSoGJiR
# 04rEAl2Fe5iSk2tEHk3UsUZBikNx5w5Vl1bX28orI4K7QCFbGDNqBoweB9Hds5sy
# q00yAF8XO9qQGNvZtl3vdIwcRRrOQ3TR1Y1mTGthwPcMtjg6jENyCDApVVVqK2E4
# FhWueYLJ6bQjtd5jujFhQI9pWuvQu6WhHQkj7f4J0c6+KfHWrkyKLEbYqCxLZzPi
# 6kU92kncczZQ3cInx+wF9nQXKhUruRxF/nK7fwhRAgMBAAGjggEJMIIBBTAdBgNV
# HQ4EFgQUE/+29IxW4NNxfLLzyyT6JOU+vacwHwYDVR0jBBgwFoAUIzT42VJGcArt
# QPt2+7MrsMM1sw8wVAYDVR0fBE0wSzBJoEegRYZDaHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljcm9zb2Z0VGltZVN0YW1wUENBLmNy
# bDBYBggrBgEFBQcBAQRMMEowSAYIKwYBBQUHMAKGPGh0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0VGltZVN0YW1wUENBLmNydDATBgNV
# HSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQUFAAOCAQEAnXZC/rUVkXiH6VjM
# iJDMxxf4sbFk8iSPJlfC3TvIJ2foqAuGCzn2Rpw3P32w5r9Ql185YZfii4tHscNg
# FDFqX+zXjUUo/gDgxakjITGaS+ZrI1nJnwGidRT5WHkyT8bBIdaVjK3jxONm9169
# l5xO5wGmNlWuhGmC9jQ5xECZ8KGN47PZrgI+jFxJQGyUxVan3uRZqStUPzld3lz+
# EG4FQPdxBDDRMIYsZpNEXRjvqsQJ8s19MZ4hoSxRhOdnmTVisyT/nbNxzOepMtO+
# XuM5bPGGSmCbvm68+INMuxHERykRmmpavF4++JR9ywvGtVQhej45oHnkvXM9xGt3
# uPOaPDCCBgMwggProAMCAQICEzMAAAEEaeLbufuKDYMAAAAAAQQwDQYJKoZIhvcN
# AQELBQAwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYG
# A1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMTAeFw0xODA3MTIy
# MDA4NDlaFw0xOTA3MjYyMDA4NDlaMHQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xHjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJvFlfKX9v8jamydc1lzOJvTtOOE
# rY24PiXnoLggWkqRcDjYFKi9msD9DWse7OH8/wQ84mFgrlVqYZL71wB9nuppNtb9
# V3kZl/6EkfbHVa2mrgKK7bGRR1bNSodmRacwGxrtrHtrBdIzgnO+xm8czNToGgUV
# AC6Rl7ZLyGFnIovnExJowhcUryZatu5Vc3z1RLMhJwYA67U2+fwmiq0/f0QUw3q7
# I8iL3r4WisEhogIB2X+YkuIxU4+HsZAkmxf6FU3KAWwQbFICopNfYgNBJIxwp3As
# jUsv1zNZXP1d4D/X5IQXu30+edOCQ2JUQMibXs9wFDtgPGk/nzfn+BaSM4sCAwEA
# AaOCAYIwggF+MB8GA1UdJQQYMBYGCisGAQQBgjdMCAEGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBS6F+MlaPS71Xsjpri2fOemgqtXrjBUBgNVHREETTBLpEkwRzEtMCsGA1UE
# CxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMRYwFAYDVQQF
# Ew0yMzAwMTIrNDM3OTY2MB8GA1UdIwQYMBaAFEhuZOVQBdOCqhc3NyK1bajKdQKV
# MFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
# cHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcmwwYQYIKwYBBQUH
# AQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAKcWCCzmZIAzoJFuJOzhQkoOV25Hy
# O9Kk8NqBW3OOZ0gatsmKB3labM7D/GaYF7K716YWtQNWhXsqfS9ABk6eaddpFBWO
# Y/vMgPXbEZxQ7ksCcUxrBwX+Z1PxGbZubizyj9RFKeE2CLIceIEnloeZQhh3lNzG
# vJ2k21amNtBDSF9ABH5n6YjYAMfrMv/eCndgA3P+nqHHHfPAsy1hh8jxN4Xc/G08
# SxNKEna1UEpN513zTyHkmBKBgf7pXKj8FIzRAp9l+3Z1t2JTx33ax7pC4m57Jkoj
# gjLYjXUeEW+Lf3oG1aofGKVwE+fuaJ0HvAbpiQOWDGriIaslA9i3ARHhxCKWKTF8
# w1VO0BznRcZmAIoVIcTFAXAd4mgBOQ8iIcmoc39w2Cz09WnlSWw5paKpyns51fl3
# bzBzg5bAo4uu5X/dY03aFct7+R3ljsQ6qkr0LUVmn/JeuEkXOePfHUmJYYu6M69e
# Quoa1PVRU/GlXZKbh2e4dqsGVeGu1YOvOf8gMYtc5vq1B8+GJ8dBAiM5bVlOLsB4
# rzpJY2zieOAjdtQrqGcAPGVSWDDSeOl47e27KX2iHzjl7FnHk5lF+QCIykR6R9Ym
# R83UCcK1epAMPRYWfreU20ZSAEoeuT1pyVFlatU/EcQtN5dfksINMQya1ll38FBI
# h4l2k9jzfUqwItgwggYHMIID76ADAgECAgphFmg0AAAAAAAcMA0GCSqGSIb3DQEB
# BQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/IsZAEZFgltaWNy
# b3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMxMzAzMDlaMHcxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ+h
# bLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn0UytdDAgEesH1VSVFUmUG0KS
# rphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0Zxws/HvniB3q506jocEjU8qN
# +kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4nrIZPVVIM5AMs+2qQkDBuh/NZ
# MJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YRJylmqJfk0waBSqL5hKcRRxQJ
# gp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54QTF3zJvfO4OToWECtR0Nsfz3
# m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsGA1UdDwQEAwIBhjAQBgkrBgEE
# AYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJgQFYnl+UlE/wq4QpTlVnkpKFj
# pGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jv
# c29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
# aXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL21pY3Jvc29mdHJvb3Rj
# ZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0Um9vdENlcnQuY3J0MBMG
# A1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBBQUAA4ICAQAQl4rDXANENt3p
# tK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1iuFcCy04gE1CZ3XpA4le7r1ia
# HOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+rkuTnjWrVgMHmlPIGL4UD6ZEq
# JCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGctxVEO6mJcPxaYiyA/4gcaMvnM
# MUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/FNSteo7/rvH0LQnvUU3Ih7jDK
# u3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbonXCUbKw5TNT2eb+qGHpiKe+i
# myk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0NbhOxXEjEiZ2CzxSjHFaRkMU
# vLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPpK+m79EjMLNTYMoBMJipIJF9a
# 6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2JoXZhtG6hE6a/qkfwEm/9ijJs
# sv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0eFQF1EEuUKyUsKV4q7OglnUa
# 2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng9wFlb4kLfchpyOZu6qeXzjEp
# /w7FW1zYTRuh2Povnj8uVRZryROj/TCCB3owggVioAMCAQICCmEOkNIAAAAAAAMw
# DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eSAyMDExMB4XDTExMDcwODIwNTkwOVoXDTI2MDcwODIxMDkwOVowfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKvw+nIQHC6t2G6qghBNNLrytlghn0IbKmvpWlCquAY4GgRJun/D
# DB7dN2vGEtgL8DjCmQawyDnVARQxQtOJDXlkh36UYCRsr55JnOloXtLfm1OyCizD
# r9mpK656Ca/XllnKYBoF6WZ26DJSJhIv56sIUM+zRLdd2MQuA3WraPPLbfM6XKEW
# 9Ea64DhkrG5kNXimoGMPLdNAk/jj3gcN1Vx5pUkp5w2+oBN3vpQ97/vjK1oQH01W
# KKJ6cuASOrdJXtjt7UORg9l7snuGG9k+sYxd6IlPhBryoS9Z5JA7La4zWMW3Pv4y
# 07MDPbGyr5I4ftKdgCz1TlaRITUlwzluZH9TupwPrRkjhMv0ugOGjfdf8NBSv4yU
# h7zAIXQlXxgotswnKDglmDlKNs98sZKuHCOnqWbsYR9q4ShJnV+I4iVd0yFLPlLE
# tVc/JAPw0XpbL9Uj43BdD1FGd7P4AOG8rAKCX9vAFbO9G9RVS+c5oQ/pI0m8GLhE
# fEXkwcNyeuBy5yTfv0aZxe/CHFfbg43sTUkwp6uO3+xbn6/83bBm4sGXgXvt1u1L
# 50kppxMopqd9Z4DmimJ4X7IvhNdXnFy/dygo8e1twyiPLI9AN0/B4YVEicQJTMXU
# pUMvdJX3bvh4IFgsE11glZo+TzOE2rCIF96eTvSWsLxGoGyY0uDWiIwLAgMBAAGj
# ggHtMIIB6TAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQUSG5k5VAF04KqFzc3
# IrVtqMp1ApUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGG
# MA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAUci06AjGQQ7kUBU7h6qfHMdEj
# iTQwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3Br
# aS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0MjAxMV8yMDExXzAzXzIyLmNybDBe
# BggrBgEFBQcBAQRSMFAwTgYIKwYBBQUHMAKGQmh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0MjAxMV8yMDExXzAzXzIyLmNydDCB
# nwYDVR0gBIGXMIGUMIGRBgkrBgEEAYI3LgMwgYMwPwYIKwYBBQUHAgEWM2h0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvZG9jcy9wcmltYXJ5Y3BzLmh0bTBA
# BggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBwAG8AbABpAGMAeQBfAHMAdABh
# AHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAZ/KGpZjgVHkaLtPY
# dGcimwuWEeFjkplCln3SeQyQwWVfLiw++MNy0W2D/r4/6ArKO79HqaPzadtjvyI1
# pZddZYSQfYtGUFXYDJJ80hpLHPM8QotS0LD9a+M+By4pm+Y9G6XUtR13lDni6WTJ
# RD14eiPzE32mkHSDjfTLJgJGKsKKELukqQUMm+1o+mgulaAqPyprWEljHwlpblqY
# luSD9MCP80Yr3vw70L01724lruWvJ+3Q3fMOr5kol5hNDj0L8giJ1h/DMhji8MUt
# zluetEk5CsYKwsatruWy2dsViFFFWDgycScaf7H0J/jeLDogaZiyWYlobm+nt3TD
# QAUGpgEqKD6CPxNNZgvAs0314Y9/HG8VfUWnduVAKmWjw11SYobDHWM2l4bf2vP4
# 8hahmifhzaWX0O5dY0HjWwechz4GdwbRBrF1HxS+YWG18NzGGwS+30HHDiju3mUv
# 7Jf2oVyW2ADWoUa9WfOXpQlLSBCZgB/QACnFsZulP0V3HjXG0qKin3p6IvpIlR+r
# +0cjgPWe+L9rt0uX4ut1eBrs6jeZeRhL/9azI2h15q/6/IvrC4DqaTuv/DDtBEyO
# 3991bWORPdGdVk5Pv4BXIqF4ETIheu9BCrE/+6jMpF3BoYibV3FWTkhFwELJm3Zb
# CoBIa/15n8G9bW1qyVJzEw16UM0xggSOMIIEigIBATCBlTB+MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29k
# ZSBTaWduaW5nIFBDQSAyMDExAhMzAAABBGni27n7ig2DAAAAAAEEMAkGBSsOAwIa
# BQCggaIwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFOj8r3a/S7B2YGRjNap/wtu7
# 1MuNMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBho
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEBBQAEggEAbrbjzL7S
# lliA7J/uNV9ny+olp0YfWrfToZxqlgaljAzdRvA+aK1a9aQVXU8oI/vZS2Ne32EC
# kHwcG1HpsIYJF3f8mnySEv26GJH4ObXLELrXnjSX69hhT7QvGAda8s4tXqz64Ums
# WpAZsZFvyq1d8FbZ12F33IMbozlFiMZ3RVWku+gE/xPnS5HiMDQ55ivmGXwSEw2R
# +ZwS5X6O40UhKmi3+f96ZdydQk0/aQNu+lNODSxkCHKub/o2oJECRssywWNRLMGu
# O/sAoLwV+oaR4VY1P9rnvPeefXM55C5JVKQ32YXunV6405vOBjhXTyr8aHCuK5AA
# 1iEFDpWgmdw2mqGCAigwggIkBgkqhkiG9w0BCQYxggIVMIICEQIBATCBjjB3MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0ECEzMAAAEJ4hnW+bikvr8AAAAAAQkwCQYFKw4D
# AhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8X
# DTE5MDEwNzE3Mjk0NFowIwYJKoZIhvcNAQkEMRYEFHHPPQihfi8v/hzK4Q//UsS2
# IR2mMA0GCSqGSIb3DQEBBQUABIIBAKpsf9L9l8MV5dCxIs+ZrIos5HN5pJGdKBwA
# 3K1/WTocUb0/TORmCrC5V792Hdp2ApQ1vsk8AocAOdVbNY8Zg0xY7TuB//nDajn3
# wLsw4IaBhFnJjn5XtQ3Y1L1s3hfBDv+drN+/5K2aePhM+GWzfZPgHwd4x+r1s+gM
# MuKwolXVZcF+bazDeqmOsdWNRrepHtN3vtlW4Oi0qSYb7OWQsj0lBKSSaT3n2jRw
# aNH8bGvyhloauhOoY/Yyv/8bc3iXFWfyxGWT6junM3hOr1CuKwLe4F9ce7k1qJ59
# HYvK1YrtQXRjPERWYadgabcBujAJpXmicf8fCYNPOfhmZkyt23E=
# SIG # End signature block