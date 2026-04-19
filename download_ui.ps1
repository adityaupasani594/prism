$OutputFolder = "C:\Users\upasa\Codes\PRISM\ui"
if (-Not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder
}

$Screens = @(
    @{ Title = "Consent Request Refined"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzM2NjZjMTlhZmZmODRiMDU5MjFjYzFjNzgzNDczZmNhEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Identity Wallet"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzE0NTIzYjFjMWMwNDQ3ZTc4ZjZjMGY0ZTliZTdiNmFhEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Business Dashboard"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzk0OWU2MGU5ZjQzNTQ0ODM5YmVjMmI0NGIzYjYzZTEzEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Get Paid"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2VjNGQzY2YxOGNiYTQ2MTRiYzc0ODY4OWJjNmVhOWM3EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Verification Request"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2IxYjI1MDQ0MmQ0YTRkOWRhMjYxNzlhMmVmM2Q2OGJiEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Generating Proof"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzg0MDMzOTM2NDIyNjQxM2VhZjBkYWY0Mjk5MjU2NjU3EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Active Access"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2Q5YmJjMGRlNWEwZjQ2MDU5N2NhNzk0NTc5MmI0ODA5EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Consent History"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzU0MmUzMDQxZDY1MjQwMTI5OGE1YTc2ZTQ4NjIxZDRiEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Verification Success"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2M1MjQ5OGNlMTRmMzRjYTNhOWJlMWE0YmUyNDk2ZTRiEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Wallet Dashboard"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzMwZGNiYmZjZDkwNzRhOGZhYTgxZDliZTgyNzBkNjIyEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Create Identity"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDVjZTQwOTBkMDQ4ZGE4ZDE3ZWU3OWZiNThhZDk2EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Consent Details"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzNjY2E4NDA1NmMzYTRkMWRhNmI5MzI2YzVkNTcxNzFkEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Identity Secured"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzUxYWUyMzVjOTAxYzRmNjNhNmM5OThmNmJhNDU1MDM0EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Settings"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzVlNTcwMWU4YzhmNzRjNzZiOWJmNTExMDJmMmE0N2Q0EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Own Your Data"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzhkZTUxNWRjYjg5NjRhNjliNjQ3ODgwMzYxZWU1Nzc0EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Data Marketplace"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzk4M2EwYzNkYTg5NTRkZjBiNDZmNDA1ZmM5MDI1ODMwEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Share Safely"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2U4NTdkNmI4MzM2MzQ0MzZiYzVhNjlmYmZlNjNhZDI2EgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" },
    @{ Title = "Privacy Dashboard"; Url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2I5ZmIyNzM4OWU2NzRkMGRiODhkZWZjODk2NDQyNDMwEgsSBxDkpbDFxg0YAZIBJAoKcHJvamVjdF9pZBIWQhQxMDM1NjA2MzkxNjMyMDYzMjI4OQ&filename=&opi=89354086" }
)

foreach ($Screen in $Screens) {
    $FileName = $Screen.Title -replace '[^a-zA-Z0-9]', '_'
    $FilePath = Join-Path $OutputFolder "$FileName.html"
    Invoke-WebRequest -Uri $Screen.Url -OutFile $FilePath
    Write-Host "Downloaded $($Screen.Title) to $FilePath"
}
Write-Host "Finished downloading all screens."
