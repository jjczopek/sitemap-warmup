$sitemapPath = "sitemap-cnn.xml"

$Global:oIE = $null

function Get-SiteMapUrls {
  $urls = @()

  if(Test-Path $sitemapPath){
    Write-Host "$sitemapPath found, processing."

    [xml]$sitemapXml =  Get-Content $sitemapPath
    $sitemapXml.urlset.url | foreach {
      $urls += $_.loc
    }

    $maxUrls = 250
    if($urls.count -le $maxUrls){
      $maxUrls = $urls.count
    }

    $randomUrls = @()

    for($i=1; $i -le $maxUrls;  $i++){
       $randomUrls += $urls[(Get-Random -Maximum ($urls.count))]
    }

    return $randomUrls
  }
  else{
    Write-Host "$sitemapPath is not valid."
    return $urls
  }
}

function Start-IE {
  if($Global:oIE -eq $null){
    Write-Host "Initiating IE" -NoNewline
    $Global:oIE = new-object -com internetexplorer.application
    $Global:oIE.visible = $true

    while ($Global:oIE.busy) {
      sleep -milliseconds 50
      Write-Host "." -NoNewline
    }
    Write-Host
    Write-Host "Initiated IE."
  }
}

function Stop-IE {
  if($Global:oIE -ne $null){
    $Global:oIE.Quit()
    Write-Host "Stopped IE."
  }
}

function New-UrlWarmup {
  param(
    [string]$warmupUrl = $(throw "warmupUrl is required.")
  )
  Write-Host "Warming up $warmupUrl" -NoNewline

  $Global:oIE.navigate2($warmupUrl);

  #Wait for request
  while ($Global:oIE.ReadyState -ne 4) {
    Write-Host "." -NoNewline
    sleep -milliseconds 100
  }

  $doc = $Global:oIE.document;
  $doc.readyState
  Write-Host "|"
}

Start-IE
Get-SiteMapUrls | foreach {
  $_
  New-UrlWarmup -warmupUrl $_
  sleep -Seconds 1
}
Stop-IE
